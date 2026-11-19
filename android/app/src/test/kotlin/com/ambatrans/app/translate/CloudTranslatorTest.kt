package com.ambatrans.app.translate

import com.ambatrans.app.data.SettingsStore
import com.ambatrans.app.data.fakePrefs
import com.ambatrans.app.pipeline.TextBlock
import com.ambatrans.app.pipeline.TranslateError
import kotlinx.coroutines.runBlocking
import org.json.JSONArray
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

class CloudTranslatorTest {
    private class FakeHttp(private val response: String) : JsonPost {
        var url = ""
        var headers = emptyMap<String, String>()
        var body = JSONObject()

        override suspend fun post(url: String, headers: Map<String, String>, body: String): String {
            this.url = url
            this.headers = headers
            this.body = JSONObject(body)
            return response
        }
    }

    private fun blocks(vararg texts: String) = texts.mapIndexed { i, t -> TextBlock(t, 0, i * 30, 100, i * 30 + 20) }

    @Test
    fun `DeepL sends all texts in one request and picks the free host for free keys`() = runBlocking {
        val http = FakeHttp("""{"translations":[{"text":"Halo"},{"text":"Dunia"}]}""")
        val out = DeepLTranslator("abc:fx", http).translate(listOf("Hello", "World"), "en", "id")
        assertEquals(listOf("Halo", "Dunia"), out)
        assertEquals("https://api-free.deepl.com/v2/translate", http.url)
        assertEquals("DeepL-Auth-Key abc:fx", http.headers["Authorization"])
        assertEquals("ID", http.body.getString("target_lang"))
        assertEquals("EN", http.body.getString("source_lang"))
        assertEquals(2, http.body.getJSONArray("text").length())
    }

    @Test
    fun `DeepL omits the source for auto-detect and maps variant targets`() = runBlocking {
        val http = FakeHttp("""{"translations":[{"text":"Hi"}]}""")
        DeepLTranslator("pro-key", http).translate(listOf("Halo"), "auto", "en")
        assertEquals("https://api.deepl.com/v2/translate", http.url)
        assertTrue(!http.body.has("source_lang"))
        assertEquals("EN-US", http.body.getString("target_lang"))
    }

    @Test
    fun `Groq uses the chosen model and reads the translations array from the reply`() = runBlocking {
        val content = JSONObject().put("translations", JSONArray(listOf("Halo", "Dunia"))).toString()
        val reply = JSONObject().put(
            "choices",
            JSONArray().put(JSONObject().put("message", JSONObject().put("content", content))),
        )
        val http = FakeHttp(reply.toString())
        val out = GroqTranslator("gsk", "my-model", http).translate(listOf("Hello", "World"), "en", "id")
        assertEquals(listOf("Halo", "Dunia"), out)
        assertEquals("Bearer gsk", http.headers["Authorization"])
        assertEquals("my-model", http.body.getString("model"))
        val messages = http.body.getJSONArray("messages")
        assertTrue(messages.getJSONObject(0).getString("content").contains("into Indonesian"))
        assertEquals("[\"Hello\",\"World\"]", messages.getJSONObject(1).getString("content"))
    }

    @Test
    fun `translateAll pairs blocks with answers and skips blank ones`() = runBlocking {
        val api = CloudTranslator { texts, _, _ -> texts.map { if (it == "skip") " " else "<$it>" } }
        val out = api.translateAll(blocks("a", "skip", "b"), "en", "id")
        assertEquals(listOf("a" to "<a>", "b" to "<b>"), out.map { it.block.text to it.translated })
    }

    @Test
    fun `a reply with the wrong number of translations fails`() {
        val api = CloudTranslator { _, _, _ -> listOf("only one") }
        assertThrows(TranslationFailedException::class.java) {
            runBlocking { api.translateAll(blocks("a", "b"), "en", "id") }
        }
    }

    @Test
    fun `engine choice - ML Kit is null, cloud without a key is reported`() {
        val data = mutableMapOf<String, Any>()
        val store = SettingsStore(fakePrefs(data))
        assertNull(CloudTranslators.forEngine(store))
        store.set("translate_engine", "deepl")
        val e = assertThrows(CloudException::class.java) { CloudTranslators.forEngine(store) }
        assertEquals(TranslateError.API_KEY_MISSING, e.error)
        store.set("deepl_api_key", "k:fx")
        assertTrue(CloudTranslators.forEngine(store) is DeepLTranslator)
    }

    @Test
    fun `HTTP codes map to the errors the user can act on`() {
        assertEquals(TranslateError.API_KEY_REJECTED, HttpJsonPost.errorFor(403))
        assertEquals(TranslateError.QUOTA_EXCEEDED, HttpJsonPost.errorFor(456))
        assertEquals(TranslateError.QUOTA_EXCEEDED, HttpJsonPost.errorFor(429))
        assertEquals(TranslateError.FAILED, HttpJsonPost.errorFor(500))
    }
}
