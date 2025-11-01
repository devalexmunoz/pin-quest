import * as fcl from '@onflow/fcl'
import { init as initFCL } from './init'

// AUTHENTICATION
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


// FCL HELPERS
// -----------------

/**
 * Helper function to parse our simple type strings (e.g., "Array(UInt64)")
 * into complex FCL types (e.g., fcl.t.Array(fcl.t.UInt64)).
 */
const getFclType = (typeString) => {
    // Check for Array types like "Array(String)" or "Array(UInt64)"
    const arrayMatch = typeString.match(/^Array\((.*)\)$/);
    if (arrayMatch) {
        const innerTypeString = arrayMatch[1]; // e.g., "UInt64"
        const innerFclType = fcl.t[innerTypeString];

        if (innerFclType) {
            return fcl.t.Array(innerFclType);
        } else {
            throw new Error(`Unsupported inner array type: ${innerTypeString}`);
        }
    }

    // Check for simple types like "String", "Address", "UInt64"
    const simpleType = fcl.t[typeString];
    if (simpleType) {
        return simpleType;
    }

    throw new Error(`Unsupported FCL type string: ${typeString}`);
}

/**
 * Executes a read-only Cadence script.
 * @param {string} cadence - The Cadence script code.
 * @param {Object} args - Arguments object: { name: { type: 'Type', value: value } }
 * @returns {Promise<any>} - The result of the script.
 */
const query = async (cadence, args = {}) => {
    try {
        const fclArgs = Object.values(args).map((arg) => fcl.arg(arg.value, getFclType(arg.type)))

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
        const fclArgs = Object.values(args).map((arg) => fcl.arg(arg.value, getFclType(arg.type)))

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

// EXPORT
// ----------

export const FlowService = {
    init,
    logIn,
    logOut,
    subscribeToCurrentUser,
    query,
    mutate,
    onceSealed,
}