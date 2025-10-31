import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { FlowService } from '@/flow/flow.service'

export const useUserStore = defineStore('user', () => {
    // --- State ---
    const currentUser = ref(null)

    // --- Getters ---
    const isLoggedIn = computed(() => currentUser.value && currentUser.value.loggedIn)
    const userAddress = computed(() => currentUser.value?.addr)

    // --- Actions ---
    const subscribe = () => {
        FlowService.subscribeToCurrentUser((user) => {
            currentUser.value = user
        })
    }

    const logIn = () => {
        FlowService.logIn()
    }

    const logOut = () => {
        // FIX: Explicitly clear the local state before calling FCL's unauthenticate.
        // This ensures the Vue app immediately registers the logged out state.
        currentUser.value = null
        FlowService.logOut()
    }

    return {
        currentUser,
        isLoggedIn,
        userAddress,
        subscribe,
        logIn,
        logOut
    }
})