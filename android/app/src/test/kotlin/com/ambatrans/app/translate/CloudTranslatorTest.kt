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
    fun `AI chat sends numbered lines and reads numbered answers`() = runBlocking {
        val reply = JSONObject().put(
            "choices",
            JSONArray().put(JSONObject().put("message", JSONObject().put("content", "1. Halo\n2. Dunia"))),
        )
        val http = FakeHttp(reply.toString())
        val out = ChatTranslator(
            "https://x/chat",
            "gsk",
            "my-model",
            http,
        ).translate(listOf("Hello", "World"), "en", "id")
        assertEquals(listOf("Halo", "Dunia"), out)
        assertEquals("Bearer gsk", http.headers["Authorization"])
        assertEquals("my-model", http.body.getString("model"))
        val messages = http.body.getJSONArray("messages")
        assertTrue(messages.getJSONObject(0).getString("content").contains("into Indonesian"))
        assertEquals("1. Hello\n2. World", messages.getJSONObject(1).getString("content"))
    }

    @Test
    fun `numbered answers - skipped lines stay blank, reasoning before the answer is ignored`() {
        val content = "Thinking: 1. draft\n```\n1) Halo\n3: Tiga\n9. out of range\n```"
        assertEquals(listOf("Halo", "", "Tiga"), ChatTranslator.parseNumbered(content, 3))
    }

    @Test
    fun `the prompt stays short`() {
        assertTrue(ChatTranslator.systemPrompt("en", "id").length < 260)
        assertTrue(!ChatTranslator.systemPrompt("auto", "id").contains("English"))
        assertTrue(ChatTranslator.systemPrompt("en", "id").contains("from English"))
    }

    @Test
    fun `repeated texts are translated once`() = runBlocking {
        val sent = mutableListOf<List<String>>()
        val api = CloudTranslator { texts, _, _ ->
            sent += texts
            texts.map { "<$it>" }
        }
        val out = api.translateAll(blocks("Like", "Post", "Like"), "en", "id")
        assertEquals(listOf(listOf("Like", "Post")), sent)
        assertEquals(listOf("<Like>", "<Post>", "<Like>"), out.map { it.translated })
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
        store.set("translate_engine", "gemini")
        store.set("gemini_api_key", "g")
        assertTrue(CloudTranslators.forEngine(store) is ChatTranslator)
    }

    @Test
    fun `HTTP codes map to the errors the user can act on`() {
        assertEquals(TranslateError.API_KEY_REJECTED, HttpJsonPost.errorFor(403))
        assertEquals(TranslateError.MODEL_NOT_FOUND, HttpJsonPost.errorFor(404))
        assertEquals(TranslateError.QUOTA_EXCEEDED, HttpJsonPost.errorFor(456))
        assertEquals(TranslateError.QUOTA_EXCEEDED, HttpJsonPost.errorFor(429))
        assertEquals(TranslateError.FAILED, HttpJsonPost.errorFor(500))
    }
}
