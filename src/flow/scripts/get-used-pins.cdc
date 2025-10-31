import "PinQuest"

// This script returns the map of all pin IDs that have been used
// in a submitted canvas this season.
// Returns: {Pin ID (UInt64): Quest ID (UInt64)}

access(all) fun main(): {UInt64: UInt64} {
    return PinQuest.getUsedPins()
}