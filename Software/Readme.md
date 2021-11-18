# Software Stack
Software, welche auf dem Puk(Flasche) läuft, sowie die dazugehörige App.

## Dependencies für Puk Software
Die Software für den PUK wurde für den NRF 52840 Chip mit der Software Segger Embedded Studio geschrieben. Für die Software wird die SDK Version 1.7.1 von Nordic Semiconductor verwendet. Um die Entwicklungsumgebung einzurichten muss Segger Embedded Studio heruntergeladen werden und innerhalb der Software unter 
`Tools -> Options -> Building -> Global Macros` das Makro `sdk_dir` mit dem Pfad für die SDK gesetzt werden (bspw. `sdk_dir=/Users/nicolaswalter/Dokumente/Smart Fuel/Software/Puk/nRF5_SDK_17.1.0_ddde560`).
Die Softwareversion befindet sich innerhalb dem Ordner nRF5_SDK_17.1.0_ddde560 in dem Ordner `examples/ble_peripheral/smart_fuel/pca10059/s140/ses/`. Die Datei `smart_fuel_pca10059_s140.emProject` ist die Segger Embedded Studio Projektdatei.

## Dependencies für App Software
Für die App wird das Framework Flutter verwendet, welches heruntergeladen werden muss (siehe https://docs.flutter.dev/get-started/install).
Zudem muss in Android Studio der Pfad zum Flutter SDK gesetzt werden.
