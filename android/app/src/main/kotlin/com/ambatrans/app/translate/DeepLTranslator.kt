package com.ambatrans.app.translate

import org.json.JSONArray
import org.json.JSONObject

/** DeepL API v2 (https://developers.deepl.com/docs/api-reference/translate). */
class DeepLTranslator(private val apiKey: String, private val http: JsonPost) : CloudTranslator {
    override suspend fun translate(texts: List<String>, source: String, target: String): List<String> {
        val body = JSONObject().put("text", JSONArray(texts)).put("target_lang", targetCode(target))
        if (source != AUTO) body.put("source_lang", source.substringBefore('-').uppercase())
        val response = http.post(endpoint(apiKey), mapOf("Authorization" to "DeepL-Auth-Key $apiKey"), body.toString())
        val translations = JSONObject(response).getJSONArray("translations")
        return List(translations.length()) { translations.getJSONObject(it).getString("text") }
    }

    companion object {
        private const val AUTO = "auto"
        private const val FREE_URL = "https://api-free.deepl.com/v2/translate"
        private const val PRO_URL = "https://api.deepl.com/v2/translate"

        /** Free-plan keys end in ":fx" and only work on the free host. */
        fun endpoint(apiKey: String) = if (apiKey.endsWith(":fx")) FREE_URL else PRO_URL

        /** ML Kit code -> DeepL target code; DeepL wants a variant for English and Portuguese. */
        // ponytail: no per-engine language list; a target DeepL lacks fails with the generic error toast.
        fun targetCode(lang: String): String = when (lang) {
            "en" -> "EN-US"
            "pt" -> "PT-BR"
            "zh" -> "ZH-HANS"
            "no" -> "NB"
            else -> lang.uppercase()
        }
    }
}
