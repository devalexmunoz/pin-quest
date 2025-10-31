import "NonFungibleToken"
import "PinQuest"
import "Pinnacle"

// This transaction calls the corrected `submitCanvas` function
// on the PinQuest contract.

transaction(pinIDs: [UInt64]) {

    // 1. Define a variable to hold the signer
    let signer: auth(Capabilities) &Account

    prepare(signer: auth(Capabilities) &Account) {
        // 2. Save the signer from the prepare phase to the transaction's state
        self.signer = signer
    }

    execute {
        // 3. Call the public function using the saved signer
        PinQuest.submitCanvas(pinIDs: pinIDs, signer: self.signer)

        log("Canvas submitted successfully.")
    }
}