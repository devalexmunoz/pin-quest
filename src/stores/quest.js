import { ref } from 'vue'
import { defineStore } from 'pinia'
import { FlowService } from '@/flow/flow.service'
import getQuestScript from '../flow/scripts/get-current-quest.cdc?raw'
import getUsedPinsScript from '../flow/scripts/get-used-pins.cdc?raw'
import getNextQuestTimeScript from '../flow/scripts/get-next-quest-time.cdc?raw'

// Helper function for polling
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

export const useQuestStore = defineStore('quest', () => {
    // --- State ---
    const currentQuest = ref(null)
    const usedPins = ref({})
    const nextQuestTime = ref(null)
    const isLoading = ref(false) // For initial page load OR manual refresh
    const isUpdating = ref(false) // For Forte auto-refresh overlay

    // --- Actions ---
    const fetchUsedPins = async () => {
        try {
            const result = await FlowService.query(getUsedPinsScript)
            usedPins.value = result || {}
        } catch (err) {
            console.error("Failed to fetch used pins:", err)
        }
    }

    const fetchNextQuestTime = async () => {
        try {
            const result = await FlowService.query(getNextQuestTimeScript)
            nextQuestTime.value = result
        } catch (err) {
            console.error("Failed to fetch next quest time:", err)
            nextQuestTime.value = null
        }
    }

    const fetchQuest = async (isUpdate = false) => {
        // Store the old quest ID to check for changes
        const oldQuestID = currentQuest.value?.questID;

        if (isUpdate) {
            isUpdating.value = true
        } else {
            isLoading.value = true
        }

        try {
            // Run the main fetches
            await Promise.all([
                FlowService.query(getQuestScript).then(data => currentQuest.value = data),
                fetchUsedPins(),
                fetchNextQuestTime()
            ]);

            // FIX: If this was a Forte update and the quest ID *hasn't* changed,
            // poll a few times to wait for the job to settle.
            if (isUpdate && currentQuest.value?.questID === oldQuestID) {

                for (let i = 0; i < 3; i++) {
                    await sleep(3000); // Wait 3 seconds

                    const newData = await FlowService.query(getQuestScript);

                    if (newData?.questID !== oldQuestID) {
                        // Success! The quest updated.
                        currentQuest.value = newData;
                        // Fetch the new timestamp and used pins to match the new quest
                        await fetchNextQuestTime();
                        await fetchUsedPins();
                        break; // Exit polling loop
                    }
                }
            }

        } catch (err) {
            console.error("Failed to fetch quest data:", err)
        }

        if (isUpdate) {
            isUpdating.value = false
        } else {
            isLoading.value = false
        }
    }

    return {
        // State
        currentQuest,
        usedPins,
        nextQuestTime,
        isLoading,
        isUpdating,

        // Actions
        fetchQuest,
        fetchUsedPins,
        fetchNextQuestTime
    }
})