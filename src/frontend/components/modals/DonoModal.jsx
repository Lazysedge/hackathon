// src/frontend/components/modals/DonoModal.jsx
import React, { useState } from 'react';
import Modal from '../common/Modal';

const DonoModal = ({ image, onClose, onSetPrice, initialPrice = 0 }) => {
  const [price, setPrice] = useState(initialPrice);
  const [selectedPreset, setSelectedPreset] = useState(null);

  const presetPrices = [5, 10, 100];

  const handlePresetClick = (preset) => {
    setPrice(preset);
    setSelectedPreset(preset);
  };

  const handlePriceChange = (e) => {
    const value = parseFloat(e.target.value);
    setPrice(value);
    setSelectedPreset(null);
  };

  const handleSubmit = () => {
    onSetPrice(price);
  };

  return (
    <Modal 
      title="Donation" 
      onClose={onClose}
      className="dono-modal"
    >
      <div className="modal-body">
        <h4 className="text-center mb-2">Price</h4>
        
        <div className="price-selector">
          {presetPrices.map(preset => (
            <div 
              key={preset}
              className={`price-option ${selectedPreset === preset ? 'selected' : ''}`}
              onClick={() => handlePresetClick(preset)}
            >
              ${preset}
            </div>
          ))}
          
          <span className="mx-2">or</span>
          
          <input
            type="number"
            className="price-input"
            value={price}
            onChange={handlePriceChange}
            min="0"
            step="0.01"
          />
        </div>
        
        <div className="text-center mt-4">
          <button 
            className="dono-button"
            onClick={handleSubmit}
          >
            Done
          </button>
        </div>
      </div>
    </Modal>
  );
};

export default DonoModal;