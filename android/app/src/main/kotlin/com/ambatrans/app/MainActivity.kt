package com.ambatrans.app

import android.content.Context
import com.ambatrans.app.bridge.SettingsMethodHandler
import com.ambatrans.app.data.SettingsStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val prefs = getSharedPreferences(SettingsStore.PREFS_NAME, Context.MODE_PRIVATE)
        val store = SettingsStore(prefs).also { it.migrate() }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SettingsMethodHandler.CHANNEL)
            .setMethodCallHandler(SettingsMethodHandler(store))
    }
}
