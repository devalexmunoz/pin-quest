<script setup>
import { computed }from 'vue'
import { storeToRefs } from 'pinia'
import { useCollectionStore } from '../stores/collection'
import { checkPin } from '../flow/checkPin' // Your helper script

// 1. Define props and emits
const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  requirement: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['close', 'pin-selected'])

// 2. Get all pins from the collection store
const collectionStore = useCollectionStore()
const { allPins } = storeToRefs(collectionStore)

// 3. Create a computed list of pins with eligibility
const pinsWithEligibility = computed(() => {
  return allPins.value.map(pin => ({
    ...pin,
    isEligible: checkPin(pin, props.requirement)
  }))
})

// 4. Handle pin selection
const selectPin = (pin) => {
  if (pin.isEligible) {
    emit('pin-selected', pin)
    emit('close')
  }
}

// 5. Handle closing the modal
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
          <span>ID: {{ pin.id }}</span>
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
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  background-color: var(--vt-c-black-soft);
  border-radius: 12px;
  padding: 1.5rem 2rem;
  display: flex;
  flex-direction: column;
  border: 1px solid var(--vt-c-divider-dark-2);
}

.modal-header {
  position: relative;
  border-bottom: 1px solid var(--vt-c-divider-dark-1);
  padding-bottom: 1rem;
  margin-bottom: 1rem;
}

.modal-header h2 {
  margin: 0;
}

.modal-header p {
  font-size: 1.1rem;
  color: var(--vt-c-text-dark-2);
  margin-top: 0.25rem;
}

.modal-header p span {
  color: var(--vt-c-green);
  font-weight: bold;
}

.close-btn {
  position: absolute;
  top: -5px;
  right: -5px;
  background: var(--vt-c-black-mute);
  border: 1px solid var(--vt-c-divider-dark-1);
  border-radius: 50%;
  width: 30px;
  height: 30px;
  font-size: 1.5rem;
  line-height: 1;
  cursor: pointer;
}

.pin-grid {
  overflow-y: auto;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 1rem;
  padding: 0.5rem;
}

.pin-card {
  border: 1px solid var(--vt-c-divider-dark-2);
  border-radius: 8px;
  padding: 1rem;
  text-align: center;
  background-color: var(--vt-c-black-mute);
  word-wrap: break-word;
  cursor: pointer;
  transition: all 0.2s ease;
}
.pin-card:hover {
  transform: translateY(-3px);
  border-color: var(--vt-c-green);
}

.pin-card img {
  width: 80px;
  height: 80px;
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

/* This is the dimming logic */
.pin-card.is-ineligible {
  opacity: 0.3;
  filter: grayscale(80%);
  cursor: not-allowed;
  border-color: var(--vt-c-divider-dark-2);
}
.pin-card.is-ineligible:hover {
  transform: none;
}
</style>