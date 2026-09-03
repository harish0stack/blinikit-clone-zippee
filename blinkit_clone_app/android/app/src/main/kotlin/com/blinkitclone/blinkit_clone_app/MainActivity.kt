package com.blinkitclone.blinkit_clone_app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.zippee.app/upi_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchUpiApp" -> {
                    val upiUriString = call.argument<String>("uri")
                    val packageName = call.argument<String>("packageName")

                    if (!upiUriString.isNullOrEmpty()) {
                        try {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(upiUriString))
                            if (!packageName.isNullOrEmpty()) {
                                intent.setPackage(packageName)
                            }
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("LAUNCH_FAILED", e.localizedMessage, null)
                        }
                    } else {
                        result.error("INVALID_URI", "UPI URI cannot be null", null)
                    }
                }
                "getInstalledUpiPackages" -> {
                    try {
                        val pm = packageManager
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("upi://pay"))
                        val resolveInfos = pm.queryIntentActivities(intent, 0)
                        val installedPackages = resolveInfos.map { it.activityInfo.packageName }
                        result.success(installedPackages)
                    } catch (e: Exception) {
                        result.error("DETECTION_FAILED", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
