package com.ambatrans.app.pipeline

/** Drops blocks that are not worth translating: empty, numbers, symbols, prices, lone letters. */
object TextFilter {
    // ponytail: small fixed list of currency codes; extend if a real screen shows a missing one.
    private val CURRENCY_TOKEN = Regex(
        "(?<!\\p{L})(rp|idr|usd|eur|sgd|myr|jpy|cny|rmb|gbp|aud|us)(?!\\p{L})",
        RegexOption.IGNORE_CASE,
    )

    fun filter(blocks: List<TextBlock>): List<TextBlock> = blocks.filter { isTranslatable(it.text) }

    /** True when translating changed nothing but case, spaces or punctuation (e.g. "Bagikan" in id -> id). */
    fun isUnchanged(original: String, translated: String): Boolean = letters(original) == letters(translated)

    private fun letters(text: String) = text.filter { it.isLetterOrDigit() }.lowercase()

    fun isTranslatable(text: String): Boolean {
        val stripped = CURRENCY_TOKEN.replace(text, " ")
        val letters = stripped.filter { it.isLetter() }
        if (letters.isEmpty()) return false
        // A single Latin letter is noise ("A", "x"); a single CJK character is a real word.
        return letters.length >= 2 || letters.any { Character.isIdeographic(it.code) || it.isHangulOrKana() }
    }

    private fun Char.isHangulOrKana(): Boolean {
        val block = Character.UnicodeBlock.of(this)
        return block == Character.UnicodeBlock.HANGUL_SYLLABLES ||
            block == Character.UnicodeBlock.HIRAGANA ||
            block == Character.UnicodeBlock.KATAKANA
    }
}
