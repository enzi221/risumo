---
ableFlag: true
comment: StatsDp
flag: gm
type: editdisplay
---

IN:
^\[stats\|(?<date>[^|]+)\|(?<time>[^|]+)\|(?<weather>[^|]+)\|(?<loc>[^|]+)\|(?<outfit>[^|]+?)\]
OUT:
{{#when::{{getvar::astarot-stats}}::is::1}}
{{#when::{{? {{chat_index}} > {{? {{lastmessageid}}-10}}}}}}
<div class="astarot-status-container">
  <div class="astarot-status-grid">
    <div class="astarot-status-row">
      <div class="astarot-status-item">
        <div class="astarot-status-icon-wrapper">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
            <line x1="16" y1="2" x2="16" y2="6"></line>
            <line x1="8" y1="2" x2="8" y2="6"></line>
            <line x1="3" y1="10" x2="21" y2="10"></line>
          </svg>
        </div>
        <div class="astarot-status-content">
          <span class="astarot-status-label">Date</span>
          <span class="astarot-status-value">$<date></span>
        </div>
      </div>
      <div class="astarot-status-item">
        <div class="astarot-status-icon-wrapper">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <circle cx="12" cy="12" r="5"></circle>
            <line x1="12" y1="1" x2="12" y2="3"></line>
            <line x1="12" y1="21" x2="12" y2="23"></line>
            <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
            <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
            <line x1="1" y1="12" x2="3" y2="12"></line>
            <line x1="21" y1="12" x2="23" y2="12"></line>
            <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
            <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
          </svg>
        </div>
        <div class="astarot-status-content">
          <span class="astarot-status-label">Time</span>
          <span class="astarot-status-value">$<time></span>
        </div>
      </div>
    </div>
    <div class="astarot-status-row">
      <div class="astarot-status-item">
        <div class="astarot-status-icon-wrapper">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <path d="M12 2v2"></path>
            <path d="m4.93 4.93 1.41 1.41"></path>
            <path d="M20 12h2"></path>
            <path d="m19.07 4.93-1.41 1.41"></path>
            <path d="M15.947 12.65a4 4 0 0 0-5.925-4.128"></path>
            <path d="M13 22H7a5 5 0 1 1 4.9-6H13a3 3 0 0 1 0 6Z"></path>
          </svg>
        </div>
        <div class="astarot-status-content">
          <span class="astarot-status-label">Weather</span>
          <span class="astarot-status-value">$<weather></span>
        </div>
      </div>
      <div class="astarot-status-item">
        <div class="astarot-status-icon-wrapper">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0Z"></path>
            <circle cx="12" cy="10" r="3"></circle>
          </svg>
        </div>
        <div class="astarot-status-content">
          <span class="astarot-status-label">Location</span>
          <span class="astarot-status-value">$<loc></span>
        </div>
      </div>
    </div>
    <div class="astarot-status-row">
      <div class="astarot-status-item">
        <div class="astarot-status-content">
          <span class="astarot-status-label">Outfit</span>
          <span class="astarot-status-value">$<outfit></span>
        </div>
      </div>
    </div>
  </div>
</div>
{{/when}}
<style>
.astarot-status-container {
  --primary-gold: #cbb69b;
  --primary-gold-dim: #8a7b66;
  --text-color: #f0e6d2;
  --panel-bg: #1a1625;
  --panel-bg-lighter: #252033;
  --border-color: #3a324b;
  --accent-glow: rgba(203, 182, 155, 0.15);

  background: var(--panel-bg);
  border-radius: 12px;
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.7), 0 0 0 1px var(--border-color) inset;
  width: 100%;
  margin: auto;
  max-width: 600px;
  padding: 24px;
  position: relative;
  overflow: hidden;
  font-family: 'Cinzel', serif;
  color: var(--text-color);
}

.astarot-status-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 3px;
  background: linear-gradient(90deg, transparent, var(--primary-gold), transparent);
  opacity: 0.7;
}

.astarot-status-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

.astarot-status-row {
  display: flex;
  gap: 16px;
}

.astarot-status-item {
  background: rgba(0, 0, 0, 0.2);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  position: relative;
  overflow: hidden;
}

.astarot-status-item::after {
  content: '';
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  width: 2px;
  background: linear-gradient(to bottom, transparent, var(--primary-gold-dim), transparent);
  opacity: 0.3;
}

.astarot-status-icon-wrapper {
  color: var(--primary-gold);
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  filter: drop-shadow(0 0 5px rgba(203, 182, 155, 0.4));
}
        
.astarot-status-icon-wrapper svg {
  width: 20px;
  height: 20px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  fill: none;
}

.astarot-status-content {
  display: flex;
  flex-direction: column;
  width: 100%;
}

.astarot-status-label {
  font-size: 0.7rem;
  color: #8a8199;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 2px;
}

.astarot-status-value {
  font-size: 0.95rem;
  color: var(--text-color);
  font-weight: 500;
  letter-spacing: 0.5px;
  text-transform: capitalize;
}
</style>
{{/when}}
