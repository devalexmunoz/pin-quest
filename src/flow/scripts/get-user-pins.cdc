import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
import "Pinnacle"

access(all) struct PinTrait {
    access(all) let name: String
    access(all) let value: AnyStruct
    access(all) let displayType: String?
    init(name: String, value: AnyStruct, displayType: String?) {
        self.name = name
        self.value = value
        self.displayType = displayType
    }
}
access(all) struct PinMetadata {
    access(all) let id: UInt64
    access(all) let name: String
    access(all) let description: String
    access(all) let thumbnail: String
    access(all) let traits: [PinTrait]
    init(id: UInt64, name: String, description: String, thumbnail: String, traits: [PinTrait]) {
        self.id = id
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.traits = traits
    }
}

access(all) fun main(address: Address): [PinMetadata] {
    let pins: [PinMetadata] = []
    let account = getAccount(address)

    let collectionCap = account.capabilities.get<&Pinnacle.Collection>(
            Pinnacle.CollectionPublicPath
        )

    if collectionCap == nil {
        return pins
    }

    let collectionRef = collectionCap!.borrow()

    if collectionRef == nil {
        return pins
    }

    let ids = collectionRef!.getIDs()

    for id in ids {
        let resolverRef = collectionRef!.borrowViewResolver(id: id)
            ?? panic("Could not borrow ViewResolver")

        let displayView = MetadataViews.getDisplay(resolverRef)!
        let traitsView = MetadataViews.getTraits(resolverRef)!

        var pinTraits: [PinTrait] = []
        for trait in traitsView.traits {
             pinTraits.append(PinTrait(name: trait.name, value: trait.value, displayType: trait.displayType))
        }

        let nftRef = collectionRef!.borrowPinNFT(id: id)
            ?? panic("Could not borrow PinNFT reference")
        let renderID = nftRef.renderID

        let thumbnailURL = "https://assets.disneypinnacle.com/render/".concat(renderID).concat("/front_cropped.png")

        pins.append(
            PinMetadata(
                id: id,
                name: displayView.name,
                description: displayView.description,
                thumbnail: thumbnailURL,
                traits: pinTraits
            )
        )
    }
    return pins
}