package com.example.sports

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.ComponentName

class MainActivity: FlutterActivity() {
    private val CHANNEL = "android_intent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchApp") {
                val packageName = call.argument<String>("package")
                val activityName = call.argument<String>("activity")
                
                try {
                    val intent = Intent()
                    intent.component = ComponentName(packageName!!, activityName!!)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("LAUNCH_ERROR", "Failed to launch app: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}