package com.ambatrans.app.data

import android.content.SharedPreferences

class InvalidSettingException(message: String) : IllegalArgumentException(message)

/**
 * Single owner of the `ambatrans_prefs` file. Keys, defaults and constraints follow docs/DATABASE.md.
 */
class SettingsStore(private val prefs: SharedPreferences) {
    val sourceLang: String get() = prefs.getString(KEY_SOURCE_LANG, DEFAULT_SOURCE_LANG) ?: DEFAULT_SOURCE_LANG
    val targetLang: String get() = prefs.getString(KEY_TARGET_LANG, DEFAULT_TARGET_LANG) ?: DEFAULT_TARGET_LANG
    val bubbleEdge: String get() = prefs.getString(KEY_BUBBLE_EDGE, DEFAULT_BUBBLE_EDGE) ?: DEFAULT_BUBBLE_EDGE
    val bubbleYFraction: Float get() = prefs.getFloat(KEY_BUBBLE_Y_FRACTION, DEFAULT_BUBBLE_Y_FRACTION)
    val onboardingDone: Boolean get() = prefs.getBoolean(KEY_ONBOARDING_DONE, false)
    val translateMode: String get() = prefs.getString(KEY_TRANSLATE_MODE, MODE_FULL) ?: MODE_FULL

    /** Overlay label colours as 0xRRGGBB (no alpha; the overlay window sets the opacity). */
    val overlayTextColor: Int get() = prefs.getInt(KEY_OVERLAY_TEXT_COLOR, DEFAULT_OVERLAY_TEXT_COLOR)
    val overlayBgColor: Int get() = prefs.getInt(KEY_OVERLAY_BG_COLOR, DEFAULT_OVERLAY_BG_COLOR)

    /** Label background opacity in percent, on top of the overlay window's own opacity. */
    val overlayBgOpacity: Int get() = prefs.getInt(KEY_OVERLAY_BG_OPACITY, DEFAULT_OVERLAY_BG_OPACITY)

    fun getAll(): Map<String, Any> = mapOf(
        KEY_SCHEMA_VERSION to prefs.getInt(KEY_SCHEMA_VERSION, CURRENT_SCHEMA_VERSION),
        KEY_ONBOARDING_DONE to onboardingDone,
        KEY_SOURCE_LANG to sourceLang,
        KEY_TARGET_LANG to targetLang,
        KEY_BUBBLE_EDGE to bubbleEdge,
        // Doubles: the platform channel codec transports doubles, not floats.
        KEY_BUBBLE_Y_FRACTION to bubbleYFraction.toDouble(),
        KEY_OVERLAY_TEXT_COLOR to overlayTextColor,
        KEY_OVERLAY_BG_COLOR to overlayBgColor,
        KEY_OVERLAY_BG_OPACITY to overlayBgOpacity,
        KEY_TRANSLATE_MODE to translateMode,
    )

    /** Validates and stores one value. Throws [InvalidSettingException] when the rules are violated. */
    fun set(key: String, value: Any?) {
        val editor = prefs.edit()
        when (key) {
            KEY_ONBOARDING_DONE -> editor.putBoolean(key, value.asBoolean(key))
            KEY_SOURCE_LANG -> {
                val lang = value.asLanguage(key, allowAuto = true)
                if (lang == targetLang) throw InvalidSettingException("source_lang must differ from target_lang")
                editor.putString(key, lang)
            }
            KEY_TARGET_LANG -> {
                val lang = value.asLanguage(key, allowAuto = false)
                if (lang == sourceLang) throw InvalidSettingException("target_lang must differ from source_lang")
                editor.putString(key, lang)
            }
            KEY_BUBBLE_EDGE -> {
                if (value != EDGE_LEFT && value != EDGE_RIGHT) throw InvalidSettingException("invalid bubble_edge")
                editor.putString(key, value as String)
            }
            KEY_BUBBLE_Y_FRACTION -> {
                val fraction = (value as? Number)?.toFloat()
                if (fraction == null || !fraction.isFinite() || fraction !in 0f..1f) {
                    throw InvalidSettingException("bubble_y_fraction must be within 0.0..1.0")
                }
                editor.putFloat(key, fraction)
            }
            KEY_OVERLAY_TEXT_COLOR, KEY_OVERLAY_BG_COLOR -> editor.putInt(key, value.asRgb(key))
            KEY_TRANSLATE_MODE -> {
                if (value != MODE_FULL && value != MODE_REGION) throw InvalidSettingException("invalid translate_mode")
                editor.putString(key, value as String)
            }
            KEY_OVERLAY_BG_OPACITY -> {
                val percent = value as? Int
                if (percent == null || percent !in 0..100) throw InvalidSettingException("$key must be 0..100")
                editor.putInt(key, percent)
            }
            else -> throw InvalidSettingException("unknown or read-only key: $key")
        }
        editor.apply()
    }

