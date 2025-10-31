<script setup>
import { onMounted, ref, computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useQuestStore } from '../stores/quest'
import { useCanvasStore } from '../stores/canvas'
import { useLeaderboardStore } from '../stores/leaderboard'
import PinSelectorModal from './PinSelectorModal.vue'

// --- Modal State ---
const isModalOpen = ref(false)
const currentSlotNumber = ref(1)
const currentRequirement = ref("Any")

// --- Quest Store ---
const questStore = useQuestStore()
const { currentQuest, isLoading: isQuestLoading } = storeToRefs(questStore)
const { fetchQuest } = questStore

// --- Canvas Store ---
const canvasStore = useCanvasStore()
const {
  slot1Pin, slot2Pin, slot3Pin,
  isSubmitting, isCanvasFull,
  submissionSuccess, submissionError
} = storeToRefs(canvasStore)
const { submitCanvas, setPin } = canvasStore

// --- Leaderboard Store ---
const leaderboardStore = useLeaderboardStore()
const {
  hasUserSubmitted,
  userScore,
  isLoading: isLeaderboardLoading
} = storeToRefs(leaderboardStore)
const { fetchLeaderboard } = leaderboardStore

// --- Combined Loading State ---
const isLoading = computed(() => isQuestLoading.value || isLeaderboardLoading.value)

// Computed value for "is submitted" state
const isLocked = computed(() => hasUserSubmitted.value || submissionSuccess.value)

// --- Methods ---
onMounted(() => {
  fetchQuest()
  fetchLeaderboard()
})

const openPinSelector = (slotNumber) => {
  if (isLocked.value) return

  currentSlotNumber.value = slotNumber
  if (currentQuest.value) {
    if (slotNumber === 1) currentRequirement.value = currentQuest.value.slot1_requirement
    if (slotNumber === 2) currentRequirement.value = currentQuest.value.slot2_requirement
    if (slotNumber === 3) currentRequirement.value = currentQuest.value.slot3_requirement
    isModalOpen.value = true
  }
}

const onPinSelected = (pin) => {
  setPin(currentSlotNumber.value, pin)
  isModalOpen.value = false
}

const getUnavailablePinIDs = computed(() => {
  const ids = []
  if (currentSlotNumber.value !== 1 && slot1Pin.value) ids.push(slot1Pin.value.id.toString())
  if (currentSlotNumber.value !== 2 && slot2Pin.value) ids.push(slot2Pin.value.id.toString())
  if (currentSlotNumber.value !== 3 && slot3Pin.value) ids.push(slot3Pin.value.id.toString())
  return ids
})
</script>

