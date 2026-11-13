package com.ambatrans.app.bridge

import com.ambatrans.app.service.ServiceStateHolder
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/** Streams "running" / "stopped"; the current value is delivered on subscribe. */
class ServiceStateStreamHandler : EventChannel.StreamHandler {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var job: Job? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        job?.cancel()
        job = scope.launch {
            ServiceStateHolder.running.collect { events.success(if (it) STATE_RUNNING else STATE_STOPPED) }
        }
    }

    override fun onCancel(arguments: Any?) {
        job?.cancel()
        job = null
    }

    companion object {
        const val CHANNEL = "com.ambatrans.app/service_state"
        const val STATE_RUNNING = "running"
        const val STATE_STOPPED = "stopped"
    }
}