    /** Brings stored data up to [CURRENT_SCHEMA_VERSION]. Never edit old steps; append new ones. */
    fun migrate() {
        val stored = prefs.getInt(KEY_SCHEMA_VERSION, 0)
        if (stored >= CURRENT_SCHEMA_VERSION) return
        // Version 0 -> 1: fresh install, defaults apply; just stamp the version.
        prefs.edit().putInt(KEY_SCHEMA_VERSION, CURRENT_SCHEMA_VERSION).apply()
    }

    private fun Any?.asBoolean(key: String): Boolean =
        this as? Boolean ?: throw InvalidSettingException("$key must be a bool")

    private fun Any?.asRgb(key: String): Int {
        // Long, not Int: the channel codec sends Dart ints above 2^31 as Long.
        val rgb = (this as? Int)?.toLong() ?: this as? Long
        if (rgb == null || rgb !in 0L..0xFFFFFFL) throw InvalidSettingException("$key must be 0xRRGGBB")
        return rgb.toInt()
    }

    private fun Any?.asLanguage(key: String, allowAuto: Boolean): String {
        val lang = this as? String
        if (lang == null || !((allowAuto && lang == AUTO) || LANG_CODE.matches(lang))) {
            throw InvalidSettingException("invalid language for $key")
        }
        return lang
    }

    companion object {
        const val PREFS_NAME = "ambatrans_prefs"
        const val CURRENT_SCHEMA_VERSION = 1

        const val KEY_SCHEMA_VERSION = "schema_version"
        const val KEY_ONBOARDING_DONE = "onboarding_done"
        const val KEY_SOURCE_LANG = "source_lang"
        const val KEY_TARGET_LANG = "target_lang"
        const val KEY_BUBBLE_EDGE = "bubble_edge"
        const val KEY_BUBBLE_Y_FRACTION = "bubble_y_fraction"
        const val KEY_OVERLAY_TEXT_COLOR = "overlay_text_color"
        const val KEY_OVERLAY_BG_COLOR = "overlay_bg_color"
        const val KEY_OVERLAY_BG_OPACITY = "overlay_bg_opacity"
        const val KEY_TRANSLATE_MODE = "translate_mode"

        const val DEFAULT_SOURCE_LANG = "en"
        const val DEFAULT_TARGET_LANG = "id"
        const val DEFAULT_BUBBLE_EDGE = "right"
        const val DEFAULT_BUBBLE_Y_FRACTION = 0.35f
        const val DEFAULT_OVERLAY_TEXT_COLOR = 0xFFFFFF
        const val DEFAULT_OVERLAY_BG_COLOR = 0x424242
        const val DEFAULT_OVERLAY_BG_OPACITY = 100

        const val EDGE_LEFT = "left"
        const val EDGE_RIGHT = "right"
        const val AUTO = "auto"
        const val MODE_FULL = "full"
        const val MODE_REGION = "region"

        // ponytail: shape check only; membership in the ML Kit language list is enforced once LanguageCatalog exists (T-022).
        private val LANG_CODE = Regex("[a-z]{2,3}(-[A-Za-z0-9]{2,8})*")
    }
}