<template>
  <div class="quest-canvas">
    <div class="header">
      <h2>Daily Quest</h2>
      <button @click="fetchQuest" :disabled="isLoading">Refresh</button>
    </div>

    <div v-if="isLoading" class="loading">Loading Quest...</div>

    <div v-if="currentQuest" class="quest-details">
      <h3>Quest ID: {{ currentQuest.questID }}</h3>

      <ul class="slots">
        <li>
          <span>Slot 1</span> {{ currentQuest.slot1_requirement }}
          <div class="selected-pin" v-if="slot1Pin">
            <img :src="slot1Pin.thumbnail" />
            {{ slot1Pin.name }}
          </div>
        </li>
        <li>
          <span>Slot 2</span> {{ currentQuest.slot2_requirement }}
          <div class="selected-pin" v-if="slot2Pin">
            <img :src="slot2Pin.thumbnail" />
            {{ slot2Pin.name }}
          </div>
        </li>
        <li>
          <span>Slot 3</span> {{ currentQuest.slot3_requirement }}
          <div class="selected-pin" v-if="slot3Pin">
            <img :src="slot3Pin.thumbnail" />
            {{ slot3Pin.name }}
          </div>
        </li>
      </ul>

      <div class="slots-actions" v-if="!isLocked">
        <button @click="openPinSelector(1)" :disabled="isSubmitting">
          {{ slot1Pin ? 'Change' : 'Select' }} Slot 1
        </button>
        <button @click="openPinSelector(2)" :disabled="isSubmitting">
          {{ slot2Pin ? 'Change' : 'Select' }} Slot 2
        </button>
        <button @click="openPinSelector(3)" :disabled="isSubmitting">
          {{ slot3Pin ? 'Change' : 'Select' }} Slot 3
        </button>
      </div>

      <div class="submit-action">

        <div v-if="submissionSuccess" class="submission-status success">
          Submission Successful!
          <span>Your Score: {{ userScore }}</span>
        </div>

        <div v-else-if="hasUserSubmitted" class="submission-status submitted">
          You have already submitted for this quest!
          <span>Your Score: {{ userScore }}</span>
        </div>

        <button
            v-else
            class="submit-btn"
            @click="submitCanvas"
            :disabled="!isCanvasFull || isSubmitting"
        >
          {{ isSubmitting ? 'Submitting...' : 'Submit Canvas' }}
        </button>

        <div v-if="submissionError" class="submission-status error">
          Submission Failed: {{ submissionError }}
        </div>
      </div>
    </div>
  </div>

  <PinSelectorModal
      :show="isModalOpen"
      :requirement="currentRequirement"
      :unavailable-pin-i-ds="getUnavailablePinIDs"
      @close="isModalOpen = false"
      @pin-selected="onPinSelected"
  />
</template>

<style scoped>
/* ... (keep old styles) ... */
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
  display: grid;
  grid-template-columns: repeat(3, 1fr);
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
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: 100px;
}
.slots li span {
  display: block;
  font-size: 0.9rem;
  font-weight: 300;
  color: var(--vt-c-green-light);
  margin-bottom: 0.25rem;
}
.selected-pin {
  font-size: 0.9rem;
  font-weight: bold;
  color: var(--vt-c-green);
  margin-top: 0.5rem;
  border-top: 1px solid var(--vt-c-divider-dark-1);
  padding-top: 0.5rem;
  word-wrap: break-word;
}
.slots-actions {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
  margin-top: 1.5rem;
}
.slots-actions button {
  flex: 1;
}
.submit-action {
  margin-top: 1.5rem;
  text-align: right;
}
.submit-btn {
  background-color: var(--vt-c-green);
  color: var(--vt-c-black-soft);
  font-size: 1.1rem;
  padding: 0.75rem 1.5rem;
  font-weight: bold;
}
.submit-btn:disabled {
  background-color: var(--vt-c-divider-dark-1);
  color: var(--vt-c-text-dark-2);
  cursor: not-allowed;
}
.selected-pin {
  font-size: 0.9rem;
  font-weight: bold;
  color: var(--vt-c-green);
  margin-top: 0.5rem;
  border-top: 1px solid var(--vt-c-divider-dark-1);
  padding-top: 0.5rem;
  word-wrap: break-word;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.selected-pin img {
  width: 32px;
  height: 32px;
  border-radius: 4px;
  background: var(--vt-c-black);
}

/* NEW: Styles for success/error messages */
.submission-status {
  font-size: 1.2rem;
  font-weight: bold;
  padding: 1.5rem;
  border-radius: 10px;
}
.submission-status span {
  display: block;
  font-size: 1rem;
  font-weight: normal;
  margin-top: 0.5rem;
}
.submission-status.success {
  background-color: var(--vt-c-green);
  color: var(--vt-c-black-soft);
}
.submission-status.submitted {
  background-color: var(--vt-c-green-light);
  color: var(--vt-c-black-soft);
}
.submission-status.error {
  background-color: #aa2222; /* Add a dark red */
  color: var(--vt-c-white-soft);
  font-size: 1rem;
  font-weight: normal;
  text-align: left;
  word-wrap: break-word;
}
</style>