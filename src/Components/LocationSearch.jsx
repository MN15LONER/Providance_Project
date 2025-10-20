import React, { useState } from 'react';
import WeatherCard from './WeatherCard';

export default function LocationSearch() {
  const [location, setLocation] = useState('');
  const [weatherData, setWeatherData] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const API_KEY = "09f0c3944d00dbfd1dca1279e7b45eaf";

  const f1Circuits = [
    'Monaco', 'Silverstone', 'Monza', 'Spa', 'Suzuka', 'Barcelona', 
    'Melbourne', 'Austin', 'Miami', 'Las Vegas', 'Singapore', 'Abu Dhabi'
  ];

  const handleSearch = async () => {
    if (!location.trim()) return;
    
    setLoading(true);
    setError('');
    
    try {
      const res = await fetch(
        `https://api.openweathermap.org/data/2.5/weather?q=${location}&appid=${API_KEY}&units=metric`
      );
      if (!res.ok) throw new Error("Location not found.");
      const data = await res.json();
      setWeatherData(data);
    } catch (err) {
      setWeatherData(null);
      setError("Could not fetch weather data. Please try a valid city name.");
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter') {
      handleSearch();
    }
  };

  return (
    <div className="location-search-container">
      <div className="search-wrapper">
        <div className="search-header">
          <h2>
            Check Race <span className="search-title-accent">Conditions</span>
          </h2>
          <p>
            Get real-time weather data for any F1 circuit or city around the world
          </p>
        </div>

        <div className="search-card">
          <div className="search-input-container">
            <div className="search-input-wrapper">
              <input
                type="text"
                placeholder="Enter F1 circuit or city (e.g., Monaco, Silverstone...)"
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                onKeyPress={handleKeyPress}
                className="search-box"
                disabled={loading}
              />
              {loading && (
                <div className="loading-spinner">
                  <div className="spinner"></div>
                </div>
              )}
            </div>
            <button
              onClick={handleSearch}
              disabled={loading || !location.trim()}
              className="search-btn"
            >
              {loading ? 'Searching...' : 'Get Weather'}
            </button>
          </div>

          <div className="circuits-section">
            <p className="circuits-label">Quick select popular F1 circuits:</p>
            <div className="circuits-grid">
              {f1Circuits.map((circuit) => (
                <button
                  key={circuit}
                  onClick={() => setLocation(circuit)}
                  className="circuit-btn"
                >
                  {circuit}
                </button>
              ))}
            </div>
          </div>

          {error && (
            <div className="error-text">
              <p>{error}</p>
            </div>
          )}
        </div>

        {weatherData && (
          <WeatherCard weather={weatherData} />
        )}
      </div>
    </div>
  );
}
