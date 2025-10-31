/*
    setup-pinnacle-collection.cdc

    This transaction must be run ONCE by the deployer account
    AFTER deploying the Pinnacle contract.
    It creates an empty NFT Collection, saves it to storage,
    and publishes the standard public capabilities.
*/
import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
import "Pinnacle" // Uses alias from flow.json

transaction() {

    prepare(signer: auth(SaveValue, BorrowValue, PublishCapability, IssueStorageCapabilityController) &Account) {

        // Check if the collection is already set up
        if signer.storage.borrow<&Pinnacle.Collection>(from: Pinnacle.CollectionStoragePath) != nil {
            log("Pinnacle Collection is already set up.")
            return
        }

        // Create a new empty collection and save it to storage
        let collection <- Pinnacle.createEmptyCollection(nftType: Type<@Pinnacle.NFT>())
        signer.storage.save(<-collection, to: Pinnacle.CollectionStoragePath)

        log("Saved empty Pinnacle Collection to storage.")

        // Issue and publish the standard public capability
        // This capability allows others to read the collection and borrow views
        let publicCap = signer.capabilities.storage
            .issue<&{NonFungibleToken.CollectionPublic, ViewResolver.ResolverCollection}>( // Correct intersection type
                Pinnacle.CollectionStoragePath
            )

        signer.capabilities.publish(publicCap, at: Pinnacle.CollectionPublicPath)

        log("Published Pinnacle Collection public capability.")
    }
}

