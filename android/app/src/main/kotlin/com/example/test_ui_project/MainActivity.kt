package com.example.test_ui_project

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "appSettings"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(flutterEngine!!)
        MethodChannel(flutterEngine!!.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "noti") {
                noti()
            } else {
                result.notImplemented()
            }
        }
    }

    private fun noti () {
//        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, this.packageName)
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.naver.com/"))

        startActivity(intent)
    }
}
