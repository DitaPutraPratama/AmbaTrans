package com.ambatrans.app.capture

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import com.ambatrans.app.service.OverlayService

/**
 * Invisible activity that shows the system screen-capture dialog and forwards the result to the service.
 * Android 14+ needs the consent before the service may declare the mediaProjection type.
 */
class CaptureConsentActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (savedInstanceState != null) return // re-created after rotation: the dialog is already showing
        val manager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        @Suppress("DEPRECATION")
        startActivityForResult(manager.createScreenCaptureIntent(), REQUEST_CAPTURE)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CAPTURE) {
            val intent = if (resultCode == RESULT_OK && data != null) {
                OverlayService.projectionGrantedIntent(this, resultCode, data)
            } else {
                OverlayService.projectionDeniedIntent(this)
            }
            startService(intent)
        }
        finish()
    }

    private companion object {
        const val REQUEST_CAPTURE = 1
    }
}
