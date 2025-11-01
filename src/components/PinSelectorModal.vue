<script setup>
import { computed }from 'vue'
import { storeToRefs } from 'pinia'
import { useCollectionStore } from '../stores/collection'
import { useQuestStore } from '../stores/quest'
import { checkPin } from '../flow/checkPin'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  requirement: {
    type: String,
    required: true
  },
  unavailablePinIDs: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'pin-selected'])

const collectionStore = useCollectionStore()
const { allPins } = storeToRefs(collectionStore)

const questStore = useQuestStore()
const { usedPins } = storeToRefs(questStore)

const pinsWithEligibility = computed(() => {
  return allPins.value.map(pin => {
    const pinIdString = pin.id.toString()
    const meetsRequirement = checkPin(pin, props.requirement)
    const isUnavailable = props.unavailablePinIDs.includes(pinIdString)
    const isHistoricallyUsed = !!usedPins.value[pinIdString]

    let filterReason = null
    if (!meetsRequirement) filterReason = "No Match"
    else if (isHistoricallyUsed) filterReason = "Used (Season)"
    else if (isUnavailable) filterReason = "Used (Canvas)"

    return {
      ...pin,
      isEligible: !filterReason,
      filterReason: filterReason
    }
  })
})

const selectPin = (pin) => {
  if (pin.isEligible) {
    emit('pin-selected', pin)
    emit('close')
  }
}

const closeModal = () => {
  emit('close')
}
</script>

<template>
  <div v-if="show" class="modal-overlay" @click.self="closeModal">
    <div class="modal-content">
      <div class="modal-header">
        <h2>Select a Pin</h2>
        <p>Requirement: <span>{{ requirement }}</span></p>
        <button class="close-btn" @click="closeModal">&times;</button>
      </div>

      <div class="pin-grid">
        <div
            v-for="pin in pinsWithEligibility"
            :key="pin.id"
            class="pin-card"
            :class="{ 'is-ineligible': !pin.isEligible }"
            @click="selectPin(pin)"
        >
          <img :src="pin.thumbnail" :alt="pin.name" />
          <p>{{ pin.name }}</p>

          <div v-if="!pin.isEligible" class="status-tag" :class="pin.filterReason">
            {{ pin.filterReason }}
          </div>
        </div>
      </div>

      <div v-if="allPins.length === 0" class="no-pins">
        You have no pins in your collection.
      </div>

    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.85);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}
.modal-content {
  width: 90%;
  max-width: 900px;
  max-height: 90vh;
  background-color: var(--vt-c-black-soft);
  border-radius: 16px;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  border: 1px solid var(--vt-c-divider-dark-2);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.6);
}
.modal-header {
  position: relative;
  border-bottom: 2px solid var(--vt-c-divider-dark-1);
  padding-bottom: 1.5rem;
  margin-bottom: 1.5rem;
}
.modal-header h2 {
  font-size: 1.8rem;
  margin-bottom: 0.5rem;
  color: var(--vt-c-white-soft);
}
.modal-header p {
  font-size: 1.1rem;
  color: var(--vt-c-text-dark-2);
}
.modal-header p span {
  color: var(--vt-c-green);
  font-weight: bold;
  background-color: var(--vt-c-black-mute);
  padding: 4px 8px;
  border-radius: 4px;
}
.close-btn {
  position: absolute;
  top: 0px;
  right: 0px;
  background: var(--vt-c-black-mute);
  border: 1px solid var(--vt-c-divider-dark-2);
  color: var(--vt-c-text-dark-2);
  border-radius: 50%;
  width: 36px;
  height: 36px;
  font-size: 1.8rem;
  line-height: 1;
  cursor: pointer;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}
.close-btn:hover {
  background: var(--vt-c-indigo);
  color: var(--vt-c-white-soft);
}

.pin-grid {
  overflow-y: auto;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
  gap: 1.25rem;
  padding: 0.5rem;
}
.pin-card {
  border: 1px solid var(--vt-c-divider-dark-2);
  border-radius: 10px;
  padding: 1rem;
  text-align: center;
  background-color: var(--vt-c-black-mute);
  word-wrap: break-word;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}
.pin-card:hover:not(.is-ineligible) {
  transform: scale(1.05);
  border-color: var(--vt-c-green);
  box-shadow: 0 0 10px rgba(76, 175, 80, 0.3);
}
.pin-card img {
  width: 100%;
  max-width: 90px;
  height: auto;
  aspect-ratio: 1 / 1;
  border-radius: 8px;
  object-fit: contain;
  background-color: var(--vt-c-divider-dark-1);
  margin-bottom: 0.5rem;
  margin-left: auto;
  margin-right: auto;
}
.pin-card p {
  font-size: 0.9rem;
  font-weight: 500;
  margin-top: 0.5rem;
  color: var(--vt-c-white-soft);
  flex-grow: 1;
}

/* Dimming logic */
.pin-card.is-ineligible {
  opacity: 0.4;
  filter: grayscale(80%);
  cursor: not-allowed;
  border-color: var(--vt-c-divider-dark-2);
}
.pin-card.is-ineligible:hover {
  transform: none;
  box-shadow: none;
}
.no-pins {
  text-align: center;
  padding: 3rem;
  color: var(--vt-c-text-dark-2);
  font-style: italic;
}

/* NEW: Status Tag Styles */
.status-tag {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 3px 6px;
  border-radius: 4px;
  margin-top: 0.75rem;
  width: 100%;
}
.status-tag.NoMatch {
  background-color: #aa2222;
  color: var(--vt-c-white-soft);
}
.status-tag.UsedSeason {
  background-color: var(--vt-c-yellow);
  color: var(--vt-c-black-soft);
}
.status-tag.UsedCanvas {
  background-color: var(--vt-c-indigo);
  color: var(--vt-c-white-soft);
}
</style>