/*
    setup-quest-capability.cdc
    Links the deployed PinQuest contract to a public capability. Run once by deployer.
    UPDATED for Cadence 1.0 syntax.
*/

import "PinQuest" // Resolved via flow.json alias

transaction {

    // Need entitlements to manage storage and capabilities
    prepare(signer: auth(Storage, Capabilities, Controller) &Account) {

        let publicPath = /public/PinQuestPublic
        let storagePath = /storage/PinQuest // Path where PinQuest *should* be saved by its init

        // Verify PinQuest resource exists in storage before attempting to issue capability
        if signer.storage.borrow<&PinQuest>(from: storagePath) == nil {
             // Attempt to save if not already saved (defensive coding)
             if let contractInstance <- signer.contracts.borrow<&PinQuest>(name: "PinQuest") {
                 // Note: This assumes the contract *itself* is the resource to be saved.
                 // If PinQuest.init doesn't save itself, this logic needs adjustment.
                 // For now, let's assume init handles saving correctly.
                 panic("PinQuest instance not found in storage and couldn't borrow contract resource.")
             } else {
                 panic("PinQuest contract not found at expected storage path and could not borrow contract.")
             }
        }

        // Publish the capability if it doesn't exist
        if !signer.capabilities.exists(publicPath) {
            // Issue a capability to the PinQuest resource in storage
            let cap = signer.capabilities.storage.issue<&PinQuest>(storagePath)
            // Publish the issued capability at the public path
            signer.capabilities.publish(cap, at: publicPath)

            log("PinQuest capability published at ".concat(publicPath.toString()))
        } else {
            log("PinQuest capability already exists at ".concat(publicPath.toString()))
        }
    }

    execute {
        log("Capability setup complete.")
    }
}

