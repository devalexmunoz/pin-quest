<script setup>
import { onMounted, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { useCollectionStore } from '../stores/collection'
import { useUserStore } from '../stores/user'

const collectionStore = useCollectionStore()
const userStore = useUserStore()

const { allPins, isLoading, loadingMessage } = storeToRefs(collectionStore)
const { userAddress } = storeToRefs(userStore)

const { checkCollection, fetchPins, setupDemoWallet } = collectionStore

// This function handles loading all user data
const loadUserData = async (address) => {
  if (!address) {
    allPins.value = [] // Clear pins on logout
    return
  }

  // User is logged in, check their collection
  const hasCollection = await checkCollection(address)

  if (hasCollection) {
    // They have a collection, fetch their pins
    await fetchPins(address)
  } else {
    // No collection, run the demo setup
    await setupDemoWallet()
  }
}

// Watch for the user to log in or out
watch(userAddress, (newAddress) => {
  loadUserData(newAddress)
})

// Also run on initial component mount
// (in case the user is already logged in on page load)
onMounted(() => {
  if (userAddress.value) {
    loadUserData(userAddress.value)
  }
})
</script>

<template>
  <div class="collection-container">
    <h2>Your Pinnacle Collection</h2>

    <div v-if="isLoading" class="loading-state">
      <p>{{ loadingMessage }}</p>
      <div class="spinner"></div>
    </div>

    <div v-if="allPins.length > 0 && !isLoading" class="pin-grid">
      <div v-for="pin in allPins" :key="pin.id" class="pin-card">
        <img :src="pin.thumbnail" :alt="pin.name" />
        <p>{{ pin.name }}</p>
        <span>ID: {{ pin.id }}</span>
      </div>
    </div>

    <div v-if="allPins.length === 0 && !isLoading">
      You have no pins in your collection.
    </div>
  </div>
</template>

<style scoped>
.collection-container {
  background-color: var(--vt-c-black-soft);
  border: 1px solid var(--vt-c-divider-dark-2);
  padding: 1.5rem;
  border-radius: 12px;
  margin-top: 2rem;
  min-height: 200px;
}
.collection-container h2 {
  color: var(--vt-c-text-dark-1);
  margin-bottom: 1rem;
}
.loading-state {
  text-align: center;
  padding: 2rem;
  font-size: 1.2rem;
  color: var(--vt-c-text-dark-2);
}
.pin-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 1rem;
}
.pin-card {
  border: 1px solid var(--vt-c-divider-dark-2);
  border-radius: 8px;
  padding: 1rem;
  text-align: center;
  background-color: var(--vt-c-black-mute);
  word-wrap: break-word;
}
.pin-card img {
  width: 100px;
  height: 100px;
  border-radius: 8px;
  object-fit: contain;
  background-color: var(--vt-c-divider-dark-1);
  margin-bottom: 0.5rem;
}
.pin-card p {
  font-size: 0.9rem;
  font-weight: 500;
  margin-top: 0.5rem;
}
.pin-card span {
  font-size: 0.8rem;
  color: var(--vt-c-text-dark-2);
  font-family: monospace;
}
.spinner {
  border: 4px solid var(--vt-c-divider-dark-1);
  border-top: 4px solid var(--vt-c-green);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 1rem auto;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>