import "NonFungibleToken"
import "MetadataViews"
import "ViewResolver"
import "Pinnacle"

access(all) contract PinQuest {

    access(all) event QuestStarted(questID: UInt64, slot1: String, slot2: String, slot3: String)
    access(all) event QuestSubmitted(questID: UInt64, user: Address, score: UInt64)
    access(all) event QuestFinalized(questID: UInt64)

    access(all) struct QuestRules {
        access(all) let questID: UInt64
        access(all) let slot1_requirement: String
        access(all) let slot2_requirement: String
        access(all) let slot3_requirement: String

        init(_ questID: UInt64, _ slot1: String, _ slot2: String, _ slot3: String) {
            self.questID = questID
            self.slot1_requirement = slot1
            self.slot2_requirement = slot2
            self.slot3_requirement = slot3
        }
    }

    access(all) let QuestPublicPath: PublicPath
    access(all) let ExecutorStoragePath: StoragePath
    
    access(all) var allPossibleQuests: [QuestRules]
    
    access(all) var currentQuestID: UInt64
    access(all) var currentQuestRules: QuestRules
    access(all) var dailyLeaderboard: {Address: UInt64}
    access(all) var questHistory: {UInt64: {Address: UInt64}}

    access(all) resource interface QuestPublic {
        access(all) fun startNewDailyQuest()
    }

    access(all) fun submitCanvas(pinIDs: [UInt64], signer: auth(Capabilities) &Account) {
        let signerAddress = signer.address

        assert(pinIDs.length == 3, message: "You must submit exactly 3 pins")

        let collectionRef = signer.capabilities
            .borrow<&{NonFungibleToken.CollectionPublic, ViewResolver.ResolverCollection}>(
                Pinnacle.CollectionPublicPath
            ) ?? panic("Could not borrow Pinnacle Collection capability implementing required interfaces.")

        var score: UInt64 = 0
        let requirements = [
            self.currentQuestRules.slot1_requirement,
            self.currentQuestRules.slot2_requirement,
            self.currentQuestRules.slot3_requirement
        ]

        var i = 0
        while i < pinIDs.length {
            let id = pinIDs[i]
            let req = requirements[i]

            let nftResolverRef = collectionRef.borrowViewResolver(id: id)
                 ?? panic("Could not borrow pin ID ".concat(id.toString()))

            if self.checkPinTraits(nft: nftResolverRef, requirement: req) {
                score = score + 100
            } else {
                panic("Pin ".concat(id.toString()).concat(" does not meet requirement: ").concat(req))
            }
            i = i + 1
        }

        self.dailyLeaderboard[signerAddress] = score
        emit QuestSubmitted(questID: self.currentQuestID, user: signerAddress, score: score)
    }

    access(all) fun checkPinTraits(nft nftRef: &{ViewResolver.Resolver}, requirement: String): Bool {
        if requirement == "Any" { return true }

        let traitsView = MetadataViews.getTraits(nftRef)!
        for trait in traitsView.traits {
            switch trait.name {
                case "Variant":
                    if let value = trait.value as? String { if value == requirement { return true } }
                case "EditionType":
                     if let value = trait.value as? String { if value == requirement { return true } }
                case "IsChaser":
                    if let value = trait.value as? Bool {
                        if requirement == "Chaser" && value == true { return true }
                        if requirement == "NotChaser" && value == false { return true }
                    }
                case "Franchises":
                    if let values = trait.value as? [String] { if values.contains(requirement) { return true } }
                case "Characters":
                    if let values = trait.value as? [String] { if values.contains(requirement) { return true } }
                case "Studios":
                    if let values = trait.value as? [String] { if values.contains(requirement) { return true } }
                case "Categories":
                     if let values = trait.value as? [String] { if values.contains(requirement) { return true } }
                 case "Materials":
                    if let values = trait.value as? [String] { if values.contains(requirement) { return true } }
                 case "Effects":
                    if let values = trait.value as? [String] { if values.contains(requirement) { return true } }
                default:
                    if let value = trait.value as? String { if value == requirement { return true } }
            }
        }
        return false
    }

    access(all) fun startNewDailyQuest() {
        emit QuestFinalized(questID: self.currentQuestID)
        self.questHistory[self.currentQuestID] = self.dailyLeaderboard
        self.dailyLeaderboard = {}
        self.currentQuestID = self.currentQuestID + 1
        
        if self.allPossibleQuests.length == 0 { panic("No quests defined!") }
        let newQuestIndex = self.currentQuestID % UInt64(self.allPossibleQuests.length)
        self.currentQuestRules = self.allPossibleQuests[newQuestIndex]

        emit QuestStarted(
            questID: self.currentQuestRules.questID,
            slot1: self.currentQuestRules.slot1_requirement,
            slot2: self.currentQuestRules.slot2_requirement,
            slot3: self.currentQuestRules.slot3_requirement
        )
        log("Started new PinQuest ID: ".concat(self.currentQuestID.toString()))
    }

    access(all) fun adminResetQuest() {
        self.currentQuestID = 0
        self.dailyLeaderboard = {}
        self.questHistory = {}
        
        if self.allPossibleQuests.length == 0 { panic("No quests defined!") }
        let newQuestIndex = self.currentQuestID % UInt64(self.allPossibleQuests.length)
        self.currentQuestRules = self.allPossibleQuests[newQuestIndex]

        emit QuestStarted(
            questID: self.currentQuestRules.questID,
            slot1: self.currentQuestRules.slot1_requirement,
            slot2: self.currentQuestRules.slot2_requirement,
            slot3: self.currentQuestRules.slot3_requirement
        )
        log("--- QUEST STATE RESET TO 0 ---")
    }

    access(all) fun adminUpdateQuests() {
        self.allPossibleQuests = [
           // Insert new quests here
        ]
        log("--- QUEST LIST HAS BEEN UPDATED ---")
    }

    access(all) fun getCurrentQuest() : QuestRules { return self.currentQuestRules }
    access(all) fun getLeaderboard(): {Address: UInt64} { return self.dailyLeaderboard }
    access(all) fun getQuestHistory(questID: UInt64): {Address: UInt64}? { return self.questHistory[questID] }

    access(all) resource PublicQuestExecutor: QuestPublic {
        access(all) fun startNewDailyQuest() {
             PinQuest.startNewDailyQuest()
        }
    }
   
    access(all) fun savePublicExecutorResource(account: auth(SaveValue, BorrowValue) &Account) {
        if account.storage.borrow<&PublicQuestExecutor>(from: self.ExecutorStoragePath) == nil {
            account.storage.save(<- create PublicQuestExecutor(), to: self.ExecutorStoragePath)
        }
    }
 
    access(all) fun publishPublicExecutor(account: auth(Capabilities, BorrowValue) &Account) {
        assert(account.storage.borrow<&PublicQuestExecutor>(from: self.ExecutorStoragePath) != nil, message: "Executor resource not found.")
        let cap = account.capabilities.storage.issue<&{QuestPublic}>(self.ExecutorStoragePath)
        account.capabilities.publish(cap, at: self.QuestPublicPath)
    }

    init() {
        self.ExecutorStoragePath = /storage/PinQuestExecutorResource
        self.QuestPublicPath = /public/PinQuestPublic
        self.currentQuestID = 0
        self.dailyLeaderboard = {}
        self.questHistory = {}
        
        self.allPossibleQuests = [
            QuestRules(0, "Star Wars", "Digital Gold", "Any"),
            QuestRules(1, "Pixar Animation Studios", "Pixar Animation Studios", "Any"),
            QuestRules(2, "NotChaser", "Mickey Mouse", "Any"),
            QuestRules(3, "Disney Princess", "Fabric", "Any"),
            QuestRules(4, "Open Edition", "Open Edition", "Open Edition"),
            QuestRules(5, "Frozen", "Ice", "Any"),
            QuestRules(6, "Toy Story", "Plastic", "Any")
        ]

        if self.allPossibleQuests.length > 0 {
             self.currentQuestRules = self.allPossibleQuests[0]
             emit QuestStarted(
                questID: self.currentQuestRules.questID,
                slot1: self.currentQuestRules.slot1_requirement,
                slot2: self.currentQuestRules.slot2_requirement,
                slot3: self.currentQuestRules.slot3_requirement
             )
        } else {
            self.currentQuestRules = QuestRules(0, "Any", "Any", "Any")
             log("Warning: No quests defined in allPossibleQuests! Setting default.")
        }
    }
}