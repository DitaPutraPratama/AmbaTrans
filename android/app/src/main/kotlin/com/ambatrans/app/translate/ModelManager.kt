package com.ambatrans.app.translate

import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.common.model.RemoteModelManager
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.TranslateRemoteModel
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.TranslatorOptions

data class ModelStatus(val ready: Boolean, val missing: List<String>)

class ModelDownloadException(cause: Throwable) : Exception(cause)

/**
 * Checks and downloads translation models. [downloadedCodes] and [downloader] are injectable so the
 * logic can be unit tested without ML Kit; [create] wires the real implementations.
 */
class ModelManager(
    private val downloadedCodes: suspend () -> Set<String>,
    private val downloader: suspend (source: String, target: String) -> Unit,
) {
    suspend fun getStatus(source: String, target: String): ModelStatus {
        val downloaded = downloadedCodes()
        val missing = requiredModels(source, target).filter { it !in downloaded }
        return ModelStatus(ready = missing.isEmpty(), missing = missing)
    }

    /** Downloads what the pair needs; failures surface as [ModelDownloadException]. */
    suspend fun download(source: String, target: String) {
        try {
            downloader(source, target)
        } catch (e: kotlinx.coroutines.CancellationException) {
            throw e
        } catch (e: Exception) {
            throw ModelDownloadException(e)
        }
    }

    companion object {
        private const val ENGLISH = "en"
        private const val AUTO = "auto"

        /**
         * Models needed for source -> target. ML Kit pivots through English, so pairs without English
         * also need it. "auto" source needs no model of its own (F-11).
         */
        fun requiredModels(source: String, target: String): List<String> {
            val pair = listOf(source, target).filter { it != AUTO }.distinct()
            return if (ENGLISH in pair || pair.isEmpty()) pair else pair + ENGLISH
        }

        fun supportedLanguages(): List<String> = TranslateLanguage.getAllLanguages()

        fun create(): ModelManager {
            val remote = RemoteModelManager.getInstance()
            return ModelManager(
                downloadedCodes = {
                    remote.getDownloadedModels(TranslateRemoteModel::class.java).await().map { it.language }.toSet()
                },
                downloader = { source, target ->
                    val options = TranslatorOptions.Builder()
                        .setSourceLanguage(source)
                        .setTargetLanguage(target)
                        .build()
                    val translator = Translation.getClient(options)
                    try {
                        translator.downloadModelIfNeeded(DownloadConditions.Builder().build()).await()
                    } finally {
                        translator.close()
                    }
                },
            )
        }
    }
}
