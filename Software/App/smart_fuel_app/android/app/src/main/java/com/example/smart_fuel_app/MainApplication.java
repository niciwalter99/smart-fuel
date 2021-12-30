package com.example.smart_fuel_app;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import com.pauldemarco.flutter_blue.FlutterBluePlugin;
import com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin;
import com.transistorsoft.flutter.backgroundfetch.HeadlessTask;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.FlutterEngine;
import com.pauldemarco.flutter_blue.FlutterBluePlugin;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;


public class MainApplication extends FlutterApplication{

    @Override
    public void onCreate() {
        super.onCreate();

        HeadlessTask.onInitialized(new HeadlessTask.OnInitializedCallback() {
            @Override
            public void onInitialized(FlutterEngine engine) {
                Log.i("TSBackgroundFetch", "********* engine started: " + engine);
                ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(engine);
                FlutterBluePlugin.registerWith(shimPluginRegistry.registrarFor("com.pauldemarco.flutter_blue.FlutterBluePlugin"));
            }
        });
    }
}