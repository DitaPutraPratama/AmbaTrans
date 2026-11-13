package com.ambatrans.app.ocr

import com.google.mlkit.nl.translate.TranslateLanguage
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class LanguageCatalogTest {
    @Test
    fun `maps CJK and Devanagari languages to their scripts`() {
        assertEquals(OcrScript.CHINESE, LanguageCatalog.scriptFor("zh"))
        assertEquals(OcrScript.JAPANESE, LanguageCatalog.scriptFor("ja"))
        assertEquals(OcrScript.KOREAN, LanguageCatalog.scriptFor("ko"))
        assertEquals(OcrScript.DEVANAGARI, LanguageCatalog.scriptFor("hi"))
        assertEquals(OcrScript.DEVANAGARI, LanguageCatalog.scriptFor("mr"))
    }

    @Test
    fun `Latin-script languages use the Latin recognizer`() {
        listOf("en", "id", "es", "fr", "de", "vi", "tr").forEach {
            assertEquals(OcrScript.LATIN, LanguageCatalog.scriptFor(it))
        }
    }

    @Test
    fun `languages OCR cannot read, auto and blank have no script`() {
        listOf("ru", "ar", "th", "el", "auto", "").forEach { assertNull("'$it'", LanguageCatalog.scriptFor(it)) }
    }

    @Test
    fun `every ML Kit translation language is either mapped or explicitly unsupported`() {
        for (code in TranslateLanguage.getAllLanguages()) {
            val mapped = LanguageCatalog.scriptFor(code) != null
            val unsupported = code in LanguageCatalog.OCR_UNSUPPORTED
            assertTrue("$code must be exactly one of mapped/unsupported", mapped != unsupported)
        }
    }

    @Test
    fun `source languages exclude the unsupported ones`() {
        val sources = LanguageCatalog.sourceLanguages(listOf("en", "ru", "ja", "ar"))
        assertEquals(listOf("en", "ja"), sources)
        assertNotNull(LanguageCatalog.scriptFor(sources.first()))
    }
}
