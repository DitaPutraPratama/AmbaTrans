package com.ambatrans.app.ocr

import android.graphics.Bitmap
import com.ambatrans.app.pipeline.TextBlock
import com.ambatrans.app.translate.await
import com.google.mlkit.vision.common.InputImage

/**
 * Runs ML Kit OCR and returns one [TextBlock] per recognized block (paragraph / speech bubble), so a
 * sentence wrapped over several lines is translated as one sentence (ADR-013).
 */
class OcrEngine(private val recognizers: RecognizerProvider) {
    suspend fun recognize(bitmap: Bitmap, script: OcrScript): List<TextBlock> {
        val result = recognizers.get(script).process(InputImage.fromBitmap(bitmap, 0)).await()
        return result.textBlocks.mapNotNull { block ->
            val box = block.boundingBox ?: return@mapNotNull null
            TextBlock(joinLines(block.lines.map { it.text }), box.left, box.top, box.right, box.bottom)
        }
    }
}

/**
 * Joins wrapped lines into one sentence: a space between lines, none after a CJK character (those
 * scripts do not use spaces), and a trailing hyphen before a letter is treated as a word break ("CON-" + "TINUE").
 */
fun joinLines(lines: List<String>): String = lines.map { it.trim() }.filter { it.isNotEmpty() }
    .fold("") { acc, line ->
        when {
            acc.isEmpty() -> line
            acc.endsWith("-") && line.first().isLetter() -> acc.dropLast(1) + line
            acc.last().isCjk() -> acc + line
            else -> "$acc $line"
        }
    }

private fun Char.isCjk(): Boolean {
    val block = Character.UnicodeBlock.of(this)
    return Character.isIdeographic(code) ||
        block == Character.UnicodeBlock.HIRAGANA ||
        block == Character.UnicodeBlock.KATAKANA ||
        block == Character.UnicodeBlock.CJK_SYMBOLS_AND_PUNCTUATION
}
