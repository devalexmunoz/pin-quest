import * as fcl from '@onflow/fcl'
import { init as initFCL } from './init' // The init.js file you already have

// 1. AUTHENTICATION
// -----------------

/**
 * Initializes the FCL configuration.
 */
const init = async () => {
    await initFCL()
}

/**
 * Logs the user in by calling FCL's authenticate method.
 */
const logIn = () => {
    fcl.authenticate()
}

/**
 * Logs the user out.
 */
const logOut = () => {
    fcl.unauthenticate()
}

/**
 * Subscribes to the FCL currentUser object to get real-time updates.
 * @param {Function} callback - A function to call with the user object.
 * @returns {Function} - An unsubscribe function.
 */
const subscribeToCurrentUser = (callback) => {
    return fcl.currentUser.subscribe(callback)
}

// 2. FCL HELPERS
// -----------------

/**
 * Executes a read-only Cadence script.
 * @param {string} cadence - The Cadence script code.
 * @param {Object} args - Arguments object: { name: { type: 'Type', value: value } }
 * @returns {Promise<any>} - The result of the script.
 */
const query = async (cadence, args = {}) => {
    try {
        // FIX: Map the structured argument object to FCL's expected format (value, type)
        const fclArgs = Object.values(args).map((arg) => fcl.arg(arg.value, fcl.t[arg.type]))

        return await fcl.query({
            cadence,
            args: (arg, t) => fclArgs,
        })
    } catch (error) {
        console.error(`Error in FCL query: ${cadence}`, error)
        throw error
    }
}

/**
 * Executes a Cadence transaction.
 * @param {string} cadence - The Cadence transaction code.
 * @param {Object} args - Arguments object: { name: { type: 'Type', value: value } }
 * @returns {Promise<string>} - The transaction ID.
 */
const mutate = async (cadence, args = {}) => {
    try {
        // FIX: Map the structured argument object to FCL's expected format (value, type)
        const fclArgs = Object.values(args).map((arg) => fcl.arg(arg.value, fcl.t[arg.type]))

        const transactionId = await fcl.mutate({
            cadence,
            args: (arg, t) => fclArgs,
            limit: 9999, // Set a high gas limit
        })
        return transactionId
    } catch (error) {
        console.error(`Error in FCL mutate: ${cadence}`, error)
        throw error
    }
}

/**
 * A helper to track the status of a transaction.
 * @param {string} transactionId - The ID of the transaction to watch.
 * @returns {Promise<Object>} - The final transaction status object.
 */
const onceSealed = (transactionId) => {
    return fcl.tx(transactionId).onceSealed()
}

// 3. EXPORT
// ----------

/**
 * We export all functions as a single object
 * to be imported as 'FlowService' in other files.
 */
export const FlowService = {
    init,
    logIn,
    logOut,
    subscribeToCurrentUser,
    query,
    mutate,
    onceSealed,
}