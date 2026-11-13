package com.ambatrans.app.access

import android.accessibilityservice.AccessibilityService
import android.graphics.Rect
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import com.ambatrans.app.pipeline.TextBlock

/**
 * Optional "accurate mode" helper. It only reads on-screen text and bounds and reports scrolling;
 * it never performs gestures or actions and stores or sends nothing (CLAUDE.md).
 */
class AmbaAccessibilityService : AccessibilityService() {
    override fun onServiceConnected() {
        super.onServiceConnected()
        AccessibilityBridge.attach(::readWindow)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.packageName == packageName) return // our own bubble and overlay
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_SCROLLED) AccessibilityBridge.notifyScrolled()
    }

    override fun onInterrupt() = Unit

    override fun onUnbind(intent: android.content.Intent?): Boolean {
        AccessibilityBridge.detach()
        return super.onUnbind(intent)
    }

    private fun readWindow(): List<TextBlock> {
        val root = rootInActiveWindow ?: return emptyList()
        val out = mutableListOf<TextBlock>()
        try {
            collect(root, out, depth = 0)
        } finally {
            root.recycle()
        }
        return out
    }

    private fun collect(node: AccessibilityNodeInfo, out: MutableList<TextBlock>, depth: Int) {
        if (depth > MAX_DEPTH || !node.isVisibleToUser) return
        val text = (node.text ?: node.contentDescription)?.toString()?.trim().orEmpty()
        if (text.isNotEmpty() && node.packageName != packageName) {
            val bounds = Rect().also { node.getBoundsInScreen(it) }
            if (bounds.width() > 0 && bounds.height() > 0) {
                out += TextBlock(text, bounds.left, bounds.top, bounds.right, bounds.bottom)
            }
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            try {
                collect(child, out, depth + 1)
            } finally {
                child.recycle()
            }
        }
    }

    private companion object {
        const val MAX_DEPTH = 40
    }
}
