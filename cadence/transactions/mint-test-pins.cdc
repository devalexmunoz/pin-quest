/*
    mint-batch.cdc
    Mints a BATCH of 10 pins.
    Accepts 5 arrays, including the REAL renderID for the frontend.
*/

import "NonFungibleToken"
import "Pinnacle" // Resolved via flow.json alias

transaction(
    // --- Arguments as Arrays ---
    characters: [String],
    franchises: [[String]],
    materials: [[String]],
    studios: [[String]],
    realRenderIDs: [String]
) {

    let adminRef: auth(Pinnacle.Operate, Pinnacle.Mint) &Pinnacle.Admin
    let receiverCap: Capability<&{NonFungibleToken.CollectionPublic}>

    prepare(signer: auth(Storage, Capabilities) &Account) {
        pre {
            characters.length == franchises.length: "Array length mismatch: characters"
            franchises.length == materials.length: "Array length mismatch: materials"
            materials.length == studios.length: "Array length mismatch: studios"
            studios.length == realRenderIDs.length: "Array length mismatch: renderIDs"
        }

        self.adminRef = signer.storage.borrow<auth(Pinnacle.Operate, Pinnacle.Mint) &Pinnacle.Admin>(from: Pinnacle.AdminStoragePath)
            ?? panic("Could not borrow Admin resource")

        self.receiverCap = signer.capabilities.get<&{NonFungibleToken.CollectionPublic}>(Pinnacle.CollectionPublicPath)
    }

    execute {
        let seriesID = Pinnacle.getSeriesIDByName("Test Series") ?? self.adminRef.createSeries(name: "Test Series")
        let setID = Pinnacle.getSetIDByName("Test Set") ?? self.adminRef.createSet(renderID: "test_set", name: "Test Set", editionType: "Open Edition", seriesID: seriesID)

        var i = 0
        while i < characters.length {
            let character = characters[i]
            let franchise = franchises[i]
            let material = materials[i]
            let studio = studios[i]
            let renderID = realRenderIDs[i]

            let shapeMetadata: {String: AnyStruct} = {
                "Franchises": franchise,
                "Characters": [character],
                "RoyaltyCodes": ["DEFAULT"],
                "Studios": studio
            }

            let timestamp = getCurrentBlock().timestamp.toString()
            let shapeName = character.concat(timestamp).concat(i.toString())

            // The Shape's renderID doesn't matter for the frontend, so we'll just generate one
            let shapeID = self.adminRef.createShape(renderID: "shape_".concat(shapeName), setID: setID, name: shapeName, metadata: shapeMetadata)

            let editionTraits: {String: AnyStruct} = {
                "Materials": material,
                "Size": "MEDIUM",
                "Thickness": "MEDIUM THIN"
            }

            let editionID = self.adminRef.createEdition(
                renderID: renderID,
                shapeID: shapeID,
                variant: nil,
                description: "Test ".concat(character),
                isChaser: false,
                maxMintSize: nil,
                maturationPeriod: nil,
                traits: editionTraits
            )

            let newPin <- self.adminRef.mintNFT(editionID: editionID, extension: nil)

            let receiver = self.receiverCap.borrow()
                ?? panic("Could not borrow receiver interface")
            receiver.deposit(token: <-newPin)

            log("Minted batch pin ".concat(i.toString()).concat(": ").concat(character))

            i = i + 1
        }
    }
}