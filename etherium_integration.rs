// src/main.rs
use std::sync::Arc;
use tokio::sync::Mutex;
use warp::{Filter, Rejection, Reply};
use serde::{Deserialize, Serialize};
use web3::{
    contract::{Contract, Options},
    transports::Http,
    types::{Address, TransactionParameters, U256},
    Web3,
};
use ethabi::{Token, Function, Param, ParamType};
use hex::ToHex;
use std::str::FromStr;
use dotenv::dotenv;
use std::env;

// Donation struct for request/response
#[derive(Debug, Deserialize, Serialize, Clone)]
struct Donation {
    amount: f64,
    currency: String,
    from_address: String,
    user_id: u64,
}

// Response types
#[derive(Debug, Serialize)]
struct ApiResponse {
    success: bool,
    message: String,
    transaction_hash: Option<String>,
}

// Ethereum connection state
struct EthState {
    web3: Web3<Http>,
    contract_address: Address,
    donation_contract: Contract<Http>,
}

// Initialize Ethereum connection and contract
async fn init_ethereum() -> Result<EthState, Box<dyn std::error::Error>> {
    dotenv().ok();
    
    // Get configuration from environment
    let infura_url = env::var("INFURA_URL")
        .unwrap_or_else(|_| "https://mainnet.infura.io/v3/YOUR_INFURA_KEY".to_string());
    
    let contract_address_str = env::var("CONTRACT_ADDRESS")
        .unwrap_or_else(|_| "0x0000000000000000000000000000000000000000".to_string());
    
    let contract_address = Address::from_str(&contract_address_str)?;
    
    // Connect to Ethereum node
    let transport = Http::new(&infura_url)?;
    let web3 = Web3::new(transport);
    
    // Set up contract ABI - simplified example
    let contract_abi = r#"[
        {
            "inputs": [
                {"name": "userId", "type": "uint256"}
            ],
            "name": "donate",
            "outputs": [],
            "stateMutability": "payable",
            "type": "function"
        }
    ]"#;
    
    // Create contract instance
    let donation_contract = Contract::new(web3.eth(), contract_address, ethabi::Contract::load(contract_abi.as_bytes())?);
    
    Ok(EthState {
        web3,
        contract_address,
        donation_contract,
    })
}

// Process donation through Ethereum
async fn process_donation(
    eth_state: Arc<Mutex<EthState>>,
    donation: Donation,
) -> Result<String, Box<dyn std::error::Error>> {
    let state = eth_state.lock().await;
    
    // Get the sender's private key from environment (in a real app would be from secure storage)
    let private_key_hex = env::var("PRIVATE_KEY")
        .unwrap_or_else(|_| "0000000000000000000000000000000000000000000000000000000000000000".to_string());
    
    // Create the donation parameters
    let amount_wei = U256::from((donation.amount * 1e18) as u64); // Convert ETH to Wei
    let from_address = Address::from_str(&donation.from_address)?;
    
    // Prepare the transaction
    let function = Function {
        name: "donate".to_owned(),
        inputs: vec![
            Param { name: "userId".to_owned(), kind: ParamType::Uint(256) }
        ],
        outputs: vec![],
        constant: false,
    };
    
    let params = vec![Token::Uint(U256::from(donation.user_id))];
    let data = function.encode_input(&params)?;
    
    let tx_params = TransactionParameters {
        to: Some(state.contract_address),
        value: amount_wei,
        data: data.into(),
        ..Default::default()
    };
    
    // In a real application, you would:
    // 1. Use a proper wallet implementation to sign with the private key
    // 2. Have better error handling
    // 3. Not store private keys directly in code or environment variables
    
    // This is just a simplified example
    let signed_tx = web3::signing::sign_transaction(
        tx_params,
        &private_key_hex.parse()?,
        state.web3.eth().chain_id().await?,
    );
    
    // Send the transaction
    let tx_hash = state.web3.eth().send_raw_transaction(signed_tx.into()).await?;
    
    // Return the transaction hash
    Ok(format!("0x{}", tx_hash.encode_hex::<String>()))
}

// API handler for donations
async fn handle_donation(
    eth_state: Arc<Mutex<EthState>>,
    donation: Donation,
) -> Result<impl Reply, Rejection> {
    match process_donation(eth_state, donation.clone()).await {
        Ok(tx_hash) => {
            let response = ApiResponse {
                success: true,
                message: format!("Donation of {} {} processed successfully", donation.amount, donation.currency),
                transaction_hash: Some(tx_hash),
            };
            Ok(warp::reply::json(&response))
        },
        Err(e) => {
            let response = ApiResponse {
                success: false,
                message: format!("Error processing donation: {}", e),
                transaction_hash: None,
            };
            Ok(warp::reply::json(&response))
        }
    }
}

// Main function to start the server
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize Ethereum connection
    let eth_state = Arc::new(Mutex::new(init_ethereum().await?));
    
    // Clone the state for route handlers
    let eth_state_filter = warp::any().map(move || eth_state.clone());
    
    // POST /api/donate endpoint
    let donate_route = warp::path!("api" / "donate")
        .and(warp::post())
        .and(eth_state_filter.clone())
        .and(warp::body::json())
        .and_then(handle_donation);
    
    // Combine routes and start server
    let routes = donate_route.with(warp::cors().allow_any_origin());
    
    println!("Starting Ethereum integration server on localhost:3001");
    warp::serve(routes).run(([127, 0, 0, 1], 3001)).await;
    
    Ok(())
}

// Smart contract for reference (Solidity) - would be deployed separately
/*
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PhotoDonation {
    address payable public owner;
    mapping(uint256 => uint256) public userDonations;
    
    event DonationReceived(address donor, uint256 userId, uint256 amount);
    
    constructor() {
        owner = payable(msg.sender);
    }
    
    function donate(uint256 userId) public payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        
        userDonations[userId] += msg.value;
        emit DonationReceived(msg.sender, userId, msg.value);
    }
    
    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw");
        owner.transfer(address(this).balance);
    }
}
*/