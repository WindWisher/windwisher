package com.windwisher.app

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "windwisher/bluetooth_devices"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "bondedDevices" -> result.success(bondedBluetoothDevices())
                else -> result.notImplemented()
            }
        }
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
