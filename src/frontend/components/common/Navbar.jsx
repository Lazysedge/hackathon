// src/frontend/components/common/Navbar.jsx
import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';

const Navbar = () => {
  const navigate = useNavigate();
  const { isAuthenticated, logout } = useAuth();

  const handleLogin = () => {
    navigate('/login');
  };

  const handlePrivateClick = () => {
    if (isAuthenticated) {
      navigate('/private');
    } else {
      navigate('/login');
    }
  };

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  return (
    <nav className="navbar">
      <Link to="/" className="navbar-logo">
        <span>POM</span>
        <span className="private-tag">Private</span>
      </Link>
      
      <div className="navbar-links">
        {isAuthenticated ? (
          <>
            <button 
              onClick={handlePrivateClick}
              className="nav-button private-button"
            >
              Private
            </button>
            <button 
              onClick={handleLogout}
              className="nav-button logout-button"
            >
              Logout
            </button>
          </>
        ) : (
          <button 
            onClick={handleLogin}
            className="nav-button login-button"
          >
            Login
          </button>
        )}
      </div>
    </nav>
  );
};

export default Navbar;