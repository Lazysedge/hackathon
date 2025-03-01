import React from 'react';
import { useNavigate } from 'react-router-dom';
import LoginForm from '../components/auth/LoginForm';
import { useAuth } from '../hooks/useAuth';

const LoginPage = () => {
  const navigate = useNavigate();
  const { login, loading, error } = useAuth();

  const handleLogin = async (credentials) => {
    const success = await login(credentials);
    if (success) {
      navigate('/');
    }
  };

  const handleRegisterClick = () => {
    navigate('/register');
  };

  return (
    <div className="auth-page" style={{ 
      backgroundImage: "url('/assets/images/mountain-lake.jpg')",
      backgroundSize: 'cover',
      backgroundPosition: 'center',
      height: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }}>
      <div className="auth-container">
        <h1 className="auth-title">Sign In</h1>
        
        {error && <div className="auth-error">{error}</div>}
        
        <LoginForm 
          onSubmit={handleLogin} 
          loading={loading} 
        />
        
        <div className="auth-footer">
          <button 
            className="register-link" 
            onClick={handleRegisterClick}
          >
            Register
          </button>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;