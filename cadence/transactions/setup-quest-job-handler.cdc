/*
    setup-quest-handler.cdc

    This transaction must be run ONCE by the deployer account.
    It creates an instance of the QuestJobHandler.Handler resource,
    saves it to storage, and publishes the required capabilities
    so the FlowTransactionScheduler can call it.

    Based on the InitCounterTransactionHandler.cdc example.
*/
import "QuestJobHandler"
import "FlowTransactionScheduler"

transaction() {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, SaveValue, PublishCapability) &Account) {

        // Define the storage path for our handler resource
        let handlerStoragePath = /storage/QuestJobHandler

        // Save a handler resource to storage if not already present
        if signer.storage.borrow<&AnyResource>(from: handlerStoragePath) == nil {
            let handler <- QuestJobHandler.createHandler()
            signer.storage.save(<-handler, to: handlerStoragePath)
        }

        // Issue the ENTITLED capability that the scheduler transaction will need.
        // This capability grants permission to CALL the `executeTransaction` function.
        let entitledCap = signer.capabilities.storage
            .issue<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}>(handlerStoragePath)

        // Note: We don't necessarily need to publish this one publicly.
        // The schedule-quest-job.cdc transaction will get it from storage controllers.

        // Issue a non-entitled public capability for the handler
        // (This path isn't strictly needed by the scheduler but is good practice)
        let publicCap = signer.capabilities.storage
            .issue<&{FlowTransactionScheduler.TransactionHandler}>(handlerStoragePath)

        // Publish the public capability
        signer.capabilities.publish(publicCap, at: /public/QuestJobHandler)

        log("QuestJobHandler resource saved to storage and capabilities published.")
    }
}

