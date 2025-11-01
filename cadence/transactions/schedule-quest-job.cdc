import "FlowTransactionScheduler"
import "FlowTransactionSchedulerUtils"
import "FlowToken"
import "FungibleToken"
import "QuestJobHandler"
import "PinQuest"

transaction(intervalSeconds: UFix64, startTimeOffsetSeconds: UFix64) {

    let priority: FlowTransactionScheduler.Priority
    let executionEffort: UInt64
    let handlerStoragePath: StoragePath

    // The transaction-level variable to store the time
    let firstExecutionTime: UFix64

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, SaveValue, GetStorageCapabilityController, PublishCapability) &Account) {

        self.priority = FlowTransactionScheduler.Priority.Low
        self.executionEffort = 2500
        self.handlerStoragePath = /storage/QuestJobHandler

        // ... (rest of prepare logic is unchanged) ...
        var handlerCap: Capability<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}>? = nil
        let controllers = signer.capabilities.storage.getControllers(forPath: self.handlerStoragePath)
        var i = 0
        while i < controllers.length {
            if let cap = controllers[i].capability as? Capability<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}> {
                handlerCap = cap
                break
            }
            i = i + 1
        }
        if handlerCap == nil {
            panic("Could not find required auth(FlowTransactionScheduler.Execute) capability for handler. Run setup-quest-handler.cdc first.")
        }

        if signer.storage.borrow<&AnyResource>(from: FlowTransactionSchedulerUtils.managerStoragePath) == nil {
            let manager <- FlowTransactionSchedulerUtils.createManager()
            signer.storage.save(<-manager, to: FlowTransactionSchedulerUtils.managerStoragePath)
            let managerCapPublic = signer.capabilities.storage.issue<&{FlowTransactionSchedulerUtils.Manager}>(FlowTransactionSchedulerUtils.managerStoragePath)
            signer.capabilities.publish(managerCapPublic, at: FlowTransactionSchedulerUtils.managerPublicPath)
        }

        let manager = signer.storage.borrow<auth(FlowTransactionSchedulerUtils.Owner) &{FlowTransactionSchedulerUtils.Manager}>(from: FlowTransactionSchedulerUtils.managerStoragePath)
            ?? panic("Could not borrow a Manager reference")

        let managerCap = signer.capabilities.storage.issue<auth(FlowTransactionSchedulerUtils.Owner) &{FlowTransactionSchedulerUtils.Manager}>(
                FlowTransactionSchedulerUtils.managerStoragePath
            )

        let feeProviderCap = signer.capabilities.storage
            .issue<auth(FungibleToken.Withdraw) &FlowToken.Vault>(/storage/flowTokenVault)


        let cronConfig = QuestJobHandler.createCronConfig(
            intervalSeconds: intervalSeconds,
            baseTimestamp: getCurrentBlock().timestamp + startTimeOffsetSeconds,
            maxExecutions: nil,
            schedulerManagerCap: managerCap,
            feeProviderCap: feeProviderCap,
            priority: self.priority,
            executionEffort: self.executionEffort
        )

        // Save the time to the transaction field
        self.firstExecutionTime = cronConfig.getNextExecutionTime()

        // FIX: Use self.firstExecutionTime
        let est = FlowTransactionScheduler.estimate(
            data: cronConfig,
            timestamp: self.firstExecutionTime,
            priority: self.priority,
            executionEffort: self.executionEffort
        )

        assert(
            est.timestamp != nil || self.priority == FlowTransactionScheduler.Priority.Low,
            message: est.error ?? "estimation failed"
        )

        let vaultRef = signer.storage
            .borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("missing FlowToken vault")
        let fees <- vaultRef.withdraw(amount: est.flowFee ?? 0.0) as! @FlowToken.Vault

        // FIX: Use self.firstExecutionTime
        let transactionId = manager.schedule(
            handlerCap: handlerCap!,
            data: cronConfig,
            timestamp: self.firstExecutionTime,
            priority: self.priority,
            executionEffort: self.executionEffort,
            fees: <-fees
        )

        // FIX: Use self.firstExecutionTime
        log("Scheduled first PinQuest cron job (id: ".concat(transactionId.toString()).concat(") to execute at ").concat(self.firstExecutionTime.toString()))
    }

    execute {
        // Use the saved transaction field
        PinQuest.setNextQuestStartTime(timestamp: self.firstExecutionTime)
        log("Successfully set initial quest start time in PinQuest contract.")
    }
}