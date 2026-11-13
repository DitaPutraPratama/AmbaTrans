package com.ambatrans.app.service

import org.junit.After
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ServiceStateHolderTest {
    @After
    fun reset() = ServiceStateHolder.set(false)

    @Test
    fun `starts as not running and follows set`() {
        assertFalse(ServiceStateHolder.running.value)
        ServiceStateHolder.set(true)
        assertTrue(ServiceStateHolder.running.value)
        ServiceStateHolder.set(false)
        assertFalse(ServiceStateHolder.running.value)
    }
}
