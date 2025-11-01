import "PinQuest"

// This script reads the public timestamp for the next quest.

access(all) fun main(): UFix64? {
    return PinQuest.getNextQuestStartTime()
}