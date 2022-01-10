package com.example.smart_fuel_app_kotlin

import android.util.Log
import com.transistorsoft.flutter.backgroundfetch.HeadlessTask
import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

import com.pauldemarco.flutter_blue.FlutterBluePlugin
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry

import test


class MainApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        val _test = test();
        HeadlessTask.onInitialized(_test);
    }
}