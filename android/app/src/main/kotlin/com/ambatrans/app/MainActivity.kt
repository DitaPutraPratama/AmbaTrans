package com.ambatrans.app

import android.content.Context
import com.ambatrans.app.bridge.AndroidPermissions
import com.ambatrans.app.bridge.PermissionsMethodHandler
import com.ambatrans.app.bridge.SettingsMethodHandler
import com.ambatrans.app.data.SettingsStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val permissions by lazy { AndroidPermissions(this) }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        val prefs = getSharedPreferences(SettingsStore.PREFS_NAME, Context.MODE_PRIVATE)
        val store = SettingsStore(prefs).also { it.migrate() }
        MethodChannel(messenger, SettingsMethodHandler.CHANNEL)
            .setMethodCallHandler(SettingsMethodHandler(store))

        MethodChannel(messenger, PermissionsMethodHandler.CHANNEL)
            .setMethodCallHandler(PermissionsMethodHandler(permissions))
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        this.permissions.onRequestPermissionsResult(requestCode, grantResults)
    }
}
