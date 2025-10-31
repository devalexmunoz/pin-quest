import "PinQuest"

// This script reads the current daily leaderboard.
// It returns a dictionary of {Address: UInt64}

access(all) fun main(): {Address: UInt64} {
    return PinQuest.getLeaderboard()
}