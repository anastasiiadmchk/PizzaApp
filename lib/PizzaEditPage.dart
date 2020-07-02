import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'MyPizzaIcon.dart';
import 'package:path/path.dart' as Path;

class MyPizzaEditor extends StatefulWidget {
  MyPizzaEditor({Key key, this.photo, this.name, this.storage, this.document}): super(key:key);
  final String photo;
  final String name;
  final String storage;
  final DocumentSnapshot document;

  @override
  _MyPizzaEditorState createState() => _MyPizzaEditorState();
}
class _MyPizzaEditorState extends State<MyPizzaEditor>{
  File imageFile = null;
  //FocusScopeNode _focusScopeNode = FocusScopeNode();
  TextEditingController text = TextEditingController();
  TextEditingController subtext = TextEditingController();

  _openGallery() async{
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image!=null){
        imageFile = image;
      }
      return new MyPizzaIcon(imageFile: imageFile);
    });

  }

  _setName(){
    text.text = widget.name;
    return text;
  }
  _setStorage(){
    subtext.text = widget.storage;
    return subtext;
  }

  void updatePizzaRecord(File image, String text, String subtext) async {
    List<String> storage = subtext.split(", ");
    StorageReference storageReference = await FirebaseStorage.instance.getReferenceFromUrl(widget.photo);
    if (text!=null && subtext!=null){
      if(text!= widget.name){
        widget.document.reference.updateData({'name' : text, });}
      if (subtext != widget.storage){
        widget.document.reference.updateData({'storage' : storage, });}
      if (image != null){
        StorageReference ref = FirebaseStorage.instance.ref().child("images/${Path.basename(image.path)}");
        StorageUploadTask uploadTask = ref.putFile(image);
        final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
        final String url = (await downloadUrl.ref.getDownloadURL());
        widget.document.reference.updateData({'photo' : url});
        await storageReference.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      elevation: 50.0,
      title: Text("Edit Pizza Record", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
      content: SingleChildScrollView(
          child:Column(
            mainAxisSize: MainAxisSize.min,
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ListTile(
                selected: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                leading: new MyPizzaIcon(imageFile: imageFile, photo: widget.photo,),
                title: Text("Edit an image"),
                trailing: IconButton(
                  icon: Icon(Icons.add_a_photo),
                  onPressed: _openGallery,
                ),
              ),
              Container(
                padding: EdgeInsets.only( top: 20, bottom: 10),
                height: 80,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    labelText: 'Edit name of pizza',),
                  controller: _setName(),
                ),),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 5),
                height: 100,
                child: TextField(decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  labelText: 'Edit storage',
                ),
                  controller: _setStorage(),
                ),),
              ButtonTheme(
                  minWidth: 150,
                  child:RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.greenAccent[400],
                      //padding: EdgeInsets.only(top:5, bottom: 5),
                      child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),),
                      onPressed: () {
                        updatePizzaRecord(imageFile, text.text, subtext.text);
                        Navigator.pop(context);
                      }
                  ))

            ],
          )),
    );
  }

}