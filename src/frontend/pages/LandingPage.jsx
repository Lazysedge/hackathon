import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import ImageGrid from '../components/gallery/ImageGrid';
import Navbar from '../components/common/Navbar';
import { useGallery } from '../hooks/useGallery';
import AuthPromptModal from '../components/modals/AuthPromptModal';
import { useAuth } from '../hooks/useAuth';

const LandingPage = () => {
  const navigate = useNavigate();
  const { fetchPublicImages, publicImages, loading } = useGallery();
  const { isAuthenticated } = useAuth();
  const [showAuthPrompt, setShowAuthPrompt] = useState(false);

  useEffect(() => {
    fetchPublicImages();
  }, [fetchPublicImages]);

  const handleImageClick = (imageId) => {
    if (!isAuthenticated) {
      setShowAuthPrompt(true);
    } else {
      // Navigate to image details or handle interaction
      console.log(`Image ${imageId} clicked`);
    }
  };

  const handleCloseAuthPrompt = () => {
    setShowAuthPrompt(false);
  };

  const handleNavigateToLogin = () => {
    navigate('/login');
    setShowAuthPrompt(false);
  };

  const handleNavigateToRegister = () => {
    navigate('/register');
    setShowAuthPrompt(false);
  };

  return (
    <div className="landing-page">
      <Navbar />
      
      <div className="gallery-container">
        {loading ? (
          <div className="loading">Loading gallery...</div>
        ) : (
          <ImageGrid 
            images={publicImages} 
            onImageClick={handleImageClick}
          />
        )}
      </div>

      {showAuthPrompt && (
        <AuthPromptModal 
          onClose={handleCloseAuthPrompt}
          onSignIn={handleNavigateToLogin}
          onRegister={handleNavigateToRegister}
        />
      )}
    </div>
  );
};

export default LandingPage;