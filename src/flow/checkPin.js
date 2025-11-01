/**
 * Checks if a pin from 'get-user-pins' script
 * matches a quest requirement string.
 *
 * @param {object} pin - The pin object from our script.
 * @param {string} requirement - The quest requirement string (e.g., "Star Wars", "Digital Gold").
 * @returns {boolean}
 */
export const checkPin = (pin, requirement) => {
    if (requirement === "Any") {
        return true
    }

    // Loop through all traits on the pin
    for (const trait of pin.traits) {
        const name = trait.name
        const value = trait.value // This is the raw JS value (string, boolean, or array of strings)

        if (value === null || value === undefined) continue

        // Check Array traits (Franchises, Characters, Studios, Materials, etc.)
        // These are the traits the Darth Vader pin relies on for "Star Wars" and "Digital Gold"
        if (Array.isArray(value)) {
            if (value.includes(requirement)) {
                return true
            }
        }

        // Check Boolean 'IsChaser' trait
        if (name === 'IsChaser' && typeof value === 'boolean') {
            if (requirement === "Chaser" && value === true) {
                return true
            }
            if (requirement === "NotChaser" && value === false) {
                return true
            }
        }

        // Check simple String traits (EditionType, Thickness, etc.)
        if (typeof value === 'string') {
            if (value === requirement) {
                return true
            }
        }

        // Catch other traits that might be returned as strings (like MintingDate)
        if (String(value) === requirement) {
            return true
        }
    }

    // No match found
    return false
}