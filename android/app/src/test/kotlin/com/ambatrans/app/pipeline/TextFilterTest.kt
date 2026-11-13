package com.ambatrans.app.pipeline

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class TextFilterTest {
    @Test
    fun `numbers symbols and prices are not translatable`() {
        listOf(
            "", "   ", "123", "12.000", "1,234.56", "Rp 12.000", "Rp12.000", "IDR 1,000", "USD 9.99", "$9.99",
            "€ 5,00", "100%", "★★★", "---", "#1", "12:30", "(5)", "©", "A", "x",
        ).forEach { assertFalse("'$it' should be dropped", TextFilter.isTranslatable(it)) }
    }

    @Test
    fun `real words are translatable`() {
        listOf("Hello", "OK", "Add to cart", "Sale 50%", "5 kg", "Total: Rp 12.000", "Hola señor")
            .forEach { assertTrue("'$it' should be kept", TextFilter.isTranslatable(it)) }
    }

    @Test
    fun `a single CJK character or kana is kept`() {
        listOf("中", "設定", "あ", "カ", "한", "한국어").forEach {
            assertTrue("'$it' should be kept", TextFilter.isTranslatable(it))
        }
    }

    @Test
    fun `filter keeps order and boxes of the surviving blocks`() {
        val keep = TextBlock("Add to cart", 10, 20, 110, 50)
        val blocks = listOf(TextBlock("Rp 12.000", 0, 0, 10, 10), keep, TextBlock("99", 5, 5, 9, 9))
        assertEquals(listOf(keep), TextFilter.filter(blocks))
    }

    @Test
    fun `block geometry`() {
        val block = TextBlock("x", 10, 20, 110, 50)
        assertEquals(100, block.width)
        assertEquals(30, block.height)
    }
}
