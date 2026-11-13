package com.ambatrans.app.bridge

import android.Manifest
import android.app.Activity
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings

/** Thin wrapper over the platform calls behind the `permissions` channel. */
class AndroidPermissions(private val activity: Activity) {
    private var pendingNotifications: ((Boolean) -> Unit)? = null

    fun overlayGranted(): Boolean = Settings.canDrawOverlays(activity)

    fun notificationsGranted(): Boolean =
        activity.getSystemService(NotificationManager::class.java).areNotificationsEnabled()

    fun accessibilityEnabled(): Boolean {
        val enabled = Settings.Secure.getString(
            activity.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ).orEmpty()
        return enabled.split(':').any { it.equals(ACCESSIBILITY_COMPONENT, ignoreCase = true) }
    }

    fun openOverlaySettings() {
        val uri = Uri.parse("package:${activity.packageName}")
        activity.startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, uri))
    }

    fun openAccessibilitySettings() {
        activity.startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
    }

    /** Asks for POST_NOTIFICATIONS (Android 13+); [onResult] receives whether notifications are allowed. */
    fun requestNotifications(onResult: (Boolean) -> Unit) {
        if (notificationsGranted()) {
            onResult(true)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pendingNotifications?.invoke(false)
            pendingNotifications = onResult
            activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_NOTIFICATIONS)
        } else {
            // Before Android 13 there is no runtime prompt; the user must enable them in system settings.
            onResult(false)
        }
    }

    /** Forward from `Activity.onRequestPermissionsResult`. */
    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode != REQUEST_NOTIFICATIONS) return
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        pendingNotifications?.invoke(granted)
        pendingNotifications = null
    }

    companion object {
        private const val REQUEST_NOTIFICATIONS = 1001
        private const val ACCESSIBILITY_COMPONENT =
            "com.ambatrans.app/com.ambatrans.app.access.AmbaAccessibilityService"
    }
}
