# POM Photo Sharing App

A photo sharing application with Ethereum donation integration built with React, Motoko, and Rust.

## Architecture Overview

This application consists of three main components:

1. **Frontend**: React application with Tailwind CSS for styling
2. **Backend**: Motoko canister running on the Internet Computer
3. **Ethereum Integration**: Rust service for handling crypto donations

## Project Structure

```
/hackathon-project
├── README.md
├── package.json
├── dfx.json                        # Internet Computer configuration
├── webpack.config.js               # Frontend build configuration
├── postcss.config.js               # PostCSS configuration for Tailwind
├── tailwind.config.js              # Tailwind CSS configuration
├── .gitignore
│
├── /src                            # Frontend source code
│   ├── /frontend                   # React application
│   │   ├── index.jsx               # Entry point
│   │   ├── App.jsx                 # Main application component with routing
│   │   ├── routes.js               # Route definitions
│   │   │
│   │   ├── /components
│   │   │   ├── /common
│   │   │   │   ├── Button.jsx      # Reusable button component
│   │   │   │   ├── ImageCard.jsx   # Photo card with like/info buttons
│   │   │   │   ├── Modal.jsx       # For pop-ups
│   │   │   │   ├── Navbar.jsx      # Top navigation with POM logo, Private button and Login
│   │   │   │   └── ...
│   │   │   │
│   │   │   ├── /auth
│   │   │   │   ├── LoginForm.jsx   # Email/password login form
│   │   │   │   ├── RegisterForm.jsx # Registration form with password confirmation
│   │   │   │   └── AuthModal.jsx   # "Sign in or register first" modal
│   │   │   │
│   │   │   ├── /gallery
│   │   │   │   ├── ImageGrid.jsx   # Grid of images for landing/private pages
│   │   │   │   ├── ImageUpload.jsx # For add pic functionality
│   │   │   │   └── ...
│   │   │   │
│   │   │   └── /modals
│   │   │       ├── DonoModal.jsx   # Donation/price setting modal
│   │   │       ├── AuthPromptModal.jsx # Pop-up for unauthenticated users
│   │   │       ├── SaveMemoryModal.jsx # Modal for saving an image
│   │   │       └── ...
│   │   │
│   │   ├── /contexts
│   │   │   ├── AuthContext.jsx     # Handle authentication state
│   │   │   ├── GalleryContext.jsx  # Manage images and collections
│   │   │   ├── BlockchainContext.jsx # Ethereum wallet connection and transactions
│   │   │   └── ...
│   │   │
│   │   ├── /hooks
│   │   │   ├── useAuth.js          # Custom hook for auth functionality
│   │   │   ├── useGallery.js       # Hook for image management
│   │   │   ├── useWallet.js        # Hook for Ethereum wallet interactions
│   │   │   ├── useSmartContract.js # Hook for interacting with smart contracts
│   │   │   └── ...
│   │   │
│   │   ├── /pages
│   │   │   ├── LandingPage.jsx     # Main gallery page
│   │   │   ├── LoginPage.jsx       # User login with mountain background
│   │   │   ├── RegisterPage.jsx    # User registration with mountain background
│   │   │   ├── PrivateGallery.jsx  # User's private collection
│   │   │   ├── AddPicture.jsx      # Upload new pictures
│   │   │   ├── DonoPage.jsx        # Donation/pricing page
│   │   │   ├── NFTGallery.jsx      # Display owned and purchasable NFTs
│   │   │   ├── WalletPage.jsx      # Wallet connection and management
│   │   │   └── ...
│   │   │
│   │   ├── /services
│   │   │   ├── auth.service.js     # Authentication API calls
│   │   │   ├── images.service.js   # Image upload/fetch functionality
│   │   │   ├── agent.js            # Internet Computer agent for Motoko backend calls
│   │   │   ├── blockchain.service.js # Ethereum blockchain interactions
│   │   │   └── ...
│   │   │
│   │   ├── /utils
│   │   │   ├── imageHelpers.js     # Image processing utilities
│   │   │   ├── validators.js       # Form validation
│   │   │   ├── web3Utils.js        # Ethereum utility functions
│   │   │   └── ...
│   │   │
│   │   ├── /contracts              # Frontend contract interfaces
│   │   │   ├── NFTContract.js      # NFT contract ABI and functions
│   │   │   ├── MarketplaceContract.js # Marketplace contract interface
│   │   │   └── ...
│   │   │
│   │   └── /styles
│   │       ├── index.css           # Global styles and Tailwind imports
│   │       ├── tailwind.css        # Tailwind base file with @tailwind directives
│   │       ├── components.css      # Additional custom styles beyond Tailwind
│   │       └── /theme              # Custom theme extensions for Tailwind
│   │           ├── colors.js       # Custom color palette
│   │           ├── buttons.js      # Button variants
│   │           └── ...
│   │
│   └── /backend                    # Motoko backend canisters
│       ├── /main                   # Main canister for app logic
│       │   ├── Types.mo            # Type definitions
│       │   ├── Auth.mo             # Authentication and user management
│       │   ├── Gallery.mo          # Photo gallery management
│       │   ├── Storage.mo          # Image and file storage
│       │   ├── Payments.mo         # Payment processing logic
│       │   └── Main.mo             # Main entry point canister
│       │
│       ├── /ethereum_bridge        # Canister for Ethereum integration
│       │   ├── Bridge.mo           # Bridge between IC and Ethereum
│       │   ├── EthTypes.mo         # Ethereum data types
│       │   └── TransactionVerifier.mo # Verify Ethereum transactions
│       │
│       └── /nft                    # NFT-related canisters
│           ├── NFT.mo              # NFT implementation
│           ├── Marketplace.mo      # NFT marketplace logic
│           └── ...
│
├── /assets                         # Static assets
│   ├── /images
│   │   ├── logo.svg
│   │   ├── mountain-lake.jpg
│   │   ├── forest-trees.jpg  
│   │   └── ...
│   └── /icons
│       └── ...
│
├── /ethereum                       # Ethereum smart contracts
│   ├── /contracts
│   │   ├── POMToken.sol            # ERC-20 token for the platform
│   │   ├── POMNFT.sol              # ERC-721 NFT contract
│   │   ├── Marketplace.sol         # NFT marketplace contract
│   │   └── ...
│   │
│   ├── /migrations                 # Truffle migration scripts
│   │   └── ...
│   │
│   ├── /test                       # Smart contract tests
│   │   └── ...
│   │
│   ├── truffle-config.js           # Truffle configuration
│   └── hardhat.config.js           # Hardhat configuration (alternative)
│
├── /declarations                   # Auto-generated type declarations
│   └── ...
│
└── /scripts                        # Deployment and utility scripts
    ├── deploy.sh                   # Deploy to Internet Computer
    ├── setup_ethereum.sh           # Deploy Ethereum contracts
    └── ...
```

