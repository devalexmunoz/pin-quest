<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { useQuestStore } from '../stores/quest'

const questStore = useQuestStore()
const { currentQuest, nextQuestTime, isLoading } = storeToRefs(questStore)
const { fetchQuest } = questStore // Get the fetchQuest action

const now = ref(Date.now())
let timer = null

const nextRunTimestamp = computed(() => {
  if (!nextQuestTime.value) {
    return null
  }
  return parseFloat(nextQuestTime.value) * 1000
})

const timeRemaining = computed(() => {
  if (!nextRunTimestamp.value) {
    return null
  }

  const remaining = nextRunTimestamp.value - now.value

  if (remaining <= 0) {
    return { hours: 0, minutes: 0, seconds: 0, total: 0 }
  }

  const hours = Math.floor(remaining / (1000 * 60 * 60))
  const minutes = Math.floor((remaining % (1000 * 60 * 60)) / (1000 * 60))
  const seconds = Math.floor((remaining % (1000 * 60)) / 1000)

  return { hours, minutes, seconds, total: remaining }
})

const formattedTime = computed(() => {
  if (isLoading.value) {
    return 'Fetching...'
  }

  if (nextQuestTime.value == null) {
    return 'NOT SCHEDULED'
  }

  if (!timeRemaining.value) {
    return '...'
  }

  if (timeRemaining.value.total <= 0) {
    return '00:00:00'
  }

  const { hours, minutes, seconds } = timeRemaining.value
  const pad = (num) => String(num).padStart(2, '0')
  return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`
})

watch(() => timeRemaining.value?.total, (newTotal, oldTotal) => {
  // oldTotal will be 'undefined' on the first run.
  // We only fire when oldTotal *exists* and was > 0.
  if (oldTotal !== undefined && newTotal !== undefined && newTotal <= 0 && oldTotal > 0) {
    // Timer has just transitioned from >0 to 0
    fetchQuest(true) // Call with the 'isUpdate' flag
  }
})

onMounted(() => {
  timer = setInterval(() => {
    now.value = Date.now()
  }, 1000)
})

onUnmounted(() => {
  if (timer) {
    clearInterval(timer)
  }
})

</script>

<template>
  <div class="quest-status-container">
    <div class="status-item">
      <span>Current Quest ID</span>
      <div class="value quest-id">
        {{ currentQuest ? currentQuest.questID : '...' }}
      </div>
    </div>

    <div class="status-item forte-status">
      <span>Automation</span>
      <div class="value forte">
        <span class="dot"></span>
        Powered by Flow Forte
      </div>
    </div>

    <div class="status-item">
      <span>Next Quest In</span>
      <div
          class="value countdown"
          :class="{ 'not-scheduled': nextQuestTime == null && !isLoading }"
      >
        {{ formattedTime }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.quest-status-container {
  display: grid;
  grid-template-columns: 1fr 2fr 1fr;
  gap: 1.5rem;
  background-color: var(--vt-c-black-mute);
  border: 1px solid var(--vt-c-divider-dark-2);
  padding: 1.5rem;
  border-radius: 12px;
  margin-bottom: 2rem;
}
.status-item {
  display: flex;
  flex-direction: column;
}
.status-item span {
  font-size: 0.9rem;
  color: var(--vt-c-text-dark-2);
  margin-bottom: 0.5rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.status-item .value {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--vt-c-white-soft);
}
.status-item .quest-id {
  font-family: monospace;
  color: var(--vt-c-green-light);
}
.status-item .countdown {
  font-family: monospace;
  color: var(--vt-c-yellow);
}
.status-item .countdown.not-scheduled {
  color: #aa2222;
  font-size: 1.2rem;
  font-weight: 500;
}
.status-item .forte {
  display: flex;
  align-items: center;
  font-size: 1.2rem;
  font-weight: 500;
  color: var(--vt-c-text-dark-1);
}
.status-item .forte .dot {
  width: 10px;
  height: 10px;
  background-color: var(--vt-c-green);
  border-radius: 50%;
  margin-right: 0.75rem;
  box-shadow: 0 0 8px var(--vt-c-green-light);
  animation: pulse 2s infinite;
}
@keyframes pulse {
  0% { transform: scale(0.9); opacity: 0.8; }
  50% { transform: scale(1.1); opacity: 1; }
  100% { transform: scale(0.9); opacity: 0.8; }
}
</style>