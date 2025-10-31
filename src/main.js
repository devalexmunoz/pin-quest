import { createApp } from 'vue'
import App from './App.vue'

// 1. Import your new init function
import { init } from './flow/init.js'

// 2. Call init and mount the app AFTER it resolves
init().then(() => {
    createApp(App).mount('#app')
})