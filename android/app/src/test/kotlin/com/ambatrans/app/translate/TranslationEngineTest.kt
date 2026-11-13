package com.ambatrans.app.translate

import com.ambatrans.app.pipeline.TextBlock
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

private class FakeClient(val reply: (String) -> String) : TranslatorClient {
    var closed = false

    override suspend fun translate(text: String) = reply(text)

    override fun close() {
        closed = true
    }
}

class TranslationEngineTest {
    private val models = mockk<ModelManager>()
    private val created = mutableListOf<Pair<String, String>>()
    private val clients = mutableListOf<FakeClient>()
    private var reply: (String) -> String = { "ID:$it" }

    private fun engine() = TranslationEngine(models) { s, t ->
        created += s to t
        FakeClient { reply(it) }.also { clients += it }
    }

    private fun block(text: String, top: Int = 0) = TextBlock(text, 0, top, 100, top + 20)

    private fun ready(value: Boolean = true) {
        coEvery { models.getStatus(any(), any()) } returns ModelStatus(value, if (value) emptyList() else listOf("id"))
    }

    @Test
    fun `translates every block in order and keeps its box`() = runBlocking {
        ready()
        val result = engine().translateAll(listOf(block("a", 0), block("b", 30)), "en", "id")
        assertEquals(listOf("ID:a", "ID:b"), result.map { it.translated })
        assertEquals(listOf(0, 30), result.map { it.block.top })
    }

    @Test
    fun `a failing block is skipped and the rest are kept`() = runBlocking {
        ready()
        reply = { if (it == "bad") error("boom") else "ok:$it" }
        val result = engine().translateAll(listOf(block("a"), block("bad"), block("c")), "en", "id")
        assertEquals(listOf("ok:a", "ok:c"), result.map { it.translated })
    }

    @Test
    fun `blank translations are skipped`() = runBlocking {
        ready()
        reply = { if (it == "x") "  " else it }
        val result = engine().translateAll(listOf(block("x"), block("y")), "en", "id")
        assertEquals(listOf("y"), result.map { it.translated })
    }

    @Test
    fun `fails when every block fails`() {
        ready()
        reply = { error("boom") }
        assertThrows(TranslationFailedException::class.java) {
            runBlocking { engine().translateAll(listOf(block("a"), block("b")), "en", "id") }
        }
    }

    @Test
    fun `missing models fail before any client is created`() {
        ready(false)
        assertThrows(ModelNotReadyException::class.java) {
            runBlocking { engine().translateAll(listOf(block("a")), "en", "id") }
        }
        assertTrue(created.isEmpty())
    }

    @Test
    fun `no blocks means no work and no model check`() = runBlocking {
        assertEquals(emptyList<Any>(), engine().translateAll(emptyList(), "en", "id"))
        assertTrue(created.isEmpty())
    }

    @Test
    fun `client is reused per pair and replaced when the pair changes`() = runBlocking {
        ready()
        val engine = engine()
        engine.translateAll(listOf(block("a")), "en", "id")
        engine.translateAll(listOf(block("b")), "en", "id")
        assertEquals(listOf("en" to "id"), created)

        engine.translateAll(listOf(block("c")), "ja", "id")
        assertEquals(listOf("en" to "id", "ja" to "id"), created)
        assertTrue(clients[0].closed)
        assertEquals(false, clients[1].closed)

        engine.close()
        assertTrue(clients[1].closed)
    }

    @Test
    fun `cancellation is propagated, not treated as a block failure`() {
        ready()
        reply = { throw CancellationException("cancelled") }
        assertThrows(CancellationException::class.java) {
            runBlocking { engine().translateAll(listOf(block("a")), "en", "id") }
        }
    }
}
