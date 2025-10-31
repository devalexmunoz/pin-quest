/*
    submit-canvas.cdc
    Calls the PinQuest contract to submit pins for the daily quest.
    UPDATED for Cadence 1.0 syntax.
*/

import "PinQuest" // Resolved via flow.json alias

transaction(pinIDs: [UInt64]) {

    let questRef: &PinQuest
    let signerAddress: Address

    // Need access to the signer's account info (address)
    // No specific entitlements needed beyond basic transaction signing
    prepare(signer: auth(Borrow) &Account) {
        self.signerAddress = signer.address

        // Borrow the PinQuest contract using the address from the alias
        // Use PinQuest.Type to access the contract's deployed address
        let contractAccount = getAccount(PinQuest.Type.address)
        self.questRef = contractAccount.capabilities
            .borrow<&PinQuest>(/public/PinQuestPublic) // Assuming path defined in setup tx
            ?? panic("Could not borrow PinQuest public capability from ".concat(PinQuest.Type.address.toString()))
    }

    execute {
        self.questRef.submitCanvas(pinIDs: pinIDs, signerAddress: self.signerAddress)
        log("Successfully submitted quest for address: ".concat(self.signerAddress.toString()))
    }
}

