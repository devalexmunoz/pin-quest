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

// --- Stores ---
const questStore = useQuestStore()
const { currentQuest, isLoading: isQuestLoading } = storeToRefs(questStore)
const { fetchQuest } = questStore

const canvasStore = useCanvasStore()
const {
  slot1Pin, slot2Pin, slot3Pin,
  isSubmitting, isCanvasFull,
  submissionSuccess, submissionError
} = storeToRefs(canvasStore)
const { submitCanvas, setPin } = canvasStore

const leaderboardStore = useLeaderboardStore()
const {
  hasUserSubmitted,
  userScore,
  isLoading: isLeaderboardLoading
} = storeToRefs(leaderboardStore)
const { fetchLeaderboard } = leaderboardStore

// --- Computed ---
const isLoading = computed(() => isQuestLoading.value || isLeaderboardLoading.value)
const isLocked = computed(() => hasUserSubmitted.value || submissionSuccess.value)

// --- Methods ---
onMounted(() => {
  fetchQuest(false)
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
    </div>

    <div v-if="isLoading" class="loading">Loading Quest...</div>

    <div v-if="currentQuest && !isLoading" class="quest-details">

      <ul class="slots">

        <li :class="{ 'is-filled': !!slot1Pin, 'is-locked': isLocked }">
          <div class="slot-header">
            <span>Slot 1</span>
            <div class="requirement-text">Pin requirement: <strong>{{ currentQuest.slot1_requirement }}</strong></div>
          </div>

          <div v-if="!slot1Pin" class="slot-empty" @click="openPinSelector(1)">
            <button class="select-pin-btn" :disabled="isSubmitting || isLocked">
              Select Pin 1
            </button>
          </div>

          <div v-if="slot1Pin" class="slot-filled">
            <div class="selected-pin">
              <img :src="slot1Pin.thumbnail" :alt="slot1Pin.name" />
              <p>{{ slot1Pin.name }}</p>
            </div>
            <button class="change-pin-btn" @click="openPinSelector(1)" :disabled="isSubmitting || isLocked">
              Change
            </button>
          </div>
        </li>

        <li :class="{ 'is-filled': !!slot2Pin, 'is-locked': isLocked }">
          <div class="slot-header">
            <span>Slot 2</span>
            <div class="requirement-text">Pin requirement: <strong>{{ currentQuest.slot2_requirement }}</strong></div>
          </div>

          <div v-if="!slot2Pin" class="slot-empty" @click="openPinSelector(2)">
            <button class="select-pin-btn" :disabled="isSubmitting || isLocked">
              Select Pin 2
            </button>
          </div>

          <div v-if="slot2Pin" class="slot-filled">
            <div class="selected-pin">
              <img :src="slot2Pin.thumbnail" :alt="slot2Pin.name" />
              <p>{{ slot2Pin.name }}</p>
            </div>
            <button class="change-pin-btn" @click="openPinSelector(2)" :disabled="isSubmitting || isLocked">
              Change
            </button>
          </div>
        </li>

        <li :class="{ 'is-filled': !!slot3Pin, 'is-locked': isLocked }">
          <div class="slot-header">
            <span>Slot 3</span>
            <div class="requirement-text">Pin requirement: <strong>{{ currentQuest.slot3_requirement }}</strong></div>
          </div>

          <div v-if="!slot3Pin" class="slot-empty" @click="openPinSelector(3)">
            <button class="select-pin-btn" :disabled="isSubmitting || isLocked">
              Select Pin 3
            </button>
          </div>

          <div v-if="slot3Pin" class="slot-filled">
            <div class="selected-pin">
              <img :src="slot3Pin.thumbnail" :alt="slot3Pin.name" />
              <p>{{ slot3Pin.name }}</p>
            </div>
            <button class="change-pin-btn" @click="openPinSelector(3)" :disabled="isSubmitting || isLocked">
              Change
            </button>
          </div>
        </li>
      </ul>

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
          {{ isSubmitting ? 'Submitting...' : 'Submit Quest' }}
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
.quest-canvas {
  background-color: var(--vt-c-black-soft);
  border: 1px solid var(--vt-c-divider-dark-2);
  padding: 2rem;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  border-bottom: 1px solid var(--vt-c-divider-dark-1);
  padding-bottom: 1rem;
}
.header h2 {
  color: var(--vt-c-text-dark-1);
  font-size: 1.8rem;
  margin: 0;
}
.loading {
  color: var(--vt-c-text-dark-2);
  text-align: center;
  padding: 2rem;
}
.slots {
  list-style-type: none;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

/* NEW "DROP ZONE" STYLES */
.slots li {
  background: var(--vt-c-black-mute);
  border: 2px dashed var(--vt-c-divider-dark-2);
  border-radius: 12px;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  min-height: 220px;
  transition: all 0.2s ease;
  text-align: center;
}
.slots li.is-filled {
  border-style: solid;
  border-color: var(--vt-c-green);
  background: var(--vt-c-black-soft);
}
.slots li.is-locked {
  border-color: var(--vt-c-divider-dark-2);
  background: var(--vt-c-black-mute);
}
.slot-header {
  flex-shrink: 0;
}
.slots li span {
  display: block;
  font-size: 0.9rem;
  font-weight: 300;
  color: var(--vt-c-green);
  margin-bottom: 0.5rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.requirement-text {
  font-size: 1rem;
  font-weight: 600;
  color: var(--vt-c-white-soft);
}
.requirement-text strong{
  font-size: 1.3rem;
  color: var(--vt-c-green);
  font-weight: 600;
  display: block;
}
.slot-empty {
  flex-grow: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  border-radius: 8px;
  padding-top: 4rem;
  padding-bottom: 4rem;
  margin-top: 1rem;
}
.slot-empty:hover {
  background: rgba(255, 255, 255, 0.03);
}
.select-pin-btn {
  padding: 10px 20px;
  background-color: var(--vt-c-indigo);
  color: var(--vt-c-white-soft);
  border-radius: 8px;
  font-weight: 500;
}
.select-pin-btn:hover {
  background-color: #8b56af;
}
.slot-filled {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
  text-align: center;
  margin-top: 1rem;
}
.selected-pin {
  font-size: 0.9rem;
  font-weight: bold;
  color: var(--vt-c-indigo);
  word-wrap: break-word;
}
.selected-pin img {
  width: 100px;
  height: 100px;
  border-radius: 8px;
  background: var(--vt-c-divider-dark-1);
  object-fit: contain;
  margin-bottom: 0.5rem;
}
.change-pin-btn {
  background: none;
  border: 1px solid var(--vt-c-text-dark-2);
  color: var(--vt-c-text-dark-2);
  font-size: 0.9rem;
  padding: 4px 10px;
  border-radius: 6px;
  margin-top: 1rem;
}
.change-pin-btn:hover {
  background: var(--vt-c-black-soft);
  color: var(--vt-c-white);
}

/* REMOVED .slots-actions */

.submit-action {
  margin-top: 2.5rem;
  text-align: center;
}
.submit-btn {
  background-color: var(--vt-c-green);
  color: var(--vt-c-black-soft);
  font-size: 1.2rem;
  padding: 1rem 2.5rem;
  font-weight: bold;
  border-radius: 3rem;
  min-width: 250px;
}
.submit-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  box-shadow: none;
}
.submit-btn:not(:disabled):hover {
  background-color: var(--vt-c-green-darker);
}
.submission-status {
  font-size: 1.2rem;
  font-weight: bold;
  padding: 1.5rem;
  border-radius: 10px;
  max-width: 600px;
  margin: 0 auto;
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
  background-color: var(--vt-c-accent);
  color: var(--vt-c-black-soft);
}
.submission-status.error {
  background-color: #aa2222;
  color: var(--vt-c-white-soft);
  font-size: 1rem;
  font-weight: normal;
  text-align: left;
  word-wrap: break-word;
}
</style>