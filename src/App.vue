<script setup>
import { ref, onMounted } from 'vue'
import * as fcl from '@onflow/fcl'
import WalletConnect from './components/WalletConnect.vue'
import QuestCanvas from './components/QuestCanvas.vue'
import UserCollection from './components/UserCollection.vue'

const currentUser = ref(null)
const isSettingUp = ref(false)

onMounted(() => {
  fcl.currentUser.subscribe(user => {
    currentUser.value = user
    if (!user.loggedIn) {
      isSettingUp.value = false
    }
  })
})
</script>

<template>
  <header>
    <h1>Pinnacle Quest</h1>
    <WalletConnect/>
  </header>

  <main>
    <div v-if="!currentUser || !currentUser.loggedIn" className="logged-out-message">
      <h2>Welcome</h2>
      <p>Please connect your Testnet wallet to begin.</p>
    </div>

    <div v-if="currentUser && currentUser.loggedIn">
      <QuestCanvas v-if="!isSettingUp"/>

      <UserCollection
          @setup:started="isSettingUp = true"
          @setup:finished="isSettingUp = false"
      />
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