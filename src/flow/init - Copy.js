import { config } from '@onflow/fcl'
import { ref } from 'vue'

// 1. Import your flow.json file
import flowJSON from '../../flow.json' assert { type: 'json' }

const isInitialized = ref(false)

// 2. Helper function to get env vars
const getViteEnv = (key) => {
    if (import.meta.env[key] === undefined) {
        throw new Error(`Environment variable ${key} is not defined!`)
    }
    return import.meta.env[key]
}

// 3. Your init function
export const init = async () => {
    if (isInitialized.value) {
        return
    }

    const flowNetwork = getViteEnv('VITE_FLOW_NETWORK')
    const accessNodeApi = getViteEnv('VITE_FLOW_ACCESS_NODE_API')

    await config({
        'flow.network': flowNetwork,
        'accessNode.api': accessNodeApi,
        'discovery.wallet': `https://fcl-discovery.onflow.org/${flowNetwork}/authn`,

        // DApp Info
        'app.detail.title': 'Pinnacle Quest',
        'app.detail.icon': 'https://placekitten.com/g/200/200'
    })
        .load({
            // This automatically loads your contract aliases from flow.json
            flowJSON: flowJSON
        })

    isInitialized.value = true
}