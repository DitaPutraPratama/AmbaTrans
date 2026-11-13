package com.ambatrans.app.ocr

import android.graphics.Bitmap
import com.ambatrans.app.pipeline.TextBlock
import com.ambatrans.app.translate.await
import com.google.mlkit.vision.common.InputImage

/** Runs ML Kit OCR and returns one [TextBlock] per recognized line (ADR-013). */
class OcrEngine(private val recognizers: RecognizerProvider) {
    suspend fun recognize(bitmap: Bitmap, script: OcrScript): List<TextBlock> {
        val result = recognizers.get(script).process(InputImage.fromBitmap(bitmap, 0)).await()
        return result.textBlocks
            .flatMap { it.lines }
            .mapNotNull { line ->
                val box = line.boundingBox ?: return@mapNotNull null
                TextBlock(line.text, box.left, box.top, box.right, box.bottom)
            }
    }
}
