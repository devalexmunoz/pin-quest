<script setup>
// This is a static component.
</script>

<template>
  <div class="landing-page">
    <div class="hero">
      <h2>Give Your Pins a New Purpose.</h2>
      <p class="subtitle">
        Welcome to <strong>Pinnacle PinQuest</strong>, the daily on-chain challenge for collectors.
      </p>
    </div>

    <div class="how-to-play">
      <h3>How It Works</h3>
      <ol>
        <li>
          <span>1</span>
          <strong>Connect Your Wallet</strong>
          <p>Link your Flow wallet that holds your Pinnacle Pins.</p>
        </li>
        <li>
          <span>2</span>
          <strong>Complete the Daily Quest</strong>
          <p>Analyze the 3 daily requirements and select your best pins to match.</p>
        </li>
        <li>
          <span>3</span>
          <strong>Climb the Leaderboard</strong>
          <p>Submit your quest to earn a score based on rarity and synergy!</p>
        </li>
      </ol>
    </div>

    <div class="connect-prompt">
      <h3>Your Quest Awaits.</h3>
      <p>Connect your wallet to begin.</p>
    </div>
  </div>
</template>

<style scoped>
.landing-page {
  text-align: center;
  color: var(--vt-c-text-dark-1);
}
.hero {
  padding: 3rem 1rem 2rem 1rem;
  background-color: var(--vt-c-black-soft);
  border-radius: 16px;
  border: 1px solid var(--vt-c-divider-dark-2);
}
.hero h2 {
  font-size: 2.8rem;
  font-weight: 700;
  color: var(--vt-c-white-soft);
}
.hero .subtitle {
  font-size: 1.25rem;
  color: var(--vt-c-text-dark-2);
  margin-top: 0.5rem;
}
.hero .subtitle strong {
  color: var(--vt-c-accent);
  font-weight: 600;
}

.how-to-play {
  margin-top: 3rem;
  padding: 2rem;
}
.how-to-play h3 {
  font-size: 2rem;
  font-weight: 600;
  margin-bottom: 3rem;
  color: var(--vt-c-white-soft);
}
.how-to-play ol {
  list-style: none;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2.5rem;
  max-width: 1000px;
  margin: 0 auto;
}
.how-to-play li {
  font-size: 1rem;
  color: var(--vt-c-text-dark-2);
  background-color: var(--vt-c-black-soft);
  padding: 2rem 1.5rem;
  border-radius: 12px;
  border: 1px solid var(--vt-c-divider-dark-2);
}
.how-to-play li span {
  display: block;
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--vt-c-green);
  margin-bottom: 1rem;
  border: 2px solid var(--vt-c-green);
  width: 40px;
  height: 40px;
  line-height: 36px;
  border-radius: 50%;
  margin: 0 auto 1.5rem;
}
.how-to-play li strong {
  display: block;
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--vt-c-white-soft);
  margin-bottom: 0.5rem;
}

.connect-prompt {
  margin-top: 3rem;
  padding: 2rem;
  background-color: var(--vt-c-black-mute);
  border-radius: 12px;
}
.connect-prompt h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--vt-c-white-soft);
}
.connect-prompt p {
  font-size: 1.2rem;
  color: var(--vt-c-yellow);
  margin-top: 0.5rem;
}
</style>