<script setup>
// This is a static component to explain the scoring rules.
</script>

<template>
  <div class="bonus-info-container">
    <h2>Scoring Rules</h2>
    <p>Maximize your score by combining rarity and synergy!</p>

    <div class="rules-grid">
      <!-- Base Score -->
      <div class="rule-card">
        <h3>Base Score</h3>
        <ul>
          <li><strong>+100</strong> points for each pin that matches its slot requirement.</li>
        </ul>
      </div>

      <!-- Rarity Bonus -->
      <div class="rule-card">
        <h3>Rarity Bonus</h3>
        <ul>
          <li><strong>+150</strong> points for any "Chaser" pin.</li>
          <li><strong>+50</strong> points for any "Limited Edition" pin.</li>
        </ul>
      </div>

      <!-- Synergy Bonus -->
      <div class="rule-card">
        <h3>Synergy Bonus (per submission)</h3>
        <ul>
          <li><strong>Franchise Pair:</strong> +75 points</li>
          <li><strong>Franchise Trio:</strong> +200 points</li>
          <li><strong>Studio Pair:</strong> +40 points</li>
          <li><strong>Studio Trio:</strong> +100 points</li>
          <li><strong>Material Pair:</strong> +50 points</li>
          <li><strong>Material Trio:</strong> +125 points</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<style scoped>
.bonus-info-container {
  background-color: var(--vt-c-black-soft);
  border: 1px solid var(--vt-c-divider-dark-2);
  padding: 2rem;
  border-radius: 16px;
  margin-top: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
}
.bonus-info-container h2 {
  color: var(--vt-c-text-dark-1);
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
  border-bottom: 1px solid var(--vt-c-divider-dark-1);
  padding-bottom: 0.5rem;
}
.bonus-info-container > p {
  font-size: 1.1rem;
  color: var(--vt-c-text-dark-2);
  margin-bottom: 1.5rem;
}

.rules-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.rule-card {
  background-color: var(--vt-c-black-mute);
  padding: 1.5rem;
  border-radius: 10px;
  border: 1px solid var(--vt-c-divider-dark-2);
}

.rule-card h3 {
  color: var(--vt-c-white);
  font-size: 1.2rem;
  margin-bottom: 1rem;
}

.rule-card ul {
  padding-left: 20px;
  margin: 0;
}

.rule-card li {
  font-size: 1rem;
  color: var(--vt-c-text-dark-1);
  margin-bottom: 0.5rem;
}

.rule-card li strong {
  color: var(--vt-c-indigo);
}
</style>