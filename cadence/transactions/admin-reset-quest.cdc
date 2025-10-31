import "PinQuest"

// This transaction calls the admin function to reset all state
// back to Quest 0 and clear all leaderboards and pin history.
// It must be signed by the contract deployer.

transaction {

    prepare(signer: auth(BorrowValue) &Account) {
        // We only need the signer's authorization
        // to prove we are the admin.
    }

    execute {
        PinQuest.adminResetQuest()
        log("--- ADMIN: Quest state has been reset to 0 ---")
    }
}