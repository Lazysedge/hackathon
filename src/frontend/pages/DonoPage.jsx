import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/common/Navbar';
import ImageGrid from '../components/gallery/ImageGrid';
import DonoModal from '../components/modals/DonoModal';
import { useGallery } from '../hooks/useGallery';
import { useAuth } from '../hooks/useAuth';
import { useWallet } from '../hooks/useWallet';

const DonoPage = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const { fetchUserImages, userImages, loading } = useGallery();
  const { isWalletConnected, connectWallet } = useWallet();
  const [selectedImage, setSelectedImage] = useState(null);
  const [showDonoModal, setShowDonoModal] = useState(false);
  
  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login');
      return;
    }
    
    fetchUserImages();
  }, [isAuthenticated, fetchUserImages, navigate]);

  const handleImageClick = (imageId) => {
    const image = userImages.find(img => img.id === imageId);
    if (image) {
      setSelectedImage(image);
      setShowDonoModal(true);
    }
  };

  const handleCloseDonoModal = () => {
    setShowDonoModal(false);
    setSelectedImage(null);
  };

  const handleSetPrice = async (price) => {
    if (!isWalletConnected) {
      const connected = await connectWallet();
      if (!connected) return;
    }
    
    // Logic to set price for the selected image
    console.log(`Setting price ${price} for image ${selectedImage.id}`);
    
    setShowDonoModal(false);
    setSelectedImage(null);
  };

  return (
    <div className="dono-page">
      <Navbar />
      
      <div className="dono-header">
        <h1>Set Prices and Accept Donations</h1>
        <p>Choose an image to set its price or accept donations</p>
      </div>
      
      <div className="gallery-container">
        {loading ? (
          <div className="loading">Loading your images...</div>
        ) : (
          <ImageGrid 
            images={userImages} 
            onImageClick={handleImageClick}
          />
        )}
      </div>
      
      {showDonoModal && selectedImage && (
        <DonoModal
          image={selectedImage}
          onClose={handleCloseDonoModal}
          onSetPrice={handleSetPrice}
        />
      )}
    </div>
  );
};

export default DonoPage;