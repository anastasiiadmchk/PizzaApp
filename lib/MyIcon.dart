import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyIcon extends StatefulWidget {
  MyIcon({Key key, this.imageFile}): super(key:key);
  final File imageFile;

  @override
  _MyIconState createState() => _MyIconState();
}

class _MyIconState extends State<MyIcon> {
  //File get imageFile => null;
  @override
  Widget build(BuildContext context) {
    if(widget.imageFile != null){
      return Container(
          width: 50,
          height: 50,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(widget.imageFile, fit: BoxFit.fill)));
    }else{
      return Container(
        child: Icon(Icons.check_box_outline_blank, size: 40,),
      );
    }
  }
}