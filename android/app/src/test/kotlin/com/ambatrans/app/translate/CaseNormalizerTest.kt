package com.ambatrans.app.translate

import org.junit.Assert.assertEquals
import org.junit.Test

class CaseNormalizerTest {
    @Test
    fun `all-caps sentences become sentence case`() {
        assertEquals("I don't know. What do you want?", CaseNormalizer.sentenceCase("I DON'T KNOW. WHAT DO YOU WANT?"))
        assertEquals("Game over", CaseNormalizer.sentenceCase("GAME OVER"))
    }

    @Test
    fun `mixed case, single words and caseless scripts are left alone`() {
        for (text in listOf("Hello World", "SETTINGS", "USA", "こんにちは 世界", "123 456", "")) {
            assertEquals(text, CaseNormalizer.sentenceCase(text))
        }
    }
}
