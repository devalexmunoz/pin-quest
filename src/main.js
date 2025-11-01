import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import './assets/base.css'
import './assets/main.css'

import { FlowService } from './flow/flow.service'

const pinia = createPinia()
const app = createApp(App)
app.use(pinia)

FlowService.init()
    .then(() => {
        app.mount('#app')
    })
    .catch(console.error)