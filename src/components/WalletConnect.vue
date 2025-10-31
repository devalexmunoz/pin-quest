<script setup>
import { ref, onMounted } from 'vue'
import * as fcl from '@onflow/fcl'

const currentUser = ref(null)

onMounted(() => {
  fcl.currentUser.subscribe(user => {
    currentUser.value = user
  })
})

const logIn = () => {
  fcl.authenticate()
}

const logOut = () => {
  fcl.unauthenticate()
}
</script>

<template>
  <div>
    <button v-if="!currentUser || !currentUser.loggedIn" @click="logIn">
      Connect Wallet
    </button>
    <div v-if="currentUser && currentUser.loggedIn">
      <p>Wallet: {{ currentUser.addr }}</p>
      <button @click="logOut">Log Out</button>
    </div>
  </div>
</template>

<style scoped>
div {
  padding: 10px;
  background-color: #2c3e50;
  color: white;
  border-radius: 8px;
  margin: 10px;
}
button {
  margin-left: 10px;
  padding: 8px 12px;
  background-color: #42b983;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
</style>