## Prerequisites

- [Node.js](https://nodejs.org/) (v16 or later)
- [DFX](https://smartcontracts.org/) (Internet Computer SDK)
- [Rust](https://www.rust-lang.org/tools/install)
- [Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)

## Setup and Installation

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/pom-photo-app.git
cd pom-photo-app
```

### 2. Install dependencies

```bash
npm install
```

### 3. Set up environment variables

Create a `.env` file in the root directory:

```
# Frontend environment variables
REACT_APP_IC_HOST=http://localhost:8000
REACT_APP_BACKEND_CANISTER_ID=rrkah-fqaaa-aaaaa-aaaaq-cai

# Ethereum integration environment variables
INFURA_URL=https://mainnet.infura.io/v3/YOUR_INFURA_KEY
CONTRACT_ADDRESS=0xYourContractAddress
```

For the Rust Ethereum integration, create a `.env` file in the `eth-integration` directory:

```
INFURA_URL=https://mainnet.infura.io/v3/YOUR_INFURA_KEY
CONTRACT_ADDRESS=0xYourContractAddress
PRIVATE_KEY=YourPrivateKeyForTesting
```

### 4. Start the local Internet Computer replica

```bash
dfx start --background
```

### 5. Deploy the backend canister

```bash
dfx deploy backend
```

### 6. Start the frontend development server

```bash
npm start
```

### 7. Start the Ethereum integration service

```bash
cd eth-integration
cargo run
```

## Main Features

- **Photo Gallery**: Browse and view photos
- **User Authentication**: Register and login functionality
- **Photo Upload**: Upload and share photos with others
- **Private Collection**: Manage your personal photo collection
- **Ethereum Donations**: Support creators with cryptocurrency donations

## Development Workflow

1. Make changes to the React frontend in the `src` directory
2. Update Motoko backend in the `backend` directory
3. Deploy backend changes with `dfx deploy backend`
4. Modify the Ethereum integration in the `eth-integration` directory as needed

## Deployment

### Deploying to the Internet Computer

```bash
dfx deploy --network ic
```

### Deploying the Ethereum Integration

The Rust Ethereum integration should be deployed to a server with:

```bash
cargo build --release
```

Then run the resulting binary on your server.

## Testing

```bash
# Test the frontend
npm test

# Test the backend
dfx canister call backend test

# Test the Ethereum integration
cd eth-integration
cargo test
```

## License

MIT