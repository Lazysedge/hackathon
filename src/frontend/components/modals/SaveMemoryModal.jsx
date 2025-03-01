// src/frontend/components/modals/SaveMemoryModal.jsx
import React, { useState } from 'react';
import Modal from '../common/Modal';

const SaveMemoryModal = ({ previewUrl, onSave, onClose, loading }) => {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    onSave({ title, description });
  };

  return (
    <Modal 
      title="Save your memory" 
      onClose={onClose}
      className="save-memory-modal"
    >
      <div className="modal-body">
        <div className="memory-preview">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
            <path d="M14.5 4h-5L7 7H4a2 2 0 00-2 2v9a2 2 0 002 2h16a2 2 0 002-2V9a2 2 0 00-2-2h-3l-2.5-3z" />
            <circle cx="12" cy="13" r="3" />
          </svg>
        </div>
        
        <form className="memory-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="title" className="form-label">Title (optional)</label>
            <input
              id="title"
              type="text"
              className="form-input"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Give your memory a title"
            />
          </div>
          
          <div className="form-group mt-3">
            <label htmlFor="description" className="form-label">Description (optional)</label>
            <textarea
              id="description"
              className="form-input"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Add a description"
              rows="3"
            ></textarea>
          </div>
          
          <div className="flex justify-end mt-4">
            <button 
              type="button"
              className="btn-cancel mr-2"
              onClick={onClose}
              disabled={loading}
            >
              Cancel
            </button>
            
            <button 
              type="submit"
              className="save-button"
              disabled={loading}
            >
              {loading ? 'Saving...' : 'Save'}
            </button>
          </div>
        </form>
      </div>
    </Modal>
  );
};

export default SaveMemoryModal;