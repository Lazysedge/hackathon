import React from 'react';
import { useNavigate } from 'react-router-dom';
import RegisterForm from '../components/auth/RegisterForm';
import { useAuth } from '../hooks/useAuth';

const RegisterPage = () => {
  const navigate = useNavigate();
  const { register, loading, error } = useAuth();

  const handleRegister = async (userData) => {
    const success = await register(userData);
    if (success) {
      navigate('/login');
    }
  };

  const handleLoginClick = () => {
    navigate('/login');
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
        <h1 className="auth-title">Register</h1>
        
        {error && <div className="auth-error">{error}</div>}
        
        <RegisterForm 
          onSubmit={handleRegister} 
          loading={loading} 
        />
        
        <div className="auth-footer">
          <p>Already have an account?</p>
          <button 
            className="login-link" 
            onClick={handleLoginClick}
          >
            Sign In
          </button>
        </div>
      </div>
    </div>
  );
};

export default RegisterPage;