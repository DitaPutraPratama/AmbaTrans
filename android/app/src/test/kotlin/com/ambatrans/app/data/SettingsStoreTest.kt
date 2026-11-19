package com.ambatrans.app.data

import android.content.SharedPreferences
import io.mockk.every
import io.mockk.mockk
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Test

/** Map-backed SharedPreferences; only the calls SettingsStore makes. */
internal fun fakePrefs(data: MutableMap<String, Any> = mutableMapOf()): SharedPreferences {
    val prefs = mockk<SharedPreferences>()
    val editor = mockk<SharedPreferences.Editor>()
    every { prefs.getString(any(), any()) } answers { data[firstArg()] as String? ?: secondArg() }
    every { prefs.getBoolean(any(), any()) } answers { data[firstArg()] as Boolean? ?: secondArg() }
    every { prefs.getInt(any(), any()) } answers { data[firstArg()] as Int? ?: secondArg() }
    every { prefs.getFloat(any(), any()) } answers { data[firstArg()] as Float? ?: secondArg() }
    every { prefs.edit() } returns editor
    every { editor.putString(any(), any()) } answers { editor.also { data[firstArg()] = secondArg<String>() } }
    every { editor.putBoolean(any(), any()) } answers { editor.also { data[firstArg()] = secondArg<Boolean>() } }
    every { editor.putInt(any(), any()) } answers { editor.also { data[firstArg()] = secondArg<Int>() } }
    every { editor.putFloat(any(), any()) } answers { editor.also { data[firstArg()] = secondArg<Float>() } }
    every { editor.apply() } returns Unit
    return prefs
}

class SettingsStoreTest {
    private fun store(data: MutableMap<String, Any> = mutableMapOf()) = SettingsStore(fakePrefs(data))

    @Test
    fun `defaults are returned when nothing is stored`() {
        val all = store().getAll()
        assertEquals("en", all["source_lang"])
        assertEquals("id", all["target_lang"])
        assertEquals("right", all["bubble_edge"])
        assertEquals(0.35, all["bubble_y_fraction"] as Double, 0.0001)
        assertEquals(false, all["onboarding_done"])
        assertEquals(1, all["schema_version"])
    }

    @Test
    fun `valid values are stored and read back`() {
        val s = store()
        s.set("source_lang", "ja")
        s.set("target_lang", "en")
        s.set("bubble_edge", "left")
        s.set("bubble_y_fraction", 0.8)
        s.set("onboarding_done", true)
        assertEquals("ja", s.sourceLang)
        assertEquals("en", s.targetLang)
        assertEquals("left", s.bubbleEdge)
        assertEquals(0.8f, s.bubbleYFraction, 0.0001f)
        assertEquals(true, s.onboardingDone)
    }

    @Test
    fun `auto is allowed only as source language`() {
        val s = store()
        s.set("source_lang", "auto")
        assertEquals("auto", s.sourceLang)
        assertThrows(InvalidSettingException::class.java) { s.set("target_lang", "auto") }
    }

    @Test
    fun `source equal to target is rejected and nothing changes`() {
        val s = store()
        assertThrows(InvalidSettingException::class.java) { s.set("source_lang", "id") }
        assertThrows(InvalidSettingException::class.java) { s.set("target_lang", "en") }
        assertEquals("en", s.sourceLang)
        assertEquals("id", s.targetLang)
    }

    @Test
    fun `invalid values are rejected`() {
        val s = store()
        val bad =
            listOf(
                "bubble_edge" to "top",
                "bubble_edge" to 1,
                "bubble_y_fraction" to 1.5,
                "bubble_y_fraction" to -0.1,
                "bubble_y_fraction" to Double.NaN,
                "bubble_y_fraction" to "0.5",
                "onboarding_done" to "yes",
                "source_lang" to "",
                "source_lang" to "English",
                "target_lang" to null,
                "schema_version" to 2,
                "unknown_key" to "x",
            )
        for ((key, value) in bad) {
            assertThrows("$key=$value", InvalidSettingException::class.java) { s.set(key, value) }
        }
    }

