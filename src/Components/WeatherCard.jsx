import React from 'react';

export default function WeatherCard({ weather }) {
  const getWeatherIcon = (condition) => {
    const icons = {
      'Clear': '☀️',
      'Clouds': '☁️',
      'Rain': '🌧️',
      'Drizzle': '🌦️',
      'Thunderstorm': '⛈️',
      'Snow': '❄️',
      'Mist': '🌫️',
      'Fog': '🌫️'
    };
    return icons[condition] || '🌤️';
  };

  const getRaceConditions = (temp, condition) => {
    if (condition.includes('Rain') || condition.includes('Thunderstorm')) {
      return { status: 'Wet Race Conditions', className: 'wet' };
    } else if (temp > 30) {
      return { status: 'Hot Track Conditions', className: 'hot' };
    } else if (temp < 10) {
      return { status: 'Cold Track Conditions', className: 'cold' };
    } else {
      return { status: 'Optimal Race Conditions', className: 'optimal' };
    }
  };

  const conditions = getRaceConditions(weather.main.temp, weather.weather[0].main);

  return (
    <div className="weather-card">
      <div className="weather-header">
        <div className="weather-location">
          <h2>{weather.name}</h2>
          <p className="weather-country">{weather.sys.country}</p>
        </div>
        <div className="weather-icon">
          {getWeatherIcon(weather.weather[0].main)}
        </div>
      </div>

      <div className="weather-main-stats">
        <div className="temperature-display">
          <p className="temperature-value">{Math.round(weather.main.temp)}°</p>
          <p className="temperature-label">Temperature</p>
        </div>
        <div className="condition-display">
          <p className="condition-main">{weather.weather[0].main}</p>
          <p className="condition-description">{weather.weather[0].description}</p>
        </div>
      </div>

      <div className={`race-conditions ${conditions.className}`}>
        <p className="race-status">{conditions.status}</p>
      </div>

      <div className="weather-details">
        <div className="detail-item">
          <p className="detail-value">{Math.round(weather.main.feels_like)}°</p>
          <p className="detail-label">Feels like</p>
        </div>
        <div className="detail-item">
          <p className="detail-value">{weather.main.humidity}%</p>
          <p className="detail-label">Humidity</p>
        </div>
        <div className="detail-item">
          <p className="detail-value">{weather.wind.speed} m/s</p>
          <p className="detail-label">Wind</p>
        </div>
      </div>
    </div>
  );
}