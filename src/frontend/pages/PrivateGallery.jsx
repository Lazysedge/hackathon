import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/common/Navbar';
import ImageGrid from '../components/gallery/ImageGrid';
import { useGallery } from '../hooks/useGallery';
import { useAuth } from '../hooks/useAuth';

const PrivateGallery = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const { fetchPrivateImages, privateImages, loading } = useGallery();
  
  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login');
      return;
    }
    
    fetchPrivateImages();
  }, [isAuthenticated, fetchPrivateImages, navigate]);

  const handleAddPicture = () => {
    navigate('/add-picture');
  };

  const handleImageClick = (imageId) => {
    // Handle image selection or detail view
    console.log(`Private image ${imageId} clicked`);
  };

  return (
    <div className="private-gallery-page">
      <Navbar />
      
      <div className="gallery-header">
        <h1>Private Gallery</h1>
      </div>
      
      <div className="gallery-container">
        {loading ? (
          <div className="loading">Loading your private gallery...</div>
        ) : (
          <>
            <ImageGrid 
              images={privateImages} 
              onImageClick={handleImageClick}
            />
            
            <div 
              className="add-image-button" 
              onClick={handleAddPicture}
              style={{
                width: '150px',
                height: '150px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '48px',
                cursor: 'pointer',
                border: '2px dashed #ccc',
                margin: '10px',
                borderRadius: '8px'
              }}
            >
              <span>+</span>
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export default PrivateGallery;