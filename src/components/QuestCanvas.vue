<script setup>
import { ref, onMounted } from 'vue'
import * as fcl from '@onflow/fcl'
import getQuestScript from '../flow/scripts/get-current-quest.cdc?raw'

const quest = ref(null)
const isLoading = ref(true)
const error = ref(null)

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

onMounted(() => {
  fetchQuest()
})
</script>

<template>
  <div class="quest-canvas">
    <div class="header">
      <h2>Daily Quest</h2>
      <button @click="fetchQuest" :disabled="isLoading">Refresh</button>
    </div>

    <div v-if="isLoading" class="loading">Loading Quest...</div>
    <div v-if="error" class="error">Error fetching quest.</div>

    <div v-if="quest" class="quest-details">
      <h3>Quest ID: {{ quest.questID }}</h3>
      <ul class="slots">
        <li><span>Slot 1</span> {{ quest.slot1_requirement }}</li>
        <li><span>Slot 2</span> {{ quest.slot2_requirement }}</li>
        <li><span>Slot 3</span> {{ quest.slot3_requirement }}</li>
      </ul>
    </div>
  </div>
</template>

<style scoped>
.quest-canvas {
  background-color: var(--vt-c-black-soft);
  border: 1px solid var(--vt-c-divider-dark-2);
  padding: 1.5rem;
  border-radius: 12px;
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}
.header h2 {
  color: var(--vt-c-text-dark-1);
}
.header button {
  font-size: 0.9rem;
  padding: 6px 12px;
  background-color: var(--vt-c-indigo);
  color: var(--vt-c-white-soft);
}
.loading, .error {
  color: var(--vt-c-text-dark-2);
}
.error {
  color: var(--vt-c-yellow);
}
.slots {
  list-style-type: none;
  padding: 0;
  display: flex;
  gap: 1rem;
}
.slots li {
  flex: 1;
  background: var(--vt-c-black-mute);
  padding: 1rem;
  border-radius: 8px;
  border: 1px solid var(--vt-c-divider-dark-2);
  font-size: 1.2rem;
  font-weight: 500;
}
.slots li span {
  display: block;
  font-size: 0.9rem;
  font-weight: 300;
  color: var(--vt-c-green-light);
  margin-bottom: 0.25rem;
}
</style>