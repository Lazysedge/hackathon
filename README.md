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

# POM - Photo Sharing Platform

POM is a decentralized photo sharing platform built on Internet Computer and Ethereum, allowing users to share images, create private collections, and monetize their content through NFTs.

![POM Platform](./assets/images/logo.svg)

## Overview

POM enables users to:
- Browse a public gallery of nature photos
- Create private collections for personal memories
- Monetize photos by setting prices and accepting donations
- Convert photos to NFTs for trading on the marketplace
- Connect Ethereum wallets for blockchain functionality

## Application Flow

### Landing Page
The landing page displays a grid of public photos. From here, users can:
- Browse the public photo gallery
- Click on individual photos to view details
- Access the login page via the login button in the top right
- Access their private gallery via the "Private" button in the top left (requires authentication)
- Access the donation/pricing page via the bag icon in the top navigation

### Authentication

#### Login Page
- Access by clicking the "Login" button in the top right of the landing page
- Enter email/phone and password
- Click "Sign In" to return to the landing page as an authenticated user
- Click "Register" to navigate to the registration page

#### Register Page
- Access by clicking the "Register" button on the login page
- Enter email/phone, password, and confirm password
- Click "Register" to create an account and navigate to the login page
- "Already have an account?" link returns to the login page

### Private Gallery
- Access by clicking the "Private" button on the landing page (authentication required)
- Displays user's private collection of photos
- Click the "+" icon to add new photos to your private collection

### Add Picture
- Access by clicking the "+" icon in the private gallery
- Upload new images to your collection
- Save your memory with the upload modal

### Donation/Pricing Page
- Access by clicking the bag icon in the top navigation
- Set prices for your photos (1$, 10$, 100$)
- Accept donations from other users

### Authentication Prompt
- Appears when an unauthenticated user attempts to interact with features requiring authentication
- Provides options to sign in or register

## Technical Architecture

### Frontend (React)
- Component-based UI architecture
- Context-based state management
- Custom hooks for authentication, gallery, and blockchain interactions
- Responsive design for various device sizes

### Backend (Internet Computer / Motoko)
- Secure authentication system
- Distributed file storage
- Smart contract integration
- NFT marketplace functionality

### Blockchain Integration (Ethereum)
- ERC-721 NFT implementation
- Marketplace smart contracts
- Ethereum wallet connection
- Token-based transactions

## Development Setup

### Prerequisites
- Node.js and npm
- Internet Computer SDK (dfx)
- Ethereum development tools (Truffle/Hardhat)
- Web3 provider (MetaMask recommended)

### Installation
```bash
# Clone the repository
git clone https://github.com/your-username/pom-platform.git
cd pom-platform

# Install dependencies
npm install

# Start the development server
npm start

# Deploy to Internet Computer
npm run deploy
```

### Smart Contract Deployment
```bash
# Deploy Ethereum contracts
cd ethereum
npx truffle migrate --network rinkeby
```

## Project Structure
The project follows a modular structure:
- `/src/frontend`: React application components, pages, and logic
- `/src/backend`: Motoko canisters for Internet Computer
- `/ethereum`: Ethereum smart contracts and configuration
- `/assets`: Static images and resources

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
[MIT](LICENSE)