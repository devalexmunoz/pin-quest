<script setup>
import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useLeaderboardStore } from '../stores/leaderboard'

const leaderboardStore = useLeaderboardStore()
const { leaderboard, isLoading } = storeToRefs(leaderboardStore)

// The leaderboard state is a dictionary { "0xADDRESS": "300" }
// We need to convert it into a sorted array for display
const sortedLeaderboard = computed(() => {
  return Object.entries(leaderboard.value)
      .map(([address, score]) => ({
        address,
        score: parseInt(score, 10) // Scores are strings from FCL
      }))
      // Sort by score (descending)
      .sort((a, b) => b.score - a.score)
})
</script>

<template>
  <div class="leaderboard-container">
    <h2>Today's Leaderboard</h2>

    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p>Loading leaderboard...</p>
    </div>

    <div v-if="!isLoading && sortedLeaderboard.length === 0" class="no-entries">
      No submissions yet. Be the first!
    </div>

    <table v-if="!isLoading && sortedLeaderboard.length > 0">
      <thead>
      <tr>
        <th>Rank</th>
        <th>Player Address</th>
        <th>Score</th>
      </tr>
      </thead>
      <tbody>
      <tr v-for="(entry, index) in sortedLeaderboard" :key="entry.address">
        <td class="rank">{{ index + 1 }}</td>
        <td class="address">{{ entry.address }}</td>
        <td class="score">{{ entry.score }}</td>
      </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.leaderboard-container {
  background-color: var(--vt-c-black-soft);
  border: 1px solid var(--vt-c-divider-dark-2);
  padding: 2rem;
  border-radius: 16px;
  margin-top: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
}
.leaderboard-container h2 {
  color: var(--vt-c-text-dark-1);
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
  border-bottom: 1px solid var(--vt-c-divider-dark-1);
  padding-bottom: 0.5rem;
}
.loading-state, .no-entries {
  text-align: center;
  padding: 3rem;
  font-size: 1.2rem;
  color: var(--vt-c-text-dark-2);
  font-style: italic;
}
table {
  width: 100%;
  border-collapse: collapse;
}
th, td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid var(--vt-c-divider-dark-2);
}
th {
  color: var(--vt-c-text-dark-2);
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
td.rank {
  font-weight: bold;
  font-size: 1.2rem;
  color: var(--vt-c-green-light);
  width: 10%;
}
td.address {
  font-family: monospace;
  font-size: 1.1rem;
  color: var(--vt-c-white-soft);
  width: 70%;
}
td.score {
  font-weight: bold;
  font-size: 1.2rem;
  color: var(--vt-c-green);
  width: 20%;
  text-align: right;
}
tr:last-child td {
  border-bottom: none;
}
.spinner {
  border: 4px solid var(--vt-c-divider-dark-1);
  border-top: 4px solid var(--vt-c-green);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>