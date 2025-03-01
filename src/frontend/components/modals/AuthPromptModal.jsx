// src/frontend/components/modals/AuthPromptModal.jsx
import React from 'react';
import Modal from '../common/Modal';

const AuthPromptModal = ({ onClose, onSignIn, onRegister }) => {
  return (
    <Modal 
      title="PLEASE SIGN-IN OR REGISTER FIRST" 
      onClose={onClose}
      className="auth-prompt-modal"
    >
      <div className="modal-body">
        <p>You need to be signed in to view or interact with this content.</p>
        
        <div className="modal-buttons">
          <button 
            className="auth-prompt-button sign-in-button"
            onClick={onSignIn}
          >
            Sign-In
          </button>
          
          <button 
            className="auth-prompt-button register-button"
            onClick={onRegister}
          >
            Register
          </button>
        </div>
      </div>
    </Modal>
  );
};

export default AuthPromptModal;