package com.ambatrans.app.translate

import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale

/**
 * Translates with an LLM on Groq (OpenAI-compatible chat API). The whole screen goes in one request so
 * the model sees every piece as context for the others (ADR-024).
 */
class GroqTranslator(private val apiKey: String, private val model: String, private val http: JsonPost) :
    CloudTranslator {
    override suspend fun translate(texts: List<String>, source: String, target: String): List<String> {
        val messages = JSONArray()
            .put(JSONObject().put("role", "system").put("content", systemPrompt(source, target)))
            .put(JSONObject().put("role", "user").put("content", JSONArray(texts).toString()))
        val body = JSONObject()
            .put("model", model)
            .put("temperature", TEMPERATURE)
            .put("response_format", JSONObject().put("type", "json_object"))
            .put("messages", messages)
        val response = http.post(URL, mapOf("Authorization" to "Bearer $apiKey"), body.toString())
        val content = JSONObject(response).getJSONArray("choices").getJSONObject(0)
            .getJSONObject("message").getString("content")
        val translations = JSONObject(content).getJSONArray("translations")
        return List(translations.length()) { translations.optString(it) }
    }

    companion object {
        private const val URL = "https://api.groq.com/openai/v1/chat/completions"
        private const val TEMPERATURE = 0.2

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
    }
}
