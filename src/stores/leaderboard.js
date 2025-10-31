import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { FlowService } from '@/flow/flow.service'
import { useUserStore } from './user'
import getLeaderboardScript from '../flow/scripts/get-leaderboard.cdc?raw'

export const useLeaderboardStore = defineStore('leaderboard', () => {
    // State: { "0xUSER_ADDRESS": "300", ... }
    const leaderboard = ref({})
    const isLoading = ref(false)

    // Store for the current user's address
    const userStore = useUserStore()

    // --- Getters ---

    /**
     * Checks if the currently logged-in user has submitted today.
     */
    const hasUserSubmitted = computed(() => {
        if (!userStore.isLoggedIn) return false
        // FCL returns dictionary keys (addresses) as strings
        return leaderboard.value[userStore.userAddress] !== undefined
    })

    /**
     * Gets the current user's score.
     */
    const userScore = computed(() => {
        if (hasUserSubmitted.value) {
            // FCL returns UFix64/UInt64 as strings
            return parseInt(leaderboard.value[userStore.userAddress], 10)
        }
        return 0
    })

    // --- Actions ---

    /**
     * Fetches the latest leaderboard from the contract.
     */
    const fetchLeaderboard = async () => {
        isLoading.value = true
        try {
            const result = await FlowService.query(getLeaderboardScript)
            leaderboard.value = result || {} // Ensure it's an object even if nil
        } catch (err) {
            console.error("Failed to fetch leaderboard:", err)
            leaderboard.value = {}
        }
        isLoading.value = false
    }

    return {
        leaderboard,
        isLoading,
        hasUserSubmitted,
        userScore,
        fetchLeaderboard
    }
})