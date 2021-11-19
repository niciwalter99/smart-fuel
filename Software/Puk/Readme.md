# Aufbau der Software
Die Software für den Puk unterteilt in Datensammlung (ADC/HX711), Speicherung und Kommunikation per BLE.

## Datensammlung
Daten werden alle 5 sec gesammelt. Dies wird durch einen RTC Timer ermöglicht (vgl.peripheral/rtc), der alle 5 Sekunden einen Interrupt triggered, der wiederum ein Datenpunkt sammelt. In der Zwischenzeit befindet sich der NRF52840 im Sleep Mode.

## Speicherung
Bei jeder Datensammlung wird der Datenpunkt in den externen Flash (64MB) gespeichert. Dazu wird ein Struct erstellt, welcher zwei Werte speichert: Datetime u. Gewicht. Dieser Struct wird dann gespeichert. Um die RTC in eine Datetime unzuwandeln kann bspw. ähnlich dem Example https://github.com/NordicPlayground/nrf5-calendar-example die Datetime konstruiert werden.

## Kommunikation per BLE
Die Daten werden beim Koppeln übertragen. Da es relativ große Datenmengen sind kann sich hierbei an das Serialization Beispiel gehalten werden (vgl. https://github.com/jimmywong2003/nrf52_ble_transfer_jpg/blob/master/ble_app_transfer_jpg/main.c oder hier: https://www.novelbits.io/bluetooth-5-speed-maximum-throughput/)

### Nützliche Links
