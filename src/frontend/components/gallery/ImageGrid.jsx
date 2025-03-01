// src/frontend/components/gallery/ImageGrid.jsx
import React from 'react';
import ImageCard from '../common/ImageCard';

const ImageGrid = ({ images, onImageClick, emptyMessage = "No images available" }) => {
  if (!images || images.length === 0) {
    return (
      <div className="empty-gallery">
        <p>{emptyMessage}</p>
      </div>
    );
  }

  return (
    <div className="image-grid">
      {images.map(image => (
        <ImageCard 
          key={image.id} 
          image={image} 
          onImageClick={onImageClick} 
        />
      ))}
    </div>
  );
};

export default ImageGrid;