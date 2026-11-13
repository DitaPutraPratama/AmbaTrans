package com.ambatrans.app.bridge

import com.ambatrans.app.data.InvalidSettingException
import com.ambatrans.app.data.SettingsStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SettingsMethodHandler(private val store: SettingsStore) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAll" -> result.success(store.getAll())
            "set" -> {
                try {
                    store.set(call.argument<String>("key").orEmpty(), call.argument<Any>("value"))
                    result.success(null)
                } catch (e: InvalidSettingException) {
                    result.error(ERROR_INVALID_VALUE, e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val CHANNEL = "com.ambatrans.app/settings"
        const val ERROR_INVALID_VALUE = "E_INVALID_VALUE"
    }
}
