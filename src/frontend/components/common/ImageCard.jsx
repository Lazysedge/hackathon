// src/frontend/components/common/ImageCard.jsx
import React from 'react';

const ImageCard = ({ image, onImageClick, showActions = true }) => {
  const handleClick = () => {
    if (onImageClick) {
      onImageClick(image.id);
    }
  };

  const handleLikeClick = (e) => {
    e.stopPropagation(); // Prevent triggering the card click
    // Handle like functionality
    console.log(`Liked image ${image.id}`);
  };

  const handleInfoClick = (e) => {
    e.stopPropagation(); // Prevent triggering the card click
    // Handle info functionality
    console.log(`Info for image ${image.id}`);
  };

  return (
    <div 
      className="image-card"
      onClick={handleClick}
    >
      <img 
        src={image.url} 
        alt={image.title || 'Image'} 
        className="card-image"
      />
      
      {showActions && (
        <div className="image-actions">
          <button 
            className="image-action-button like-button"
            onClick={handleLikeClick}
            aria-label="Like"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
            </svg>
          </button>
          
          <button 
            className="image-action-button info-button"
            onClick={handleInfoClick}
            aria-label="Info"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="12" cy="12" r="10"></circle>
              <line x1="12" y1="16" x2="12" y2="12"></line>
              <line x1="12" y1="8" x2="12.01" y2="8"></line>
            </svg>
          </button>
        </div>
      )}
    </div>
  );
};

export default ImageCard;