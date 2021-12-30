package com.example.smart_fuel_app;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.pauldemarco.flutter_blue.FlutterBluePlugin;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin;

public class MainActivity extends FlutterActivity {
//    @Override
//    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//
//        GeneratedPluginRegistrant.registerWith(flutterEngine);
//        // Normally not needed?
//        flutterEngine.getPlugins().add(new com.pauldemarco.flutter_blue.FlutterBluePlugin());
//    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
