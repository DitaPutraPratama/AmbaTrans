package com.ambatrans.app.translate

import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale

/**
 * Translates with an LLM over an OpenAI-compatible chat API ([AiProvider]). The whole screen goes in one
 * request so the model sees every piece as context for the others (ADR-024).
 */
class ChatTranslator(
    private val url: String,
    private val apiKey: String,
    private val model: String,
    private val http: JsonPost,
) : CloudTranslator {
    override suspend fun translate(texts: List<String>, source: String, target: String): List<String> {
        val messages = JSONArray()
            .put(JSONObject().put("role", "system").put("content", systemPrompt(source, target)))
            .put(JSONObject().put("role", "user").put("content", JSONArray(texts).toString()))
        // No temperature / response_format: not every provider or model accepts them.
        val body = JSONObject().put("model", model).put("messages", messages)
        val response = http.post(url, mapOf("Authorization" to "Bearer $apiKey"), body.toString())
        val content = JSONObject(response).getJSONArray("choices").getJSONObject(0)
            .getJSONObject("message").getString("content")
        val translations = JSONObject(jsonIn(content)).getJSONArray("translations")
        return List(translations.length()) { translations.optString(it) }
    }

    companion object {
        private val TRANSLATIONS_START = Regex("\\{\\s*\"translations\"")

        fun systemPrompt(source: String, target: String): String {
            val from = if (source == "auto") "whatever language it is in" else languageName(source)
            val to = languageName(target)
            return "You translate text read by OCR from a phone screen, from $from into $to. " +
                "The user message is a JSON array of text pieces from one screen in reading order; " +
                "use them as context for each other. Fix obvious OCR mistakes. Translate naturally, " +
                "the way a native $to speaker would write it. Keep names and numbers. " +
                "Reply with only a JSON object {\"translations\": [...]} holding exactly one $to string " +
                "per input piece, in the same order."
        }

        fun languageName(code: String): String =
            Locale.forLanguageTag(code).getDisplayLanguage(Locale.ENGLISH).ifBlank { code }

        /** The answer object, even when a model wraps it in ``` fences or adds reasoning text first. */
        fun jsonIn(content: String): String {
            val start = TRANSLATIONS_START.findAll(content).lastOrNull()?.range?.first ?: return content
            val end = content.lastIndexOf('}')
            return if (end > start) content.substring(start, end + 1) else content
        }
    }
}
