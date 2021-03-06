# Aufbau der Software
Die Software für den Puk unterteilt in Datensammlung (ADC/HX711), Speicherung und Kommunikation per BLE.

## Datensammlung
Daten werden alle 5 sec gesammelt. Dies wird durch einen RTC Timer ermöglicht (vgl.peripheral/rtc), der alle 5 Sekunden einen Interrupt triggered, der wiederum ein Datenpunkt sammelt. In der Zwischenzeit befindet sich der NRF52840 im Sleep Mode.

## Speicherung
Bei jeder Datensammlung wird der Datenpunkt in den externen Flash (64MB) gespeichert. Dazu wird ein Struct erstellt, welcher zwei Werte speichert: Datetime u. Gewicht. Dieser Struct wird dann gespeichert. Um die RTC in eine Datetime unzuwandeln kann bspw. ähnlich dem Example https://github.com/NordicPlayground/nrf5-calendar-example die Datetime konstruiert werden.

Die Daten werden max. 30 Tage gespeichert -> maximale Datenspeichermenge bei 100 Bytes pro Datenpunkt: 12(Messungen pro Minute) * 60(Stunde) * 24(Tage) * 30(Speicherung maximal) = 518 kB, welche maximal übertragen werden müssen. Bei jeder Datensynchronisierung wird die RTC Datetime synchronisiert um grobe Messfehler zu vermeiden.

Daten werden in Struct gespeichert, welche die Datetime vom aller ersten Messpunkt beinhaltet und eine Liste der Daten in richtiger Reihenfolge. Evtl. muss die Interrupt Pin Genauigkeit noch beobachtet werden (manchmal können Messungen nicht ausgeführt werden).

## Kommunikation per BLE
Die Daten werden beim Koppeln übertragen. Da es relativ große Datenmengen sind kann sich hierbei an das Serialization Beispiel gehalten werden (vgl. https://github.com/jimmywong2003/nrf52_ble_transfer_jpg/blob/master/ble_app_transfer_jpg/main.c oder hier: https://www.novelbits.io/bluetooth-5-speed-maximum-throughput/)

### Nützliche Links
