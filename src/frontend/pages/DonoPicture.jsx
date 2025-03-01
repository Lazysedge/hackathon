import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import Navbar from '../components/common/Navbar';
import DonoModal from '../components/modals/DonoModal';
import { useGallery } from '../hooks/useGallery';
import { useAuth } from '../hooks/useAuth';
import { useWallet } from '../hooks/useWallet';
import { useSmartContract } from '../hooks/useSmartContract';

const DonoPicture = () => {
  const { imageId } = useParams();
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const { getImageById, loading: galleryLoading, error } = useGallery();
  const { isWalletConnected, connectWallet } = useWallet();
  const { mintNFT, loading: contractLoading } = useSmartContract();
  
  const [image, setImage] = useState(null);
  const [showDonoModal, setShowDonoModal] = useState(false);
  const [priceSet, setPriceSet] = useState(false);

  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login');
      return;
    }

    const fetchImage = async () => {
      const imageData = await getImageById(imageId);
      if (imageData) {
        setImage(imageData);
        setPriceSet(imageData.price > 0);
      } else {
        // Image not found or not accessible
        navigate('/dono');
      }
    };

    fetchImage();
  }, [isAuthenticated, imageId, getImageById, navigate]);

  const handleShowDonoModal = () => {
    setShowDonoModal(true);
  };

  const handleCloseDonoModal = () => {
    setShowDonoModal(false);
  };

  const handleSetPrice = async (price) => {
    if (!isWalletConnected) {
      const connected = await connectWallet();
      if (!connected) return;
    }
    
    try {
      // Update image price in backend
      // This would typically involve a service call
      console.log(`Setting price ${price} for image ${imageId}`);
      
      // Update local state
      setImage(prevImage => ({
        ...prevImage,
        price: price
      }));
      
      setPriceSet(true);
      setShowDonoModal(false);
    } catch (err) {
      console.error("Error setting price:", err);
    }
  };

  const handleMintNFT = async () => {
    if (!isWalletConnected) {
      const connected = await connectWallet();
      if (!connected) return;
    }
    
    try {
      await mintNFT(image);
      navigate('/nft-gallery');
    } catch (err) {
      console.error("Error minting NFT:", err);
    }
  };

  if (galleryLoading || !image) {
    return (
      <div className="dono-picture-page">
        <Navbar />
        <div className="loading-container">
          <div className="loading">Loading image details...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="dono-picture-page">
      <Navbar />
      
      <div className="dono-picture-container">
        <div className="dono-picture-header">
          <h1>Donation Settings</h1>
          <button 
            className="back-button"
            onClick={() => navigate('/dono')}
          >
            Back to Gallery
          </button>
        </div>
        
        {error && <div className="error-message">{error}</div>}
        
        <div className="image-details">
          <div className="image-preview">
            <img src={image.url} alt={image.title || 'Image'} />
          </div>
          
          <div className="image-info">
            <h2>{image.title || 'Untitled'}</h2>
            {image.description && <p>{image.description}</p>}
            
            <div className="price-section">
              {priceSet ? (
                <>
                  <div className="current-price">
                    <span className="price-label">Current Price:</span>
                    <span className="price-value">${image.price}</span>
                  </div>
                  <button 
                    className="change-price-button"
                    onClick={handleShowDonoModal}
                  >
                    Change Price
                  </button>
                </>
              ) : (
                <button 
                  className="set-price-button"
                  onClick={handleShowDonoModal}
                >
                  Set Price
                </button>
              )}
            </div>
            
            <div className="nft-section">
              <h3>Convert to NFT</h3>
              <p>Make this image available as an NFT on the marketplace</p>
              <button 
                className="mint-nft-button"
                onClick={handleMintNFT}
                disabled={contractLoading || !priceSet}
              >
                {contractLoading ? 'Processing...' : 'Mint as NFT'}
              </button>
              {!priceSet && (
                <p className="nft-warning">
                  You must set a price before minting as NFT
                </p>
              )}
            </div>
          </div>
        </div>
      </div>
      
      {showDonoModal && (
        <DonoModal
          image={image}
          onClose={handleCloseDonoModal}
          onSetPrice={handleSetPrice}
          initialPrice={image.price || 0}
        />
      )}
    </div>
  );
};

export default DonoPicture;