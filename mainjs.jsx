// App.jsx - Main application component
import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import LandingPage from './pages/LandingPage';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import PrivatePage from './pages/PrivatePage';
import AddPicturePage from './pages/AddPicturePage';
import DonoPage from './pages/DonoPage';
import { AuthProvider } from './context/AuthContext';

function App() {
  return (
    <AuthProvider>
      <Router>
        <div className="w-full min-h-screen bg-gray-900 text-white">
          <Routes>
            <Route path="/" element={<LandingPage />} />
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegisterPage />} />
            <Route 
              path="/private" 
              element={
                <ProtectedRoute>
                  <PrivatePage />
                </ProtectedRoute>
              } 
            />
            <Route 
              path="/add-picture" 
              element={
                <ProtectedRoute>
                  <AddPicturePage />
                </ProtectedRoute>
              } 
            />
            <Route path="/dono" element={<DonoPage />} />
          </Routes>
        </div>
      </Router>
    </AuthProvider>
  );
}

// Protected route component for authenticated routes
function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth();
  return isAuthenticated ? children : <Navigate to="/login" />;
}

export default App;