package com.ambatrans.app.service

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

/** Process-wide running flag. A killed process resets it to false, which is what Home should show. */
object ServiceStateHolder {
    private val state = MutableStateFlow(false)

    val running: StateFlow<Boolean> get() = state

    fun set(isRunning: Boolean) {
        state.value = isRunning
    }

    private val capture = MutableStateFlow(false)

    /** True while a screen-capture session is live; shown on Home as a missing permission when false. */
    val captureReady: StateFlow<Boolean> get() = capture

    fun setCaptureReady(ready: Boolean) {
        capture.value = ready
    }
}