    @Test
    fun `overlay colours default to white on grey and accept 0xRRGGBB only`() {
        val s = store()
        assertEquals(0xFFFFFF, s.getAll()["overlay_text_color"])
        assertEquals(0x424242, s.getAll()["overlay_bg_color"])
        s.set("overlay_text_color", 0x000000)
        s.set("overlay_bg_color", 0xFFEB3BL) // Long, as the channel may deliver it
        assertEquals(0x000000, s.overlayTextColor)
        assertEquals(0xFFEB3B, s.overlayBgColor)
        assertThrows(InvalidSettingException::class.java) { s.set("overlay_bg_color", 0xFF424242L) }
        assertThrows(InvalidSettingException::class.java) { s.set("overlay_text_color", -1) }
        assertThrows(InvalidSettingException::class.java) { s.set("overlay_text_color", "#FFFFFF") }
        assertEquals(0xFFEB3B, s.overlayBgColor)
    }

    @Test
    fun `overlay background opacity defaults to 100 and accepts 0 to 100`() {
        val s = store()
        assertEquals(100, s.getAll()["overlay_bg_opacity"])
        s.set("overlay_bg_opacity", 0)
        assertEquals(0, s.overlayBgOpacity)
        s.set("overlay_bg_opacity", 40)
        assertThrows(InvalidSettingException::class.java) { s.set("overlay_bg_opacity", 101) }
        assertThrows(InvalidSettingException::class.java) { s.set("overlay_bg_opacity", -1) }
        assertThrows(InvalidSettingException::class.java) { s.set("overlay_bg_opacity", 0.5) }
        assertEquals(40, s.overlayBgOpacity)
    }

    @Test
    fun `translate mode defaults to full screen and accepts full or region only`() {
        val s = store()
        assertEquals("full", s.getAll()["translate_mode"])
        s.set("translate_mode", "region")
        assertEquals("region", s.translateMode)
        assertThrows(InvalidSettingException::class.java) { s.set("translate_mode", "half") }
        assertEquals("region", s.translateMode)
    }

    @Test
    fun `engine defaults to ML Kit and API keys are stored trimmed per engine`() {
        val s = store()
        assertEquals("mlkit", s.getAll()["translate_engine"])
        assertEquals("", s.apiKey("deepl"))
        s.set("translate_engine", "groq")
        s.set("groq_api_key", "  gsk_abc  ")
        assertEquals("groq", s.translateEngine)
        assertEquals("gsk_abc", s.apiKey("groq"))
        assertEquals("", s.getAll()["deepl_api_key"])
        assertThrows(InvalidSettingException::class.java) { s.set("translate_engine", "bing") }
        assertThrows(InvalidSettingException::class.java) { s.set("deepl_api_key", "a b") }
        assertThrows(InvalidSettingException::class.java) { s.set("deepl_api_key", 5) }
        assertEquals("groq", s.translateEngine)
    }

    @Test
    fun `AI models default per provider and an empty model is rejected`() {
        val s = store()
        assertEquals("llama-3.3-70b-versatile", s.getAll()["groq_model"])
        assertEquals("", s.getAll()["gemini_api_key"])
        s.set("gemini_model", " gemini-x ")
        assertEquals("gemini-x", s.model("gemini"))
        assertThrows(InvalidSettingException::class.java) { s.set("gemini_model", "  ") }
        assertThrows(InvalidSettingException::class.java) { s.set("deepl_model", "x") }
        assertEquals("gemini-x", s.model("gemini"))
    }

    @Test
    fun `migrate stamps a fresh install with the current version`() {
        val data = mutableMapOf<String, Any>()
        val s = store(data)
        s.migrate()
        assertEquals(SettingsStore.CURRENT_SCHEMA_VERSION, data["schema_version"])
    }

    @Test
    fun `migrate leaves newer or equal versions and user data untouched`() {
        val data = mutableMapOf<String, Any>("schema_version" to 99, "source_lang" to "ja")
        store(data).migrate()
        assertEquals(99, data["schema_version"])
        assertEquals("ja", data["source_lang"])
        assertFalse(data.containsKey("target_lang"))
    }
}
