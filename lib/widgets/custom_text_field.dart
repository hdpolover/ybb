import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  String hint;
  bool issecured;

  CustomTextField({this.hint, this.issecured});

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: TextField(
        obscureText: widget.issecured,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(25),
          ),
          hintText: widget.hint,
          hintStyle: TextStyle(
              fontSize: 18,
              letterSpacing: 1.5,
              color: Colors.white70,
              fontWeight: FontWeight.w900),
          filled: true,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          fillColor: Colors.white.withOpacity(.3),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
}
