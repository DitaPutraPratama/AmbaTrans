package com.ambatrans.app.ocr

enum class OcrScript { LATIN, CHINESE, DEVANAGARI, JAPANESE, KOREAN }

/** Maps a source language (BCP-47) to the ML Kit text recognizer that can read it. */
object LanguageCatalog {
    private val CHINESE = setOf("zh")
    private val JAPANESE = setOf("ja")
    private val KOREAN = setOf("ko")
    private val DEVANAGARI = setOf("hi", "mr")

    /** ML Kit translates these, but no bundled recognizer reads their scripts (Cyrillic, Arabic, Indic, ...). */
    val OCR_UNSUPPORTED = setOf(
        "ar", "be", "bg", "bn", "el", "fa", "gu", "he", "ka", "kn", "mk", "ru", "ta", "te", "th", "uk", "ur",
    )

    /** The recognizer script for [code], or null when OCR cannot read the language (or for "auto"). */
    fun scriptFor(code: String): OcrScript? = when {
        code in CHINESE -> OcrScript.CHINESE
        code in JAPANESE -> OcrScript.JAPANESE
        code in KOREAN -> OcrScript.KOREAN
        code in DEVANAGARI -> OcrScript.DEVANAGARI
        code in OCR_UNSUPPORTED || code == "auto" || code.isBlank() -> null
        else -> OcrScript.LATIN
    }

    /** Languages usable as source: translatable and readable by OCR. */
    fun sourceLanguages(allTranslatable: List<String>): List<String> = allTranslatable.filter { scriptFor(it) != null }
}
