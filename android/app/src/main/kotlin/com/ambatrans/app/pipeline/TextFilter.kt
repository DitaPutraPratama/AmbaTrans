package com.ambatrans.app.pipeline

/** Drops blocks that are not worth translating: empty, numbers, symbols, prices, lone letters. */
object TextFilter {
    // ponytail: small fixed list of currency codes; extend if a real screen shows a missing one.
    private val CURRENCY_TOKEN = Regex(
        "(?<!\\p{L})(rp|idr|usd|eur|sgd|myr|jpy|cny|rmb|gbp|aud|us)(?!\\p{L})",
        RegexOption.IGNORE_CASE,
    )

    fun filter(blocks: List<TextBlock>): List<TextBlock> = blocks.filter { isTranslatable(it.text) }

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
