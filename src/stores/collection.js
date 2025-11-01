import { ref } from 'vue'
import { defineStore } from 'pinia'
import { FlowService } from '@/flow/flow.service'
import { useUserStore } from './user'
import { useQuestStore } from './quest'

import getPinsScript from '../flow/scripts/get-user-pins.cdc?raw'
import checkCollectionScript from '../flow/scripts/check-pinnacle-collection.cdc?raw'
import setupCollectionTx from '../flow/transactions/setup-pinnacle-collection.cdc?raw'
import mintDemoPinsTx from '../flow/transactions/mint-demo-pins.cdc?raw'

export const useCollectionStore = defineStore('collection', () => {
    const allPins = ref([])
    const isLoading = ref(false)
    const loadingMessage = ref("")
    const hasCollection = ref(true)

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

    const setupDemoWallet = async () => {
        isLoading.value = true
        const userStore = useUserStore()
        const questStore = useQuestStore()

        try {
            loadingMessage.value = "Setting up new collection..."
            await FlowService.mutate(setupCollectionTx)

            loadingMessage.value = "Minting test pins..."
            await FlowService.mutate(mintDemoPinsTx)

            loadingMessage.value = "Loading new pins..."
            await fetchPins(userStore.userAddress)

            await questStore.fetchUsedPins()

        } catch (err) {
            console.error("Demo Setup Failed:", err)
            loadingMessage.value = "Demo setup failed. Please try again."
        }
        isLoading.value = false
    }

    return {
        allPins,
        isLoading,
        loadingMessage,
        hasCollection,
        checkCollection,
        fetchPins,
        setupDemoWallet
    }
})