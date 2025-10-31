import "Pinnacle"

access(all) fun main(address: Address): Bool {
    let account = getAccount(address)

    let collectionCap = account.capabilities.get<&Pinnacle.Collection>(
            Pinnacle.CollectionPublicPath
        )

    if collectionCap == nil {
        return false
    }

    return collectionCap!.borrow() != nil
}