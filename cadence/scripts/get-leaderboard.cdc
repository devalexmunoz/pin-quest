/*
    get-leaderboard.cdc
    Reads the current daily leaderboard.
    UPDATED for Cadence 1.0 syntax.
*/

import "PinQuest" // Resolved via flow.json alias

// Takes the address of the account where PinQuest is deployed
access(all) fun main(deployerAddress: Address): {Address: UInt64} {
    let questRef = getAccount(deployerAddress).capabilities
        .borrow<&PinQuest>(/public/PinQuestPublic) // Assuming path defined in setup tx
        ?? panic("Could not borrow PinQuest public capability from account ".concat(deployerAddress.toString()))

    return questRef.getLeaderboard()
}

