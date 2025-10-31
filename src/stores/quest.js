import { ref } from 'vue'
import { defineStore } from 'pinia'
import { FlowService } from '@/flow/flow.service' // Import service
import getQuestScript from '../flow/scripts/get-current-quest.cdc?raw'

export const useQuestStore = defineStore('quest', () => {
    const currentQuest = ref(null)
    const isLoading = ref(false)

    const fetchQuest = async () => {
        isLoading.value = true
        try {
            // Use service
            currentQuest.value = await FlowService.query(getQuestScript)
        } catch (err) {
            console.error("Failed to fetch quest:", err)
        }
        isLoading.value = false
    }

    return { currentQuest, isLoading, fetchQuest }
})