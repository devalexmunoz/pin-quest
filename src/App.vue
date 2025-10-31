<script setup>
import WalletConnect from './components/WalletConnect.vue'
import QuestCanvas from './components/QuestCanvas.vue'
import UserCollection from './components/UserCollection.vue'
</script>

<template>
  <header>
    <h1>Pinnacle Quest</h1>
    <WalletConnect />
  </header>

  <main>
    <QuestCanvas />
    <UserCollection />
  </main>
</template>

<style scoped>
/* (styles remain the same) */
header {
  line-height: 1.5;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #444;
}

main {
  margin-top: 2rem;
}
</style>