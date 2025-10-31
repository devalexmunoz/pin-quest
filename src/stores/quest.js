import { ref } from 'vue'
import { defineStore } from 'pinia'
import { FlowService } from '@/flow/flow.service'
import getQuestScript from '../flow/scripts/get-current-quest.cdc?raw'
import getUsedPinsScript from '../flow/scripts/get-used-pins.cdc?raw' // NEW IMPORT

export const useQuestStore = defineStore('quest', () => {
    const currentQuest = ref(null)
    const usedPins = ref({}) // MOVED HERE: Map of {pinId: questId}
    const isLoading = ref(false)

    // MOVED HERE: Fetch the list of used pins (Global Game Constraint)
    const fetchUsedPins = async () => {
        try {
            const result = await FlowService.query(getUsedPinsScript)
            usedPins.value = result
        } catch (err) {
            console.error("Failed to fetch used pins:", err)
        }
    }

    // UPDATED: Now calls fetchUsedPins as part of global state loading
    const fetchQuest = async () => {
        isLoading.value = true
        try {
            currentQuest.value = await FlowService.query(getQuestScript)
            await fetchUsedPins() // Load constraints with the quest
        } catch (err) {
            console.error("Failed to fetch quest:", err)
        }
        isLoading.value = false
    }

    return {
        currentQuest,
        usedPins, // EXPOSED
        isLoading,
        fetchQuest,
        fetchUsedPins // EXPOSED
    }
})