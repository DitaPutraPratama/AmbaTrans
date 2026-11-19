package com.ambatrans.app.ocr

import android.graphics.Bitmap
import com.ambatrans.app.pipeline.ScreenRect
import com.ambatrans.app.pipeline.TextBlock
import com.ambatrans.app.translate.await
import com.google.mlkit.vision.common.InputImage

/**
 * Runs ML Kit OCR and returns one [TextBlock] per recognized block (paragraph / speech bubble), so a
 * sentence wrapped over several lines is translated as one sentence (ADR-013).
 */
class OcrEngine(private val recognizers: RecognizerProvider) {
    /** With a [region], only that part of the screenshot is read; boxes stay in screen pixels. */
    suspend fun recognize(bitmap: Bitmap, script: OcrScript, region: ScreenRect? = null): List<TextBlock> {
        if (region == null) return blocksOf(bitmap, script, 0, 0)
        val area = region.clampTo(bitmap.width, bitmap.height) ?: return emptyList()
        val crop = Bitmap.createBitmap(bitmap, area.left, area.top, area.width, area.height)
        return try {
            blocksOf(crop, script, area.left, area.top)
        } finally {
            if (crop !== bitmap) crop.recycle() // memory only, released right after OCR (F-04)
        }
    }

    private suspend fun blocksOf(image: Bitmap, script: OcrScript, dx: Int, dy: Int): List<TextBlock> {
        val result = recognizers.get(script).process(InputImage.fromBitmap(image, 0)).await()
        return result.textBlocks.mapNotNull { block ->
            val box = block.boundingBox ?: return@mapNotNull null
            val lineHeight = block.lines.mapNotNull { it.boundingBox?.height() }.average()
                .takeIf { !it.isNaN() }?.toInt() ?: box.height()
            TextBlock(
                joinLines(block.lines.map { it.text }),
                box.left + dx,
                box.top + dy,
                box.right + dx,
                box.bottom + dy,
                lineHeight,
            )
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
