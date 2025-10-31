import * as fcl from '@onflow/fcl'
import flowJSON from '../../flow.json' assert { type: 'json' }
import { useUserStore } from '@/stores/user'

const getViteEnv = (key) => {
    if (import.meta.env[key] === undefined) {
        throw new Error(`Environment variable ${key} is not defined!`)
    }
    return import.meta.env[key]
}

export const initFCL = async () => {
    const userStore = useUserStore()

    const network = getViteEnv('VITE_FLOW_NETWORK')
    const accessNodeApi = getViteEnv('VITE_FLOW_ACCESS_NODE_API')

    await fcl.config({
        'flow.network': network,
        'accessNode.api': accessNodeApi,
        'discovery.wallet': `https://fcl-discovery.onflow.org/${network}/authn`,

        'app.detail.title': 'Pinnacle Quest',
        'app.detail.icon': 'https://placekitten.com/g/200/200'
    })
        .load({
            flowJSON: flowJSON
        })

    // Subscribe to FCL's user state and push updates to our Pinia store
    fcl.currentUser.subscribe(user => {
        userStore.setUser(user)
    })
}