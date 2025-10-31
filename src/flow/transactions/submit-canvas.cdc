import "NonF_Token"
import "PinQuest"
import "Pinnacle"

// This transaction calls the corrected `submitCanvas` function
// on the PinQuest contract.

transaction(pinIDs: [UInt64]) {

    prepare(signer: auth(Capabilities) &Account) {
        // We don't need to do anything in prepare
        // except get the signer auth account, which is
        // passed directly to the execute phase.
    }

    execute {
        // Call the public function on the deployed PinQuest contract
        // We pass the signer object directly, as required by the fix.
        PinQuest.submitCanvas(pinIDs: pinIDs, signer: signer)

        log("Canvas submitted successfully.")
    }
}