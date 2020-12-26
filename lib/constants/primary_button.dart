import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton({this.key, this.text, this.height, this.onPressed})
      : super(key: key);
  final Key key;
  final String text;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Text(text,
                style: TextStyle(color: Colors.white, fontSize: 20.0)),
            color: kSecondaryColor,
            textColor: Colors.black87,
            onPressed: onPressed),
      ),
    );
  }
}
