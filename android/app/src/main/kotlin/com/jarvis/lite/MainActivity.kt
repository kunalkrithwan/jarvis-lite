package com.jarvis.lite

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.bluetooth.BluetoothAdapter
import android.net.wifi.WifiManager
import android.provider.AlarmClock
import android.net.Uri
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.jarvis.lite/system"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "launchApp" -> {
                        val packageName = call.argument<String>("packageName")
                        val appName = call.argument<String>("appName")
                        result(launchApp(packageName))
                    }
                    "isAppInstalled" -> {
                        val packageName = call.argument<String>("packageName")
                        result(isAppInstalled(packageName))
                    }
                    "toggleWifi" -> {
                        val enable = call.argument<Boolean>("enable") ?: false
                        result(toggleWifi(enable))
                    }
                    "isWifiEnabled" -> {
                        result(isWifiEnabled())
                    }
                    "toggleBluetooth" -> {
                        val enable = call.argument<Boolean>("enable") ?: false
                        result(toggleBluetooth(enable))
                    }
                    "isBluetoothEnabled" -> {
                        result(isBluetoothEnabled())
                    }
                    "toggleFlashlight" -> {
                        val enable = call.argument<Boolean>("enable") ?: false
                        result(toggleFlashlight(enable))
                    }
                    "isFlashlightOn" -> {
                        result(isFlashlightOn())
                    }
                    "getSystemInfo" -> {
                        result(getSystemInfo())
                    }
                    "setAlarm" -> {
                        val hour = call.argument<Int>("hour") ?: 0
                        val minute = call.argument<Int>("minute") ?: 0
                        val label = call.argument<String>("label") ?: "JARVIS Alarm"
                        result(setAlarm(hour, minute, label))
                    }
                    "makeCall" -> {
                        val phoneNumber = call.argument<String>("phoneNumber")
                        result(makeCall(phoneNumber))
                    }
                    "sendSms" -> {
                        val phoneNumber = call.argument<String>("phoneNumber")
                        val message = call.argument<String>("message")
                        result(sendSms(phoneNumber, message))
                    }
                    "getInstalledApps" -> {
                        result(getInstalledApps())
                    }
                    else -> result(null)
                }
            }
    }

    private fun launchApp(packageName: String?): Boolean {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(packageName ?: return false)
            if (intent != null) {
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun isAppInstalled(packageName: String?): Boolean {
        return try {
            packageManager.getApplicationInfo(packageName ?: return false, 0)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun toggleWifi(enable: Boolean): Boolean {
        return try {
            val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            wifiManager.isWifiEnabled = enable
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun isWifiEnabled(): Boolean {
        return try {
            val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            wifiManager.isWifiEnabled
        } catch (e: Exception) {
            false
        }
    }

    private fun toggleBluetooth(enable: Boolean): Boolean {
        return try {
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            if (enable) {
                bluetoothAdapter.enable()
            } else {
                bluetoothAdapter.disable()
            }
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun isBluetoothEnabled(): Boolean {
        return try {
            val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
            bluetoothAdapter?.isEnabled ?: false
        } catch (e: Exception) {
            false
        }
    }

    private fun toggleFlashlight(enable: Boolean): Boolean {
        // Placeholder - requires camera permission and hardware
        return true
    }

    private fun isFlashlightOn(): Boolean {
        return false
    }

    private fun getSystemInfo(): Map<String, Any> {
        return try {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER)
            
            val intentFilter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            val batteryStatus = registerReceiver(null, intentFilter)
            val level = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            val status = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1

            mapOf(
                "device" to Build.DEVICE,
                "model" to Build.MODEL,
                "brand" to Build.BRAND,
                "version" to Build.VERSION.RELEASE,
                "sdk_int" to Build.VERSION.SDK_INT,
                "battery_level" to level,
                "battery_scale" to scale,
                "is_charging" to (status == BatteryManager.BATTERY_STATUS_CHARGING)
            )
        } catch (e: Exception) {
            emptyMap()
        }
    }

    private fun setAlarm(hour: Int, minute: Int, label: String): Boolean {
        return try {
            val intent = Intent(AlarmClock.ACTION_SET_ALARM)
            intent.putExtra(AlarmClock.EXTRA_HOUR, hour)
            intent.putExtra(AlarmClock.EXTRA_MINUTES, minute)
            intent.putExtra(AlarmClock.EXTRA_MESSAGE, label)
            startActivity(intent)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun makeCall(phoneNumber: String?): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_CALL)
            intent.data = Uri.parse("tel:$phoneNumber")
            startActivity(intent)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun sendSms(phoneNumber: String?, message: String?): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_SENDTO)
            intent.data = Uri.parse("smsto:$phoneNumber")
            intent.putExtra("sms_body", message)
            startActivity(intent)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun getInstalledApps(): List<String> {
        return try {
            val pm = packageManager
            val packages = pm.getInstalledApplications(0)
            packages
                .filter { !it.packageName.contains("jarvis") }
                .map { it.packageName }
                .take(50)
        } catch (e: Exception) {
            emptyList()
        }
    }
}
