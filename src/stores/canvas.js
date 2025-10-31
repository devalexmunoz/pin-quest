import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { FlowService } from '@/flow/flow.service'
import { useQuestStore } from './quest' // Import quest store
import { useLeaderboardStore } from './leaderboard' // Import leaderboard store
import submitCanvasTx from '../flow/transactions/submit-canvas.cdc?raw'

export const useCanvasStore = defineStore('canvas', () => {
    const slot1Pin = ref(null)
    const slot2Pin = ref(null)
    const slot3Pin = ref(null)

    const isSubmitting = ref(false)
    const submissionError = ref(null)
    const submissionSuccess = ref(false) // NEW: Success state

    const isCanvasFull = computed(() => slot1Pin.value && slot2Pin.value && slot3Pin.value)

    const submissionPinIDs = computed(() => [
        slot1Pin.value?.id,
        slot2Pin.value?.id,
        slot3Pin.value?.id
    ].filter(id => id != null))

    const setPin = (slotNumber, pin) => {
        if (slotNumber === 1) slot1Pin.value = pin
        if (slotNumber === 2) slot2Pin.value = pin
        if (slotNumber === 3) slot3Pin.value = pin
        // Clear errors/success when user changes a pin
        submissionError.value = null
        submissionSuccess.value = false
    }

    const clearCanvas = () => {
        slot1Pin.value = null
        slot2Pin.value = null
        slot3Pin.value = null
        submissionError.value = null
        submissionSuccess.value = false
    }

    const submitCanvas = async () => {
        if (!isCanvasFull.value) return

        isSubmitting.value = true
        submissionError.value = null
        submissionSuccess.value = false

        // Get other stores to refresh them
        const questStore = useQuestStore()
        const leaderboardStore = useLeaderboardStore()

        try {
            const transactionId = await FlowService.mutate(submitCanvasTx, {
                // Pin IDs must be strings for FCL Array(UInt64)
                pinIDs: { type: 'Array(UInt64)', value: submissionPinIDs.value.map(String) }
            })

            await FlowService.onceSealed(transactionId)

            // --- SUCCESS ---
            submissionSuccess.value = true // Set success flag
            // DO NOT CLEAR CANVAS

            // Refresh state to lock the UI
            await leaderboardStore.fetchLeaderboard() // See new submission
            await questStore.fetchUsedPins() // See newly used pins

        } catch (err) {
            console.error("Submission Failed:", err)
            submissionError.value = err.message
        }
        isSubmitting.value = false
    }

    return {
        slot1Pin,
        slot2Pin,
        slot3Pin,
        isCanvasFull,
        isSubmitting,
        submissionError,
        submissionSuccess, // EXPORT
        setPin,
        clearCanvas,
        submitCanvas
    }
})