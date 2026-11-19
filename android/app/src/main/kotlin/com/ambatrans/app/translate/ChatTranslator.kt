package com.ambatrans.app.translate

import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale

/**
 * Translates with an LLM over an OpenAI-compatible chat API ([AiProvider]). The whole screen goes in one
 * request so the model sees every piece as context for the others (ADR-024). Token-lean: a short prompt
 * and numbered plain lines both ways, no JSON wrapper around the answer.
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
            .put(JSONObject().put("role", "user").put("content", numbered(texts)))
        // No temperature / response_format: not every provider or model accepts them.
        val body = JSONObject().put("model", model).put("messages", messages)
        val response = http.post(url, mapOf("Authorization" to "Bearer $apiKey"), body.toString())
        val content = JSONObject(response).getJSONArray("choices").getJSONObject(0)
            .getJSONObject("message").getString("content")
        return parseNumbered(content, texts.size)
    }

    companion object {
        private val NUMBERED_LINE = Regex("(\\d+)[.):]\\s*(.*)")

        fun systemPrompt(source: String, target: String): String {
            val from = if (source == "auto") "" else " from ${languageName(source)}"
            return "Translate numbered lines of OCR text from one phone screen$from into ${languageName(target)}. " +
                "Lines are context for each other. Natural wording, fix OCR errors, keep names and numbers. " +
                "Output only the same numbers: N. translation"
        }

        fun languageName(code: String): String =
            Locale.forLanguageTag(code).getDisplayLanguage(Locale.ENGLISH).ifBlank { code }

        /** "1. first\n2. second"; a block never spans lines, so a stray newline is flattened. */
        fun numbered(texts: List<String>): String =
            texts.mapIndexed { i, text -> "${i + 1}. ${text.replace('\n', ' ')}" }.joinToString("\n")

        /**
         * One answer per input; a line the model skipped stays blank (that block gets no label instead of
         * failing the screen). The last line with a number wins, so reasoning text before the answer is ignored.
         */
        fun parseNumbered(content: String, count: Int): List<String> {
            val answers = MutableList(count) { "" }
            for (line in content.lines()) {
                val match = NUMBERED_LINE.matchEntire(line.trim()) ?: continue
                val index = match.groupValues[1].toIntOrNull()?.minus(1) ?: continue
                if (index in 0 until count) answers[index] = match.groupValues[2].trim()
            }
            return answers
        }
    }
}
