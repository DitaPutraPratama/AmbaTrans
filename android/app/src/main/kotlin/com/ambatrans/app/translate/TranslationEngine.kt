package com.ambatrans.app.translate

import com.ambatrans.app.pipeline.TextBlock
import com.ambatrans.app.pipeline.TranslatedBlock
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.Translator
import com.google.mlkit.nl.translate.TranslatorOptions
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope

/** Translates one string; closed when the language pair changes or the service stops. */
interface TranslatorClient {
    suspend fun translate(text: String): String

    fun close()
}

class ModelNotReadyException : Exception("Translation models are not installed")

class TranslationFailedException : Exception("No block could be translated")

/**
 * Translates all blocks of a screen in one batch. A block that fails is skipped (F-06); the call fails
 * only when the models are missing or when every block fails. Keeps one client per language pair.
 */
class TranslationEngine(
    private val models: ModelManager,
    private val clientFactory: (source: String, target: String) -> TranslatorClient,
) {
    private var pair: Pair<String, String>? = null
    private var client: TranslatorClient? = null

    suspend fun translateAll(blocks: List<TextBlock>, source: String, target: String): List<TranslatedBlock> {
        if (blocks.isEmpty()) return emptyList()
        if (!models.getStatus(source, target).ready) throw ModelNotReadyException()
        val translator = clientFor(source, target)
        val results = coroutineScope {
            blocks.map { block -> async { block to translateOrNull(translator, block.text) } }.awaitAll()
        }
        val translated = results.mapNotNull { (block, text) -> text?.let { TranslatedBlock(block, it) } }
        if (translated.isEmpty()) throw TranslationFailedException()
        return translated
    }

    @Synchronized
    fun close() {
        client?.close()
        client = null
        pair = null
    }

    @Synchronized
    private fun clientFor(source: String, target: String): TranslatorClient {
        val wanted = source to target
        if (pair != wanted) {
            client?.close()
            client = clientFactory(source, target)
            pair = wanted
        }
        return client!!
    }

    private suspend fun translateOrNull(translator: TranslatorClient, text: String): String? = try {
        translator.translate(text).takeIf { it.isNotBlank() }
    } catch (e: CancellationException) {
        throw e
    } catch (e: Exception) {
        null
    }

    companion object {
        fun create(models: ModelManager) = TranslationEngine(models) { source, target ->
            val options = TranslatorOptions.Builder().setSourceLanguage(source).setTargetLanguage(target).build()
            MlKitTranslatorClient(Translation.getClient(options))
        }
    }
}

private class MlKitTranslatorClient(private val translator: Translator) : TranslatorClient {
    override suspend fun translate(text: String): String = translator.translate(text).await()

    override fun close() = translator.close()
}
