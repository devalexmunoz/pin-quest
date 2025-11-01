import "NonFungibleToken"
import "PinQuest"
import "Pinnacle"

// This transaction calls the corrected `submitCanvas` function
// on the PinQuest contract.

transaction(pinIDs: [UInt64]) {

    let signer: auth(Capabilities) &Account

    prepare(signer: auth(Capabilities) &Account) {
        self.signer = signer
    }

    execute {
        PinQuest.submitCanvas(pinIDs: pinIDs, signer: self.signer)

        log("Canvas submitted successfully.")
    }
}