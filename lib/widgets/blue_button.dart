import 'package:flutter/material.dart';

class BlueButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const BlueButton({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      disabledColor: Colors.grey,
      elevation: 2.0,
      color: Colors.blue,
      shape: const StadiumBorder(),
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}
