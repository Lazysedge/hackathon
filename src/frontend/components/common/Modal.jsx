// src/frontend/components/common/Modal.jsx
import React, { useEffect } from 'react';

const Modal = ({ title, children, onClose, className = '' }) => {
  // Close on escape key press
  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape') onClose();
    };
    
    document.addEventListener('keydown', handleEscape);
    return () => document.removeEventListener('keydown', handleEscape);
  }, [onClose]);

  // Prevent body scrolling when modal is open
  useEffect(() => {
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = 'auto';
    };
  }, []);

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div 
        className={`modal-container ${className}`}
        onClick={(e) => e.stopPropagation()} // Prevent closing when clicking modal content
      >
        <div className="modal-header">
          <h3 className="modal-title">{title}</h3>
          <button 
            className="modal-close"
            onClick={onClose}
            aria-label="Close"
          >
            <span className="text-2xl">&times;</span>
          </button>
        </div>
        
        {children}
      </div>
    </div>
  );
};

export default Modal;