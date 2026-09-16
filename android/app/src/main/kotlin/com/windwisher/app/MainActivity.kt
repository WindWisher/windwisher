package com.windwisher.app

import android.Manifest
import android.app.Activity
import android.content.Intent
import java.io.ByteArrayOutputStream
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.pm.PackageManager
import android.os.Build
import com.google.firebase.FirebaseApp
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingCanonical: MethodChannel.Result? = null
    private var garminConnectIqBridge: GarminConnectIqBridge? = null
    private val canonicalRequest = 47021
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        garminConnectIqBridge = GarminConnectIqBridge(
            this,
            flutterEngine.dartExecutor.binaryMessenger,
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "windwisher/private_canonical_import")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "privateDirectory" -> {
                        val directory = java.io.File(noBackupFilesDir, "canonical_inbox_v1")
                        if (!directory.exists() && !directory.mkdirs()) {
                            result.error("storage", "Private storage unavailable", null)
                        } else { result.success(directory.absolutePath) }
                    }
                    "pickCanonical" -> {
                        if (pendingCanonical != null) {
                            result.error("busy", "Import already pending", null)
                        } else {
                            pendingCanonical = result
                            try {
                                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                                    addCategory(Intent.CATEGORY_OPENABLE)
                                    type = "*/*"
                                    putExtra(Intent.EXTRA_LOCAL_ONLY, true)
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                }
                                startActivityForResult(intent, canonicalRequest)
                            } catch (_: Exception) {
                                pendingCanonical = null
                                result.error("picker", "File picker unavailable", null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "windwisher/bluetooth_devices"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "bondedDevices" -> result.success(bondedBluetoothDevices())
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "windwisher/push"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getFcmToken" -> {
                    try {
                        FirebaseApp.initializeApp(applicationContext)
                    } catch (_: Exception) {
                    }
                    FirebaseMessaging.getInstance().token
                        .addOnCompleteListener { task ->
                            if (!task.isSuccessful) {
                                result.error(
                                    "fcm-token-error",
                                    task.exception?.message ?: "No se pudo obtener el token FCM.",
                                    null,
                                )
                                return@addOnCompleteListener
                            }
                            result.success(task.result)
                        }
                }
                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Activity callback retained for the existing FlutterActivity integration")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != canonicalRequest) return
        val result = pendingCanonical ?: return
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            pendingCanonical = null
            result.success(null)
            return
        }
        val uri = data.data!!
        Thread {
            try {
                val bytes = contentResolver.openInputStream(uri)?.use { stream ->
                    val output = ByteArrayOutputStream()
                    val buffer = ByteArray(8192)
                    while (true) {
                        val count = stream.read(buffer)
                        if (count < 0) break
                        if (output.size() + count > 2 * 1024 * 1024) throw IllegalArgumentException()
                        output.write(buffer, 0, count)
                    }
                    output.toByteArray()
                } ?: throw IllegalArgumentException()
                runOnUiThread {
                    if (pendingCanonical === result) {
                        pendingCanonical = null
                        result.success(bytes)
                    }
                }
            } catch (_: Exception) {
                runOnUiThread {
                    if (pendingCanonical === result) {
                        pendingCanonical = null
                        result.error("read", "Cannot read bounded canonical file", null)
                    }
                }
            }
        }.start()
    }

    override fun onDestroy() {
        garminConnectIqBridge?.dispose()
        garminConnectIqBridge = null
        pendingCanonical?.error("cancelled", "Import interrupted by activity destruction", null)
        pendingCanonical = null
        super.onDestroy()
    }

    @Suppress("DEPRECATION")
    private fun bondedBluetoothDevices(): List<Map<String, Any?>> {
        if (!hasBluetoothConnectPermission()) {
            return emptyList()
        }

        val adapter = BluetoothAdapter.getDefaultAdapter() ?: return emptyList()
        return try {
            adapter.bondedDevices.map { device ->
                mapOf(
                    "id" to device.address,
                    "name" to (device.name ?: ""),
                    "type" to bluetoothDeviceTypeLabel(device.type),
                    "bondState" to bluetoothBondStateLabel(device.bondState),
                )
            }
        } catch (_: SecurityException) {
            emptyList()
        }
    }

    private fun hasBluetoothConnectPermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun bluetoothDeviceTypeLabel(type: Int): String {
        return when (type) {
            BluetoothDevice.DEVICE_TYPE_CLASSIC -> "classic"
            BluetoothDevice.DEVICE_TYPE_LE -> "le"
            BluetoothDevice.DEVICE_TYPE_DUAL -> "dual"
            else -> "unknown"
        }
    }

    private fun bluetoothBondStateLabel(state: Int): String {
        return when (state) {
            BluetoothDevice.BOND_BONDED -> "bonded"
            BluetoothDevice.BOND_BONDING -> "bonding"
            BluetoothDevice.BOND_NONE -> "none"
            else -> "unknown"
        }
    }
}
