import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/common/Navbar';
import { useAuth } from '../hooks/useAuth';
import { useWallet } from '../hooks/useWallet';
import { useSmartContract } from '../hooks/useSmartContract';

const WalletPage = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const { 
    isWalletConnected, 
    connectWallet, 
    disconnectWallet, 
    account, 
    balance, 
    getBalance 
  } = useWallet();
  const { getTokenBalance, tokenBalance, loading } = useSmartContract();
  const [transactions, setTransactions] = useState([]);
  
  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login');
      return;
    }
    
    if (isWalletConnected && account) {
      getBalance(account);
      getTokenBalance(account);
      // Fetch transaction history
      fetchTransactionHistory(account);
    }
  }, [isAuthenticated, isWalletConnected, account, getBalance, getTokenBalance, navigate]);

  const fetchTransactionHistory = async (address) => {
    // Placeholder for fetching transaction history
    // In a real app, this would call an API or blockchain explorer
    setTransactions([
      { id: 1, type: 'Purchase', amount: '0.5 ETH', date: '2025-02-28', status: 'Completed' },
      { id: 2, type: 'Sale', amount: '0.3 ETH', date: '2025-02-25', status: 'Completed' },
      { id: 3, type: 'Donation', amount: '0.05 ETH', date: '2025-02-20', status: 'Completed' }
    ]);
  };

  const handleConnectWallet = async () => {
    await connectWallet();
  };

  const handleDisconnectWallet = () => {
    disconnectWallet();
  };

  return (
    <div className="wallet-page">
      <Navbar />
      
      <div className="wallet-container">
        <h1>Wallet</h1>
        
        {!isWalletConnected ? (
          <div className="connect-wallet-section">
            <p>Connect your Ethereum wallet to access blockchain features</p>
            <button 
              className="connect-wallet-button"
              onClick={handleConnectWallet}
            >
              Connect Wallet
            </button>
          </div>
        ) : (
          <div className="wallet-details">
            <div className="wallet-header">
              <h2>Wallet Details</h2>
              <button 
                className="disconnect-button"
                onClick={handleDisconnectWallet}
              >
                Disconnect
              </button>
            </div>
            
            <div className="wallet-info">
              <div className="info-item">
                <span className="label">Address:</span>
                <span className="value">{account}</span>
              </div>
              
              <div className="info-item">
                <span className="label">ETH Balance:</span>
                <span className="value">{loading ? 'Loading...' : `${balance} ETH`}</span>
              </div>
              
              <div className="info-item">
                <span className="label">POM Token Balance:</span>
                <span className="value">{loading ? 'Loading...' : `${tokenBalance} POM`}</span>
              </div>
            </div>
            
            <div className="transaction-history">
              <h2>Transaction History</h2>
              
              {transactions.length > 0 ? (
                <table className="transactions-table">
                  <thead>
                    <tr>
                      <th>Type</th>
                      <th>Amount</th>
                      <th>Date</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {transactions.map(tx => (
                      <tr key={tx.id}>
                        <td>{tx.type}</td>
                        <td>{tx.amount}</td>
                        <td>{tx.date}</td>
                        <td>{tx.status}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              ) : (
                <p>No transactions found</p>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default WalletPage;