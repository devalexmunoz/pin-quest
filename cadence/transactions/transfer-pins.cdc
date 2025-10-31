import "NonFungibleToken"
import "Pinnacle"

transaction(recipientAddress: Address) {

    let collection: auth(NonFungibleToken.Withdraw) &Pinnacle.Collection
    let recipient: &{NonFungibleToken.CollectionPublic}

    prepare(signer: auth(Storage) &Account) {

        self.collection = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &Pinnacle.Collection>(
            from: Pinnacle.CollectionStoragePath
        ) ?? panic("Signer does not have a Pinnacle Collection with Withdraw capability")

        self.recipient = getAccount(recipientAddress).capabilities
            .borrow<&{NonFungibleToken.CollectionPublic}>(
                Pinnacle.CollectionPublicPath
            ) ?? panic("Recipient does not have a Pinnacle Collection. Run 'setup-collection.cdc' in the app first.")
    }

    execute {
        let ids = self.collection.getIDs()
        
        for id in ids {
            let nft <- self.collection.withdraw(withdrawID: id)
            self.recipient.deposit(token: <-nft)
        }
        
        log("Transferred ".concat(ids.length.toString()).concat(" pins to ").concat(recipientAddress.toString()))
    }
}