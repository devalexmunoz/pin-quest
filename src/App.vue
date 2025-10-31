<script setup>
import { onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useUserStore } from './stores/user' // Adjust path if needed

import WalletConnect from './components/WalletConnect.vue'
import QuestCanvas from './components/QuestCanvas.vue'
import UserCollection from './components/UserCollection.vue'

// 1. Get the store
const userStore = useUserStore()
// 2. Get state reactively
const { isLoggedIn } = storeToRefs(userStore)

// 3. On mount, subscribe to user changes.
// This will automatically update the store's state.
onMounted(() => {
  userStore.subscribe()
})
</script>

<template>
  <header>
    <h1>Pinnacle Quest</h1>
    <WalletConnect/>
  </header>

  <main>
    <div v-if="!isLoggedIn" class="logged-out-message">
      <h2>Welcome</h2>
      <p>Please connect your Testnet wallet to begin.</p>
    </div>

    <div v-if="isLoggedIn">
      <QuestCanvas />
      <UserCollection />
    </div>
  </main>
</template>

<style scoped>
.logged-out-message {
  text-align: center;
  color: #ccc;
  padding: 3rem;
  background-color: var(--vt-c-black-soft);
  border-radius: 12px;
}
</style>