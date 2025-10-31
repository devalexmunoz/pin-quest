import "PinQuest"

transaction {
    prepare(signer: auth(Storage) &Account) {
    }

    execute {
        PinQuest.resetQuests()
        log("PinQuest state has been reset.")
    }
}