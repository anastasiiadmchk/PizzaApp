import 'dart:io';

import 'package:flutter/cupertino.dart';

class MyPizzaIcon extends StatefulWidget {
  MyPizzaIcon({Key key, this.imageFile, this.photo}): super(key:key);
  final File imageFile;
  final String photo;

  @override
  _MyPizzaIconState createState() => _MyPizzaIconState();
}

class _MyPizzaIconState extends State<MyPizzaIcon> {
  //File get imageFile => null;
  @override
  Widget build(BuildContext context) {
    if(widget.imageFile == null){
      return Container(
          width: 70,
          height: 50,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(widget.photo, fit: BoxFit.fill)));
    }else{
      return Container(
          width: 70,
          height: 50,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(widget.imageFile, fit: BoxFit.fill))
      );
    }
  }
}