package com.ambatrans.app.translate

import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

class ModelManagerTest {
    @Test
    fun `English pair needs exactly source and target`() {
        assertEquals(listOf("en", "id"), ModelManager.requiredModels("en", "id"))
        assertEquals(listOf("id", "en"), ModelManager.requiredModels("id", "en"))
    }

    @Test
    fun `pair without English also needs English for the pivot`() {
        assertEquals(listOf("ja", "id", "en"), ModelManager.requiredModels("ja", "id"))
    }

    @Test
    fun `auto source needs only target models`() {
        assertEquals(listOf("id", "en"), ModelManager.requiredModels("auto", "id"))
        assertEquals(listOf("en"), ModelManager.requiredModels("auto", "en"))
    }

    @Test
    fun `status is ready when all required models are downloaded`() = runBlocking {
        val manager = ModelManager({ setOf("en", "id", "fr") }, { _, _ -> })
        assertEquals(ModelStatus(true, emptyList()), manager.getStatus("en", "id"))
    }

    @Test
    fun `status lists missing models`() = runBlocking {
        val manager = ModelManager({ setOf("en") }, { _, _ -> })
        val status = manager.getStatus("ja", "id")
        assertFalse(status.ready)
        assertEquals(listOf("ja", "id"), status.missing)
    }

    @Test
    fun `download forwards the pair`() = runBlocking {
        var requested: Pair<String, String>? = null
        val manager = ModelManager({ emptySet() }, { s, t -> requested = s to t })
        manager.download("en", "id")
        assertEquals("en" to "id", requested)
    }

    @Test
    fun `download failures are wrapped`() {
        val manager = ModelManager({ emptySet() }, { _, _ -> error("no network") })
        val e = assertThrows(ModelDownloadException::class.java) { runBlocking { manager.download("en", "id") } }
        assertTrue(e.cause is IllegalStateException)
    }
}
