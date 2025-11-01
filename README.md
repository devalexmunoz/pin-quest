# ⚔️ Pinnacle PinQuest

**Give your Pinnacle Pins a new purpose.**

Pinnacle PinQuest is a 100% on-chain, server-less daily quest game for Pinnacle collectors on the Flow blockchain.

---

## 💡 The Concept (For Collectors)

Your pin collection is amazing, but what if it could _do_ something?

Pinnacle PinQuest gives your collection daily utility. Every day, a new quest is revealed with three trait requirements. Your goal is to fill the canvas with 3 pins from your collection that not only match the quest but also have the best Rarity and Synergy to maximize your score and climb the daily leaderboard.

### How to Play

1.  **Connect Your Wallet**
    Link your Flow wallet (like Blocto) that holds your Pinnacle Pins.

2.  **Complete the Daily Quest**
    Analyze the 3 daily trait requirements (e.g., "Star Wars", "Digital Gold", "NotChaser") and select your best pins to match.

3.  **Climb the Leaderboard**
    Submit your quest to earn a score based on Rarity (Chasers, LEs) and Synergy (matching Franchises, Studios, or Materials).

---

## 🏆 The Hackathon (For Judges)

**➡️ [Watch Our Demo Video](https://www.loom.com/share/93433a9b8bce40118bd8f016d6ad5e85)**

This project was built for the **Forte Hacks (Dapper Track)** with one goal: to build a truly automated, server-less, on-chain application.

### The Technical Achievement: 100% On-Chain Automation

The core problem with "daily" on-chain games is that they aren't _really_ on-chain. They _always_ require a centralized, off-chain server (a "keeper") to run a cron job and call a contract function to reset the day's quest.

**Pinnacle PinQuest has no server.**

The _entire_ game loop is automated by **Flow Forte Scheduled Transactions**.

1.  We wrote and deployed `QuestJobHandler.cdc`, a contract that follows the cron handler pattern.
2.  We use `schedule-quest-job.cdc` to register this handler with the `FlowTransactionScheduler` to run automatically.
3.  This Forte job calls our main `PinQuest.cdc` contract, which resets the quest, clears the leaderboard, and sets the new countdown timer.

The "Next Quest In" timer you see in the app is **not** a mock. It is a live countdown reading a public `nextQuestStartTime` variable from our smart contract, which is updated _by the Forte job itself_.

### Features

- **100% Server-less Automation:** Powered by Flow Forte Scheduled Transactions.
- **Dynamic On-Chain Scoring:** Score is calculated in the contract based on:
  - **Base Score** (matching the slot)
  - **Rarity Bonus** (Chaser, Limited Edition)
  - **Synergy Bonus** (matching Franchise, Studio, or Material pairs/trios)
- **On-Chain Validation:** The contract enforces all game rules:
  - One submission per user, per quest.
  - Pins cannot be re-used in the same canvas.
  - Pins cannot be re-used for the entire season (all 7 quests).
- **Live On-Chain Timer:** The UI features a live countdown to the next quest, proving the automation is on-chain.

---

## 🛠️ Tech Stack

- **Frontend:** Vue 3 (Composition API), Pinia, Vite
- **Blockchain:** Cadence, Flow Client Library (FCL)
- **Automation:** Flow Forte Scheduled Transactions

---

## ⚙️ Development Approach & Testnet

Pinnacle PinQuest is designed to integrate directly with the official **Disney Pinnacle** NFT collection, providing new utility for existing collectors.

As no official Testnet version of the `Pinnacle` contract was available for development, we took the following steps to build our demo:

1.  We deployed a **local copy** of the `Pinnacle.cdc` contract to our Testnet account.
2.  We **minted 10 test pins** (simulating real pins from the collection) to our deployer account.
3.  We **transferred these test pins** to a separate app wallet, which we used for all testing and for our demo video.

This approach allowed us to accurately simulate the live mainnet environment and prove our application's functionality for real-world collectors.

---

## 📄 Smart Contracts

All contracts and admin transactions are in the `/cadence` directory. The user-facing app scripts are in `/src/flow`.

### Deployed Contracts (Testnet)

- **Pinnacle (copy):** `0x2dc97da14102bbd6`
- **PinQuest:** `0x2dc97da14102bbd6`
- **QuestJobHandler:** `0x2dc97da14102bbd6`

### Admin Setup (One-Time)

To start the automated job, the deployer must run:

1.  **Setup Handler:**
    ```bash
    flow transactions send ./cadence/transactions/setup-quest-job-handler.cdc --network testnet --signer [DEPLOYER_ACCOUNT]
    ```
2.  **Schedule Job (runs every 5 min):**
    ```bash
    flow transactions send ./cadence/transactions/schedule-quest-job.cdc --network testnet --signer [DEPLOYER_ACCOUNT] --arg UFix64:300.0 --arg UFix64:0.0
    ```
