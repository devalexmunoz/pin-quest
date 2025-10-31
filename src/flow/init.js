import { config } from '@onflow/fcl'
import { ref } from 'vue'

import flowJSON from '../../flow.json' assert { type: 'json' }

const isInitialized = ref(false)

const getViteEnv = (key) => {
    if (import.meta.env[key] === undefined) {
        throw new Error(`Environment variable ${key} is not defined!`)
    }
    return import.meta.env[key]
}

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

        'app.detail.title': 'Pinnacle Quest',
        'app.detail.icon': 'https://placekitten.com/g/200/200',
    })
        .load({
            flowJSON: flowJSON
        })

    isInitialized.value = true
}