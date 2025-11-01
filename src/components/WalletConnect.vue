<script setup>
import { storeToRefs } from 'pinia'
import { useUserStore } from '../stores/user'

const userStore = useUserStore()
const { isLoggedIn, userAddress } = storeToRefs(userStore)
const { logIn, logOut } = userStore
</script>

<template>
  <div>
    <button v-if="!isLoggedIn" @click="logIn">
      Connect Wallet
    </button>
    <div v-if="isLoggedIn" class="wallet-info">
      <span>{{ userAddress }}</span>
      <button @click="logOut" class="logout-btn">Log Out</button>
    </div>
  </div>
</template>

<style scoped>
.wallet-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  background-color: var(--vt-c-black-soft);
  padding: 8px 12px;
  border-radius: 8px;
}
.wallet-info span {
  font-family: monospace;
  font-size: 0.9rem;
  color: var(--vt-c-text-dark-2);
}
.logout-btn {
  background-color: var(--vt-c-indigo);
  color: var(--vt-c-white-soft);
  padding: 6px 10px;
  font-size: 0.9rem;
}
.logout-btn:hover {
  background-color: #3a506b;
}
</style>