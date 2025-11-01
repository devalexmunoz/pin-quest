import { ref } from 'vue'
import { defineStore } from 'pinia'
import { FlowService } from '@/flow/flow.service'

import getPinsScript from '../flow/scripts/get-user-pins.cdc?raw'
import checkCollectionScript from '../flow/scripts/check-pinnacle-collection.cdc?raw'

export const useCollectionStore = defineStore('collection', () => {
    const allPins = ref([])
    const isLoading = ref(false)
    const loadingMessage = ref("")
    const hasCollection = ref(true) // Start optimistic

    const checkCollection = async (address) => {
        isLoading.value = true
        loadingMessage.value = "Checking collection..."
        try {
            const result = await FlowService.query(checkCollectionScript, {
                address: { type: 'Address', value: address }
            })
            hasCollection.value = result
            return result
        } catch (err) {
            console.error("Failed to check collection", err)
            hasCollection.value = false
            return false
        }
    }

    const fetchPins = async (address) => {
        isLoading.value = true
        loadingMessage.value = "Loading your pins..."
        try {
            const pins = await FlowService.query(getPinsScript, {
                address: { type: 'Address', value: address }
            })
            allPins.value = pins
            isLoading.value = false
            return pins.length
        } catch (err) {
            console.error("Failed to fetch pins:", err)
            allPins.value = []
            isLoading.value = false
            return 0
        }
    }

    return {
        allPins,
        isLoading,
        loadingMessage,
        hasCollection,
        checkCollection,
        fetchPins
    }
})