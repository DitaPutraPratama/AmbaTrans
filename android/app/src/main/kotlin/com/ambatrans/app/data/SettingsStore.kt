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
    val accessibilityMode: Boolean get() = prefs.getBoolean(KEY_ACCESSIBILITY_MODE, false)

    fun getAll(): Map<String, Any> = mapOf(
        KEY_SCHEMA_VERSION to prefs.getInt(KEY_SCHEMA_VERSION, CURRENT_SCHEMA_VERSION),
        KEY_ONBOARDING_DONE to onboardingDone,
        KEY_SOURCE_LANG to sourceLang,
        KEY_TARGET_LANG to targetLang,
        KEY_BUBBLE_EDGE to bubbleEdge,
        // Doubles: the platform channel codec transports doubles, not floats.
        KEY_BUBBLE_Y_FRACTION to bubbleYFraction.toDouble(),
        KEY_ACCESSIBILITY_MODE to accessibilityMode,
    )

    /** Validates and stores one value. Throws [InvalidSettingException] when the rules are violated. */
    fun set(key: String, value: Any?) {
        val editor = prefs.edit()
        when (key) {
            KEY_ONBOARDING_DONE -> editor.putBoolean(key, value.asBoolean(key))
            KEY_ACCESSIBILITY_MODE -> editor.putBoolean(key, value.asBoolean(key))
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
        const val KEY_ACCESSIBILITY_MODE = "accessibility_mode"

        const val DEFAULT_SOURCE_LANG = "en"
        const val DEFAULT_TARGET_LANG = "id"
        const val DEFAULT_BUBBLE_EDGE = "right"
        const val DEFAULT_BUBBLE_Y_FRACTION = 0.35f

        const val EDGE_LEFT = "left"
        const val EDGE_RIGHT = "right"
        const val AUTO = "auto"

        // ponytail: shape check only; membership in the ML Kit language list is enforced once LanguageCatalog exists (T-022).
        private val LANG_CODE = Regex("[a-z]{2,3}(-[A-Za-z0-9]{2,8})*")
    }
}
