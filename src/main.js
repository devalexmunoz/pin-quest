import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import './assets/base.css' // <-- NEW: Import base styles first
import './assets/main.css'

// 1. Import the new service
import { FlowService } from './flow/flow.service'

const pinia = createPinia()
const app = createApp(App)
app.use(pinia)

// 2. Call the service to initialize
FlowService.init()
    .then(() => {
        // 3. Mount app after FCL is ready
        app.mount('#app')
    })
    .catch(console.error)