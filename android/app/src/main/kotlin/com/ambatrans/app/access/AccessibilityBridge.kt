package com.ambatrans.app.access

import com.ambatrans.app.pipeline.TextBlock
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow

/** Process-wide link between the accessibility service and the rest of the app (F-10). */
object AccessibilityBridge {
    @Volatile
    private var reader: (() -> List<TextBlock>)? = null

    private val scrolls = MutableSharedFlow<Unit>(extraBufferCapacity = 1)

    /** Emits when something on screen scrolled; the overlay is stale from then on. */
    val scrolled: SharedFlow<Unit> get() = scrolls

    val isAvailable: Boolean get() = reader != null

    @Volatile
    private var disabler: (() -> Unit)? = null

    fun attach(read: () -> List<TextBlock>, disableSelf: () -> Unit) {
        reader = read
        disabler = disableSelf
    }

    fun detach() {
        reader = null
        disabler = null
    }

    /** Switches the service off in system settings (only the service itself may do this). */
    fun disable() {
        disabler?.invoke()
    }

    fun notifyScrolled() {
        scrolls.tryEmit(Unit)
    }

    /** Text nodes of the active window, or an empty list when the service is off. */
    fun snapshot(): List<TextBlock> = runCatching { reader?.invoke() }.getOrNull().orEmpty()
}
