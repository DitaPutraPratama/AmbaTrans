package com.ambatrans.app.ocr

import org.junit.Assert.assertEquals
import org.junit.Test

class JoinLinesTest {
    @Test
    fun `wrapped lines become one sentence`() {
        assertEquals(
            "HE MIGHT TRY TO THREATEN US USING THE MAGIC CIRCLE AS AN EXCUSE,",
            joinLines(listOf("HE MIGHT TRY TO", "THREATEN US USING THE ", " MAGIC CIRCLE AS AN EXCUSE,")),
        )
    }

    @Test
    fun `hyphen at line end joins the word`() {
        assertEquals("CONTINUE now", joinLines(listOf("CON-", "TINUE now")))
    }

    @Test
    fun `cjk lines join without space`() {
        assertEquals("魔法陣を口実に", joinLines(listOf("魔法陣を", "口実に")))
    }

    @Test
    fun `blank lines are skipped`() {
        assertEquals("a b", joinLines(listOf("a", "  ", "b")))
        assertEquals("", joinLines(emptyList()))
    }
}
