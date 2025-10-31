import "NonFungibleToken"
import "Pinnacle"

transaction {
    prepare(signer: auth(Storage, Capabilities) &Account) {

        if signer.storage.borrow<&Pinnacle.Collection>(from: Pinnacle.CollectionStoragePath) != nil {
            log("Pinnacle Collection already exists in this account.")
            return
        }

        signer.storage.save(
            <-Pinnacle.createEmptyCollection(nftType: Type<@Pinnacle.NFT>()),
            to: Pinnacle.CollectionStoragePath
        )

        signer.capabilities.publish(
            signer.capabilities.storage.issue<&Pinnacle.Collection>(Pinnacle.CollectionStoragePath),
            at: Pinnacle.CollectionPublicPath
        )

        log("Successfully created and published Pinnacle Collection.")
    }
}