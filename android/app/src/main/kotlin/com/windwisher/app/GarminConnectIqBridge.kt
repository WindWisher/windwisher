package com.windwisher.app

import android.app.Activity
import android.os.Handler
import android.os.Looper
import com.garmin.android.connectiq.ConnectIQ
import com.garmin.android.connectiq.IQApp
import com.garmin.android.connectiq.IQDevice
import com.garmin.android.connectiq.exception.InvalidStateException
import com.garmin.android.connectiq.exception.ServiceUnavailableException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.nio.charset.StandardCharsets
import java.util.UUID

class GarminConnectIqBridge(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    companion object {
        const val channelName = "windwisher/garmin_connect_iq"
        const val sessionAppId = "f25ab89e57f74368b256069658c6d2d8"
        private const val protocol = "windwisher.session.transfer"
        private const val protocolVersion = 1
        private const val maxSessions = 32
        private const val maxLines = 1026
        private const val maxLineBytes = 4096
        private const val maxTransferBytes = 2 * 1024 * 1024
        private const val responseTimeoutMs = 15_000L
    }

    private val channel = MethodChannel(messenger, channelName)
    private val connectIQ = ConnectIQ.getInstance(activity, ConnectIQ.IQConnectType.WIRELESS)
    private val handler = Handler(Looper.getMainLooper())
    private var isReady = false
    private var isInitializing = false
    private var pendingResult: MethodChannel.Result? = null
    private var pendingReadyAction: (() -> Unit)? = null
    private var transfer: PendingTransfer? = null

    private data class PendingTransfer(
        val result: MethodChannel.Result,
        val device: IQDevice,
        val app: IQApp,
        val requestId: String,
        val sourceId: String?,
        val output: ByteArrayOutputStream = ByteArrayOutputStream(),
        var expectedLine: Int = 0,
        var timeout: Runnable? = null,
    )

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "knownDevices" -> runWhenReady(result) { returnKnownDevices(result) }
                "inspectSessions" -> runWhenReady(result) {
                    startTransfer(result, requireDeviceId(call), null)
                }
                "downloadSession" -> runWhenReady(result) {
                    val sourceId = call.argument<String>("sourceId")?.trim().orEmpty()
                    if (!sourceId.matches(Regex("[A-Za-z0-9_-]{1,96}"))) {
                        result.error("garmin_invalid_session", "La sesion solicitada no es valida.", null)
                    } else {
                        startTransfer(result, requireDeviceId(call), sourceId)
                    }
                }
                else -> result.notImplemented()
            }
        } catch (error: IllegalArgumentException) {
            result.error("garmin_invalid_request", error.message, null)
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        failActive("garmin_interrupted", "La comunicacion con Garmin se ha interrumpido.")
        pendingResult?.error(
            "garmin_interrupted",
            "La consulta de Garmin se ha interrumpido.",
            null,
        )
        pendingResult = null
        pendingReadyAction = null
        try {
            connectIQ.unregisterAllForEvents()
            connectIQ.shutdown(activity)
        } catch (_: InvalidStateException) {
        }
        isReady = false
        isInitializing = false
    }

    private fun runWhenReady(result: MethodChannel.Result, action: () -> Unit) {
        if (isReady) {
            action()
            return
        }
        if (isInitializing || pendingResult != null || transfer != null) {
            result.error("garmin_busy", "Ya hay una consulta de Garmin en curso.", null)
            return
        }
        isInitializing = true
        pendingResult = result
        pendingReadyAction = action
        connectIQ.initialize(
            activity,
            true,
            object : ConnectIQ.ConnectIQListener {
                override fun onSdkReady() {
                    activity.runOnUiThread {
                        isReady = true
                        isInitializing = false
                        val readyAction = pendingReadyAction
                        pendingReadyAction = null
                        pendingResult = null
                        readyAction?.invoke()
                    }
                }

                override fun onInitializeError(error: ConnectIQ.IQSdkErrorStatus) {
                    activity.runOnUiThread {
                        isReady = false
                        isInitializing = false
                        pendingResult?.error(
                            "garmin_unavailable",
                            "Garmin Connect IQ no esta disponible: ${error.name}",
                            null,
                        )
                        pendingResult = null
                        pendingReadyAction = null
                    }
                }

                override fun onSdkShutDown() {
                    isReady = false
                    activity.runOnUiThread {
                        failActive(
                            "garmin_unavailable",
                            "Garmin Connect IQ ha dejado de estar disponible.",
                        )
                    }
                }
            },
        )
    }

    private fun requireDeviceId(call: MethodCall): Long {
        val text = call.argument<String>("deviceId")?.trim().orEmpty()
        return text.toLongOrNull()
            ?: throw IllegalArgumentException("Identificador Garmin invalido.")
    }

    private fun returnKnownDevices(result: MethodChannel.Result) {
        try {
            val devices = connectIQ.knownDevices.orEmpty().map { device ->
                val status = connectIQ.getDeviceStatus(device)
                mapOf(
                    "id" to device.deviceIdentifier.toString(),
                    "name" to device.friendlyName,
                    "status" to status.name,
                    "partNumber" to connectIQ.getDevicePartNumber(device),
                    "sessionAppId" to sessionAppId,
                )
            }
            result.success(devices)
        } catch (_: ServiceUnavailableException) {
            result.error(
                "garmin_service_unavailable",
                "Garmin Connect debe estar instalado, abierto y vinculado al reloj.",
                null,
            )
        } catch (_: InvalidStateException) {
            isReady = false
            result.error("garmin_invalid_state", "Garmin Connect IQ no esta preparado.", null)
        }
    }

    private fun startTransfer(
        result: MethodChannel.Result,
        deviceIdentifier: Long,
        sourceId: String?,
    ) {
        if (transfer != null) {
            result.error("garmin_busy", "Ya hay una transferencia Garmin en curso.", null)
            return
        }
        try {
            val device = connectIQ.knownDevices.orEmpty().firstOrNull {
                it.deviceIdentifier == deviceIdentifier
            }
            if (device == null || connectIQ.getDeviceStatus(device) != IQDevice.IQDeviceStatus.CONNECTED) {
                result.error("garmin_disconnected", "El reloj Garmin no esta conectado.", null)
                return
            }
            val app = IQApp(sessionAppId)
            val pending = PendingTransfer(
                result = result,
                device = device,
                app = app,
                requestId = UUID.randomUUID().toString(),
                sourceId = sourceId,
            )
            transfer = pending
            connectIQ.registerForAppEvents(device, app, appEventListener)
            send(
                pending,
                mutableMapOf<String, Any>(
                    "protocol" to protocol,
                    "version" to protocolVersion,
                    "type" to if (sourceId == null) "inventory_request" else "download_start",
                    "requestId" to pending.requestId,
                ).apply {
                    if (sourceId != null) put("sessionId", sourceId)
                },
            )
        } catch (_: ServiceUnavailableException) {
            failActive("garmin_service_unavailable", "Garmin Connect no esta disponible.")
        } catch (_: InvalidStateException) {
            isReady = false
            failActive("garmin_invalid_state", "Garmin Connect IQ no esta preparado.")
        }
    }

    private val appEventListener = ConnectIQ.IQApplicationEventListener { device, app, messages, status ->
        activity.runOnUiThread {
            val pending = transfer ?: return@runOnUiThread
            if (pending.device != device || pending.app.applicationId != app.applicationId) {
                return@runOnUiThread
            }
            if (status != ConnectIQ.IQMessageStatus.SUCCESS) {
                failActive("garmin_receive_failed", "Garmin no pudo entregar la respuesta: ${status.name}")
                return@runOnUiThread
            }
            for (message in messages) {
                val response = message as? Map<*, *> ?: continue
                if (response["requestId"] == pending.requestId) {
                    handleResponse(pending, response)
                    break
                }
            }
        }
    }

    private fun handleResponse(pending: PendingTransfer, response: Map<*, *>) {
        if (response["protocol"] != protocol || (response["version"] as? Number)?.toInt() != protocolVersion) {
            failActive("garmin_invalid_response", "El reloj devolvio una respuesta incompatible.")
            return
        }
        when (response["type"] as? String) {
            "inventory" -> completeInventory(pending, response)
            "download_line" -> acceptLine(pending, response)
            "download_complete" -> completeDownload(pending, response)
            "error" -> failActive(
                "garmin_watch_error",
                "El reloj rechazo la operacion: ${response["code"] ?: "UNKNOWN"}.",
            )
            else -> failActive("garmin_invalid_response", "El reloj devolvio una respuesta desconocida.")
        }
    }

    private fun completeInventory(pending: PendingTransfer, response: Map<*, *>) {
        if (pending.sourceId != null || response["format"] != "garmin-frame-envelope-v1") {
            failActive("garmin_invalid_inventory", "El inventario Garmin no es valido.")
            return
        }
        val sessions = response["sessions"] as? List<*>
        if (sessions == null || sessions.size > maxSessions) {
            failActive("garmin_invalid_inventory", "El inventario Garmin no es valido.")
            return
        }
        val mapped = sessions.mapNotNull { raw ->
            val item = raw as? Map<*, *> ?: return@mapNotNull null
            val sourceId = item["sessionId"] as? String ?: return@mapNotNull null
            val started = (item["startedAtEpochSeconds"] as? Number)?.toLong() ?: return@mapNotNull null
            val ended = (item["endedAtEpochSeconds"] as? Number)?.toLong() ?: return@mapNotNull null
            val duration = (item["durationMilliseconds"] as? Number)?.toLong() ?: return@mapNotNull null
            val count = (item["frameCount"] as? Number)?.toInt() ?: return@mapNotNull null
            if (!sourceId.matches(Regex("[A-Za-z0-9_-]{1,96}")) || started < 0 || ended < started || duration < 0 || count !in 2..1024) {
                return@mapNotNull null
            }
            mapOf(
                "sourceId" to sourceId,
                "startedAtEpochSeconds" to started,
                "endedAtEpochSeconds" to ended,
                "durationMilliseconds" to duration,
                "frameCount" to count,
            )
        }
        if (mapped.size != sessions.size || mapped.map { it["sourceId"] }.toSet().size != mapped.size) {
            failActive("garmin_invalid_inventory", "El inventario Garmin contiene sesiones invalidas.")
            return
        }
        finishActive { it.result.success(mapped) }
    }

    private fun acceptLine(pending: PendingTransfer, response: Map<*, *>) {
        val sourceId = response["sessionId"] as? String
        val lineIndex = (response["lineIndex"] as? Number)?.toInt()
        val line = response["line"] as? String
        if (sourceId != pending.sourceId || lineIndex != pending.expectedLine || line == null) {
            failActive("garmin_invalid_line", "La descarga Garmin esta desordenada.")
            return
        }
        val bytes = line.toByteArray(StandardCharsets.UTF_8)
        if (bytes.isEmpty() || bytes.size > maxLineBytes || pending.expectedLine >= maxLines || pending.output.size() + bytes.size > maxTransferBytes) {
            failActive("garmin_transfer_limit", "La sesion Garmin supera los limites permitidos.")
            return
        }
        pending.output.write(bytes)
        pending.expectedLine += 1
        send(
            pending,
            mapOf(
                "protocol" to protocol,
                "version" to protocolVersion,
                "type" to "download_ack",
                "requestId" to pending.requestId,
                "sessionId" to pending.sourceId!!,
                "lineIndex" to lineIndex,
            ),
        )
    }

    private fun completeDownload(pending: PendingTransfer, response: Map<*, *>) {
        val lineCount = (response["lineCount"] as? Number)?.toInt()
        if (pending.sourceId == null || response["sessionId"] != pending.sourceId || lineCount != pending.expectedLine || lineCount !in 4..maxLines) {
            failActive("garmin_incomplete_transfer", "La descarga Garmin esta incompleta.")
            return
        }
        val bytes = pending.output.toByteArray()
        finishActive { it.result.success(bytes) }
    }

    private fun send(pending: PendingTransfer, message: Map<String, Any>) {
        scheduleTimeout(pending)
        try {
            connectIQ.sendMessage(pending.device, pending.app, message) { _, _, status ->
                if (status != ConnectIQ.IQMessageStatus.SUCCESS) {
                    activity.runOnUiThread {
                        if (transfer === pending) {
                            failActive("garmin_send_failed", "Garmin no pudo enviar el mensaje: ${status.name}")
                        }
                    }
                }
            }
        } catch (_: ServiceUnavailableException) {
            failActive("garmin_service_unavailable", "Garmin Connect no esta disponible.")
        } catch (_: InvalidStateException) {
            isReady = false
            failActive("garmin_invalid_state", "Garmin Connect IQ no esta preparado.")
        }
    }

    private fun scheduleTimeout(pending: PendingTransfer) {
        pending.timeout?.let(handler::removeCallbacks)
        val timeout = Runnable {
            if (transfer === pending) {
                failActive("garmin_timeout", "El reloj no ha respondido a tiempo.")
            }
        }
        pending.timeout = timeout
        handler.postDelayed(timeout, responseTimeoutMs)
    }

    private fun failActive(code: String, message: String) {
        finishActive { it.result.error(code, message, null) }
    }

    private fun finishActive(complete: (PendingTransfer) -> Unit) {
        val pending = transfer ?: return
        transfer = null
        pending.timeout?.let(handler::removeCallbacks)
        try {
            connectIQ.unregisterForApplicationEvents(pending.device, pending.app)
        } catch (_: Exception) {
        }
        complete(pending)
    }
}
