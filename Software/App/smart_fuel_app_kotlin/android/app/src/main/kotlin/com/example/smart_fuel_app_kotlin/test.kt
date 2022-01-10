import com.transistorsoft.flutter.backgroundfetch.HeadlessTask
import io.flutter.embedding.engine.FlutterEngine

import com.pauldemarco.flutter_blue.FlutterBluePlugin

import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry


class test() : HeadlessTask.OnInitializedCallback{
    override fun onInitialized(engine: FlutterEngine) {
        var shimPluginRegistry: ShimPluginRegistry = ShimPluginRegistry(engine)
        FlutterBluePlugin.registerWith(shimPluginRegistry.registrarFor("com.pauldemarco.flutter_blue.FlutterBluePlugin"))
    }
}