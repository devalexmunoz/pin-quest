<script setup>
import { ref, onMounted } from 'vue'
import * as fcl from '@onflow/fcl'

import getPinsScript from '../flow/scripts/get-user-pins.cdc?raw'
import checkCollectionScript from '../flow/scripts/check-pinnacle-collection.cdc?raw'
import setupCollectionTx from '../flow/transactions/setup-pinnacle-collection.cdc?raw'
import mintBatchTx from '../flow/transactions/mint-test-pins.cdc?raw'
import prettierPinData from '../../test-pins.json'

const pins = ref([])
const isLoading = ref(false)
const loadingMessage = ref("Loading pins...")
const currentUser = ref(null)

const emit = defineEmits(['setup:started', 'setup:finished'])

const runTx = async (cadence, args) => {
  const transactionId = await fcl.mutate({
    cadence: cadence,
    args: args,
    limit: 9999
  })
  return fcl.tx(transactionId).onceSealed()
}

const checkCollection = async (address) => {
  try {
    return await fcl.query({
      cadence: checkCollectionScript,
      args: (arg, t) => [arg(address, t.Address)]
    });
  } catch (err) {
    console.error("Failed to check collection", err);
    return false;
  }
}

const fetchPins = async (address) => {
  if (!address) {
    pins.value = []
    return 0
  }

  isLoading.value = true
  loadingMessage.value = "Loading your pins..."
  try {
    const response = await fcl.query({
      cadence: getPinsScript,
      args: (arg, t) => [arg(address, t.Address)]
    })
    pins.value = response
    isLoading.value = false
    return response.length
  } catch (err) {
    console.error("Failed to fetch pins:", err)
    isLoading.value = false
    return 0
  }
}

const setupDemoWallet = async () => {
  emit('setup:started')
  isLoading.value = true
  try {
    loadingMessage.value = "Setting up new collection..."
    await runTx(setupCollectionTx)

    loadingMessage.value = "Minting test pins..."
    const pinData = {
      characters: prettierPinData.map(p => p.character),
      franchises: prettierPinData.map(p => p.franchise),
      materials: prettierPinData.map(p => p.material),
      studios: prettierPinData.map(p => p.studio),
      realRenderIDs: prettierPinData.map(p => p.renderID)
    }
    await runTx(mintBatchTx, (arg, t) => [
      arg(pinData.characters, t.Array(t.String)),
      arg(pinData.franchises, t.Array(t.Array(t.String))),
      arg(pinData.materials, t.Array(t.Array(t.String))),
      arg(pinData.studios, t.Array(t.Array(t.String))),
      arg(pinData.realRenderIDs, t.Array(t.String))
    ])

    loadingMessage.value = "Loading new pins..."
    await fetchPins(currentUser.value.addr)

  } catch (err) {
    console.error("Demo Setup Failed:", err)
    loadingMessage.value = "Demo setup failed. Please try again."
  }
  isLoading.value = false
  emit('setup:finished')
}


onMounted(() => {
  fcl.currentUser.subscribe(async (user) => {
    currentUser.value = user
    if (user && user.loggedIn) {
      const collectionExists = await checkCollection(user.addr);

      if (!collectionExists) {
        const network = import.meta.env.VITE_FLOW_NETWORK
        if (network === 'testnet') {
          await setupDemoWallet()
        } else {
          pins.value = []
        }
      } else {
        await fetchPins(user.addr);
      }

    } else {
      pins.value = []
    }
  })
})
</script>

<template>
  <div class="collection-container">
    <h2>Your Pins</h2>

    <div v-if="isLoading" class="loading-state">
      <p>{{ loadingMessage }}</p>
      <div class="spinner"></div>
    </div>

    <div v-if="pins.length > 0 && !isLoading" class="pin-grid">
      <div v-for="pin in pins" :key="pin.id" class="pin-card">
        <img :src="pin.thumbnail" :alt="pin.name" />
        <p>{{ pin.name }}</p>
        <span>ID: {{ pin.id }}</span>
      </div>
    </div>

    <div v-if="pins.length === 0 && !isLoading">
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
  object-fit: cover;
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