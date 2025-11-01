<script setup>
import { onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useUserStore } from './stores/user'
import { useQuestStore } from './stores/quest'

import WalletConnect from './components/WalletConnect.vue'
import QuestStatus from './components/QuestStatus.vue'
import QuestCanvas from './components/QuestCanvas.vue'
import UserCollection from './components/UserCollection.vue'
import Leaderboard from './components/Leaderboard.vue'
import ScoreInfo from './components/ScoreInfo.vue' // We'll add this next
import LandingPage from './components/LandingPage.vue' // 1. IMPORT

const userStore = useUserStore()
const { isLoggedIn } = storeToRefs(userStore)

const questStore = useQuestStore()
const { isUpdating } = storeToRefs(questStore)

onMounted(() => {
  userStore.subscribe()
})
</script>

<template>
  <header>
    <h1>Pinnacle PinQuest</h1>
    <WalletConnect/>
  </header>

  <main>
    <div v-if="isUpdating" class="update-overlay">
      <div class="spinner"></div>
      <span>New quest is being scheduled...</span>
      <span>(This is a live Forte job update!)</span>
    </div>

    <div v-if="!isLoggedIn">
      <LandingPage />
    </div>

    <div v-if="isLoggedIn">
      <QuestStatus />
      <QuestCanvas />
      <Leaderboard />
      <ScoreInfo />
      <UserCollection />
    </div>
  </main>
</template>

<style scoped>
/* 3. REMOVED .logged-out-message styles */

.update-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.9);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  z-index: 2000;
  color: var(--vt-c-white-soft);
  text-align: center;
}
.update-overlay span {
  font-size: 1.2rem;
  margin-top: 1rem;
}
.update-overlay span:last-child {
  font-size: 1rem;
  color: var(--vt-c-green);
  font-family: monospace;
}
.spinner {
  border: 4px solid var(--vt-c-divider-dark-1);
  border-top: 4px solid var(--vt-c-green);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>