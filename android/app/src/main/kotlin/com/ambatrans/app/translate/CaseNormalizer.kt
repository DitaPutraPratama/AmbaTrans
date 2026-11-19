package com.ambatrans.app.translate

/**
 * On-device models are trained on mixed-case text and garble ALL-CAPS lettering (comics, buttons), so
 * an all-caps sentence is lowered to sentence case before ML Kit sees it.
 */
object CaseNormalizer {
    // ponytail: acronyms inside an all-caps sentence are lowered too ("THE USA" -> "The usa"); keep a list if that hurts.
    private val SENTENCE_START = Regex("(^|[.!?…]\\s+)(\\p{Ll})")
    private val WHITESPACE = Regex("\\s+")

    fun sentenceCase(text: String): String {
        val letters = text.filter { it.isLetter() }
        val allCaps = letters.any { it.isUpperCase() } && letters.none { it.isLowerCase() }
        // A single word ("SETTINGS", "USA") is left alone: it may be an acronym and translates fine.
        if (!allCaps || text.trim().split(WHITESPACE).size < 2) return text
        return SENTENCE_START.replace(text.lowercase()) { it.groupValues[1] + it.groupValues[2].uppercase() }
    }
}
