import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/common/Navbar';
import { useAuth } from '../hooks/useAuth';
import { useWallet } from '../hooks/useWallet';
import { useSmartContract } from '../hooks/useSmartContract';

const NFTGallery = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const { isWalletConnected, connectWallet, account } = useWallet();
  const { fetchUserNFTs, fetchMarketplaceNFTs, userNFTs, marketplaceNFTs, loading } = useSmartContract();
  const [activeTab, setActiveTab] = useState('owned');
  
  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login');
      return;
    }
    
    if (!isWalletConnected) {
      // Prompt to connect wallet
      return;
    }
    
    if (activeTab === 'owned') {
      fetchUserNFTs(account);
    } else {
      fetchMarketplaceNFTs();
    }
  }, [isAuthenticated, isWalletConnected, activeTab, account, fetchUserNFTs, fetchMarketplaceNFTs, navigate]);

  const handleConnectWallet = async () => {
    await connectWallet();
  };

  const handleTabChange = (tab) => {
    setActiveTab(tab);
  };

  const handleBuyNFT = async (nftId, price) => {
    // Logic to purchase NFT
    console.log(`Buying NFT ${nftId} for ${price}`);
  };

  const handleSellNFT = (nftId) => {
    // Logic to list NFT for sale
    console.log(`Selling NFT ${nftId}`);
  };

  return (
    <div className="nft-gallery-page">
      <Navbar />
      
      <div className="nft-header">
        <h1>NFT Gallery</h1>
        
        {!isWalletConnected ? (
          <div className="wallet-connect-container">
            <p>Connect your wallet to view and trade NFTs</p>
            <button 
              className="connect-wallet-button"
              onClick={handleConnectWallet}
            >
              Connect Wallet
            </button>
          </div>
        ) : (
          <>
            <div className="wallet-info">
              <p>Connected: {account.substring(0, 6)}...{account.substring(account.length - 4)}</p>
            </div>
            
            <div className="nft-tabs">
              <button 
                className={`tab ${activeTab === 'owned' ? 'active' : ''}`}
                onClick={() => handleTabChange('owned')}
              >
                My NFTs
              </button>
              <button 
                className={`tab ${activeTab === 'marketplace' ? 'active' : ''}`}
                onClick={() => handleTabChange('marketplace')}
              >
                Marketplace
              </button>
            </div>
            
            <div className="nft-grid">
              {loading ? (
                <div className="loading">Loading NFTs...</div>
              ) : activeTab === 'owned' ? (
                userNFTs.length > 0 ? (
                  userNFTs.map(nft => (
                    <div key={nft.id} className="nft-card">
                      <img src={nft.imageUrl} alt={nft.name} />
                      <div className="nft-info">
                        <h3>{nft.name}</h3>
                        <button 
                          className="sell-button"
                          onClick={() => handleSellNFT(nft.id)}
                        >
                          List for Sale
                        </button>
                      </div>
                    </div>
                  ))
                ) : (
                  <p>You don't own any NFTs yet</p>
                )
              ) : (
                marketplaceNFTs.length > 0 ? (
                  marketplaceNFTs.map(nft => (
                    <div key={nft.id} className="nft-card">
                      <img src={nft.imageUrl} alt={nft.name} />
                      <div className="nft-info">
                        <h3>{nft.name}</h3>
                        <p>Price: {nft.price} ETH</p>
                        <button 
                          className="buy-button"
                          onClick={() => handleBuyNFT(nft.id, nft.price)}
                        >
                          Buy Now
                        </button>
                      </div>
                    </div>
                  ))
                ) : (
                  <p>No NFTs available for purchase</p>
                )
              )}
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export default NFTGallery;