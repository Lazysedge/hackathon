import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/common/Navbar';
import ImageUpload from '../components/gallery/ImageUpload';
import SaveMemoryModal from '../components/modals/SaveMemoryModal';
import { useGallery } from '../hooks/useGallery';
import { useAuth } from '../hooks/useAuth';

const AddPicture = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const { uploadImage, loading, error } = useGallery();
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewUrl, setPreviewUrl] = useState(null);
  const [showSaveModal, setShowSaveModal] = useState(false);
  
  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login');
    }
  }, [isAuthenticated, navigate]);

  const handleFileSelect = (file) => {
    setSelectedFile(file);
    
    // Create preview URL
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreviewUrl(reader.result);
        setShowSaveModal(true);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSaveMemory = async (metadata) => {
    if (!selectedFile) return;
    
    const formData = new FormData();
    formData.append('image', selectedFile);
    formData.append('title', metadata.title || 'Untitled');
    formData.append('description', metadata.description || '');
    formData.append('isPrivate', true);
    
    const success = await uploadImage(formData);
    if (success) {
      setShowSaveModal(false);
      navigate('/private');
    }
  };

  const handleCloseModal = () => {
    setShowSaveModal(false);
    setSelectedFile(null);
    setPreviewUrl(null);
  };

  return (
    <div className="add-picture-page">
      <Navbar />
      
      <div className="upload-container">
        <h1>Add a New Memory</h1>
        
        {error && <div className="upload-error">{error}</div>}
        
        <ImageUpload 
          onFileSelect={handleFileSelect}
          loading={loading}
        />
        
        {previewUrl && (
          <div className="image-preview">
            <img src={previewUrl} alt="Preview" />
          </div>
        )}
      </div>
      
      {showSaveModal && (
        <SaveMemoryModal
          previewUrl={previewUrl}
          onSave={handleSaveMemory}
          onClose={handleCloseModal}
          loading={loading}
        />
      )}
    </div>
  );
};

export default AddPicture;