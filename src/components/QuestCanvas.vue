<script setup>
import { ref, onMounted } from 'vue'
import * as fcl from '@onflow/fcl'

import getQuestScript from '../flow/scripts/get-current-quest.cdc?raw'

const quest = ref(null)
const isLoading = ref(true)
const error = ref(null)

// 2. Function to run the FCL query
const fetchQuest = async () => {
  isLoading.value = true
  error.value = null
  try {
    const response = await fcl.query({
      cadence: getQuestScript
    })
    quest.value = response
  } catch (err) {
    console.error("Failed to fetch quest:", err)
    error.value = err.message
  }
  isLoading.value = false
}

// 3. Run the query when the component is first loaded
onMounted(() => {
  fetchQuest()
})
</script>

<template>
  <div class="quest-canvas">
    <h2>Daily Quest</h2>
    <div v-if="isLoading">Loading Quest...</div>
    <div v-if="error" class="error">
      <p>Error fetching quest:</p>
      <pre>{{ error }}</pre>
    </div>
    <div v-if="quest">
      <h3>Quest ID: {{ quest.questID }}</h3>
      <ul>
        <li>**Slot 1:** {{ quest.slot1_requirement }}</li>
        <li>**Slot 2:** {{ quest.slot2_requirement }}</li>
        <li>**Slot 3:** {{ quest.slot3_requirement }}</li>
      </ul>
    </div>
    <button @click="fetchQuest">Refresh Quest</button>
  </div>
</template>

<style scoped>
.quest-canvas {
  border: 1px solid #444;
  padding: 1.5rem;
  border-radius: 8px;
  background-color: #1a1a1a;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  font-size: 1.2rem;
  margin: 0.5rem 0;
}
.error {
  color: #ff6b6b;
}
</style>