package com.ambatrans.app.translate

import com.ambatrans.app.pipeline.TranslateError
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL

/** POSTs a JSON body and returns the response body. Injectable so translators are testable offline. */
fun interface JsonPost {
    suspend fun post(url: String, headers: Map<String, String>, body: String): String
}

/** [JsonPost] over the platform's HttpURLConnection (no HTTP library needed). */
object HttpJsonPost : JsonPost {
    private const val CONNECT_TIMEOUT_MS = 10_000
    private const val READ_TIMEOUT_MS = 30_000

    override suspend fun post(url: String, headers: Map<String, String>, body: String): String =
        withContext(Dispatchers.IO) {
            val connection = URL(url).openConnection() as HttpURLConnection
            try {
                connection.requestMethod = "POST"
                connection.connectTimeout = CONNECT_TIMEOUT_MS
                connection.readTimeout = READ_TIMEOUT_MS
                connection.doOutput = true
                connection.setRequestProperty("Content-Type", "application/json; charset=utf-8")
                headers.forEach(connection::setRequestProperty)
                connection.outputStream.use { it.write(body.toByteArray()) }
                val code = connection.responseCode
                if (code !in 200..299) throw CloudException(errorFor(code))
                connection.inputStream.bufferedReader().use { it.readText() }
            } catch (e: IOException) {
                throw CloudException(TranslateError.NETWORK)
            } finally {
                connection.disconnect()
            }
        }

    /** 456 is DeepL's "quota exceeded"; 429 is the usual rate limit; 404 is an unknown model ID. */
    fun errorFor(httpCode: Int): TranslateError = when (httpCode) {
        401, 403 -> TranslateError.API_KEY_REJECTED
        404 -> TranslateError.MODEL_NOT_FOUND
        429, 456 -> TranslateError.QUOTA_EXCEEDED
        else -> TranslateError.FAILED
    }
}
