# POM Photo Sharing App

A photo sharing application with Ethereum donation integration built with React, Motoko, and Rust.

## Architecture Overview

This application consists of three main components:

1. **Frontend**: React application with Tailwind CSS for styling
2. **Backend**: Motoko canister running on the Internet Computer
3. **Ethereum Integration**: Rust service for handling crypto donations

## Project Structure

```
pom-photo-app/
├── src/                    # Frontend React code
│   ├── components/         # Reusable React components
│   ├── pages/              # Page components
│   ├── context/            # React context for state management
│   └── declarations/       # Auto-generated canister interfaces
├── backend/                # Motoko backend code
├── eth-integration/        # Rust Ethereum integration
│   └── src/
│       └── main.rs         # Rust Ethereum service
├── public/                 # Static assets
└── dfx.json                # Internet Computer configuration
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