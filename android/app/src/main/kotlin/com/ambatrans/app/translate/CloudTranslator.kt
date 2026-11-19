package com.ambatrans.app.translate

import com.ambatrans.app.data.SettingsStore
import com.ambatrans.app.pipeline.TextBlock
import com.ambatrans.app.pipeline.TranslateError
import com.ambatrans.app.pipeline.TranslatedBlock

/** An online translation API that takes a whole screen in one request (DeepL, AI). ADR-024. */
fun interface CloudTranslator {
    /** Returns one translation per entry of [texts], in the same order. */
    suspend fun translate(texts: List<String>, source: String, target: String): List<String>
}

/** A cloud failure the user can act on (no key, key rejected, quota, no connection). */
class CloudException(val error: TranslateError) : Exception(error.name)

/**
 * Pairs each block with its translation; blank answers are skipped like failed ML Kit blocks (F-06).
 * Repeated texts (e.g. several "Like" buttons) are sent once, saving tokens and DeepL characters.
 */
suspend fun CloudTranslator.translateAll(
    blocks: List<TextBlock>,
    source: String,
    target: String,
): List<TranslatedBlock> {
    if (blocks.isEmpty()) return emptyList()
    val unique = blocks.map { it.text }.distinct()
    val answers = translate(unique, source, target)
    if (answers.size != unique.size) throw TranslationFailedException()
    val byText = unique.zip(answers).toMap()
    val translated = blocks.mapNotNull { block ->
        byText[block.text]?.takeIf { it.isNotBlank() }?.let { TranslatedBlock(block, it.trim()) }
    }
    if (translated.isEmpty()) throw TranslationFailedException()
    return translated
}

object CloudTranslators {
    /** The online translator for [engine], or null when it is on-device ML Kit. */
    fun forEngine(store: SettingsStore, http: JsonPost = HttpJsonPost): CloudTranslator? {
        val engine = store.translateEngine
        if (engine == SettingsStore.ENGINE_MLKIT) return null
        val apiKey = store.apiKey(engine)
        if (apiKey.isBlank()) throw CloudException(TranslateError.API_KEY_MISSING)
        if (engine == SettingsStore.ENGINE_DEEPL) return DeepLTranslator(apiKey, http)
        val ai = AiProvider.of(engine) ?: return null
        return ChatTranslator(ai.url, apiKey, store.model(engine), http)
    }
}
