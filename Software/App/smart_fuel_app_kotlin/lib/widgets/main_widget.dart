import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef void MyCallback();

class MainWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String iconPath;
  final MyCallback onPressedFunction;

  MainWidget(
      {Key? key,
      required this.title,
      required this.subTitle,
      required this.iconPath,
      required this.onPressedFunction});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: CircleAvatar(
                radius: 30,
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: SvgPicture.asset(
                      iconPath
                  ),//Image.asset(iconPath),
                ),
                backgroundColor: const Color(0xFFF4F6F6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.left),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 1),
                    child: Text(subTitle,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.left),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onPressed: () => onPressedFunction(),
      style: ButtonStyle(
          //shadowColor: MaterialStateProperty.all<Color>(Colors.green),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          overlayColor: MaterialStateProperty.all<Color>(const Color(0xFFF4F6F6)),
          elevation: MaterialStateProperty.all<double>(3),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                side: BorderSide(color: Colors.white)),
          )),
    );
  }
}
