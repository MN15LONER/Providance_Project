import React from 'react';
import '../index.css';

export default function Hero() {
  return (
    <div className="hero-container">
      <div className="absolute inset-0 w-full h-full">
        <video 
          autoPlay 
          loop 
          muted 
          className="bg-video"
        >
          <source src="/Lewis Absolutely FLEW!.mp4" type="video/mp4"/>
          Your browser does not support the video tag.
        </video>
      </div>

      <div className="overlay"></div>

      <div className="hero-content">
        <h1>
          Weather-Ready
          <span className="hero-title-accent">F1 Viewing</span>
        </h1>
        <p>
          Track forecasts. Plan race days. Stay ahead of the storm.
        </p>
        <div className="hero-buttons">
          <button className="cta-btn">
            Explore Conditions
          </button>
          <button className="cta-btn-secondary">
            Live Updates
          </button>
        </div>
      </div>

      <div className="scroll-indicator">
        <div className="scroll-mouse">
          <div className="scroll-dot"></div>
        </div>
      </div>
    </div>
  );
}
