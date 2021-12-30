package com.example.smart_fuel_app;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.PluginRegistry;
import com.pauldemarco.flutter_blue.FlutterBluePlugin;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;
/*
This is a copy of the original GeneratedPluginRegistrant, provided to explain how to use a custom
plugin registrant.
 */
@Keep
public final class CustomPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    flutterEngine.getPlugins().add(new com.pauldemarco.flutter_blue.FlutterBluePlugin());

  }
}
