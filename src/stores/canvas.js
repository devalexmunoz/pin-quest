import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { FlowService } from '@/flow/flow.service' // Import service
import submitCanvasTx from '../flow/transactions/submit-canvas.cdc?raw'

export const useCanvasStore = defineStore('canvas', () => {
    const slot1Pin = ref(null)
    const slot2Pin = ref(null)
    const slot3Pin = ref(null)

    const isSubmitting = ref(false)
    const submissionError = ref(null)

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
    }

    const clearCanvas = () => {
        slot1Pin.value = null
        slot2Pin.value = null
        slot3Pin.value = null
        submissionError.value = null
    }

    const submitCanvas = async () => {
        if (!isCanvasFull.value) return

        isSubmitting.value = true
        submissionError.value = null

        try {
            // Use service
            const transactionId = await FlowService.mutate(submitCanvasTx, {
                pinIDs: { type: 'Array(UInt64)', value: submissionPinIDs.value }
            })

            await FlowService.onceSealed(transactionId) // Wait for it to be sealed
            clearCanvas()

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
        setPin,
        clearCanvas,
        submitCanvas
    }
})