import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CircularStatus extends StatelessWidget {
  final double progress;
  final Widget child;
  final double height;
  final double padding;
  final double width;

  CornerStyle getStyle(double progress) {
    if(progress < 2000) {
      return CornerStyle.bothCurve;
    }
    return  CornerStyle.bothFlat;
  }

  CircularStatus({Key? key, required this.progress, required this.child, required this.height, required this.width, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: SizedBox(
        height: height,
        width:width,
        child: SfRadialGauge(axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 2000,
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.15,
              color: Color(0x2216B9ED),
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: progress,
                cornerStyle: getStyle(progress),
                enableAnimation: true,
                width: 0.15,
                color: const Color(0xFF16B9ED),
                sizeUnit: GaugeSizeUnit.factor,
              )
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                horizontalAlignment: GaugeAlignment.center,
                positionFactor: 0.1,
                widget: child,
              ),
            ],
          )
        ]),
      ),
    );
  }
}
