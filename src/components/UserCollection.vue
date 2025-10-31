<script setup>
import { ref, onMounted } from 'vue'
import * as fcl from '@onflow/fcl'
import getPinsScript from '../flow/scripts/get-user-pins.cdc?raw'

const pins = ref([])
const isLoading = ref(false)
const currentUser = ref(null)

const fetchPins = async (address) => {
  if (!address) {
    pins.value = []
    return
  }

  isLoading.value = true
  try {
    const response = await fcl.query({
      cadence: getPinsScript,
      args: (arg, t) => [arg(address, t.Address)]
    })
    pins.value = response
  } catch (err) {
    // We only log the error now, we don't show it
    console.error("Failed to fetch pins:", err)
  }
  isLoading.value = false
}

onMounted(() => {
  fcl.currentUser.subscribe(user => {
    currentUser.value = user
    if (user && user.loggedIn) {
      fetchPins(user.addr)
    } else {
      fetchPins(null)
    }
  })
})
</script>

<template>
  <div class="collection-container">
    <h2>Your Pins</h2>
    <div v-if="isLoading">Loading pins...</div>

    <div v-if="!currentUser || !currentUser.loggedIn">
      Please connect your wallet to see your pins.
    </div>

    <div v-if="pins.length > 0" class="pin-grid">
      <div v-for="pin in pins" :key="pin.id" class="pin-card">
        <img :src="pin.thumbnail" :alt="pin.name" />
        <p>{{ pin.name }} (ID: {{ pin.id }})</p>
      </div>
    </div>

    <div v-if="currentUser && currentUser.loggedIn && pins.length === 0 && !isLoading">
      You have no pins in your collection.
    </div>
  </div>
</template>

<style scoped>
.collection-container {
  border: 1px solid #444;
  padding: 1.5rem;
  border-radius: 8px;
  background-color: #1a1a1a;
  margin-top: 1.5rem;
}
.pin-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 1rem;
}
.pin-card {
  border: 1px solid #555;
  border-radius: 8px;
  padding: 1rem;
  text-align: center;
  background-color: #2c3e50;
  word-wrap: break-word;
}
.pin-card img {
  width: 100px;
  height: 100px;
  border-radius: 5px;
  object-fit: cover;
  background-color: #555;
}
.pin-card p {
  font-size: 0.9rem;
  margin-top: 0.5rem;
}
</style>