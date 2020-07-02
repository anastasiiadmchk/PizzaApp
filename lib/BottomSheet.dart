import 'MyIcon.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class MyBottomSheet extends StatefulWidget {
  //MyBottomSheet({Key key, this.bestOffers, this.callback}): super(key:key);
  //final List<ListTile> bestOffers;
  Function(List<ListTile>) callback;

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet>{
  File imageFile = null;
  final databaseReference = Firestore.instance;
  TextEditingController text = TextEditingController();
  TextEditingController subtext = TextEditingController();

  _openGallery() async{

    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image!=null){
        imageFile = image;
      }
      return new MyIcon(imageFile: imageFile);
    });

    //Navigator.of(context).pop();
  }

  /*Widget _chooseImage(){
    if (imageFile!= null) {
      return Container (
          width: 50,
          height: 50,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10), child: Image.file(imageFile, fit: BoxFit.fill)));
    } else{
      return Container(
        child: Icon(Icons.check_box_outline_blank, size: 40,),
      );}
  }*/

  void clearFields() {
    text.clear();
    subtext.clear();
    //price.clear();
    //super.dispose();
    imageFile = null;

  }

  void createPizzaRecord(File image, String text, String subtext) async {
    List<String> storage = subtext.split(", ");
    if (image!=null && text!=null && subtext!=null){

      StorageReference ref = FirebaseStorage.instance.ref().child("images/${Path.basename(image.path)}");
      StorageUploadTask uploadTask = ref.putFile(image);
      final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
      final String url = (await downloadUrl.ref.getDownloadURL());
      await databaseReference.collection('pizzas').add({
        'name' : text,
        'storage' : storage,
        'photo' : url,
      });

    }
  }


  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 350.0,
      color: Color(0xFF737373),
      child: new Container(
        decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0))),
        child: Center(
          child: Column(
            children: <Widget>[
              Container(padding: EdgeInsets.only(top:22, bottom: 5), child: Text("Add your Pizza Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),),),
              ListTile(
                leading: new MyIcon(imageFile: imageFile),
                title: Text("Choose an image"),
                trailing: IconButton(
                  icon: Icon(Icons.add_a_photo),
                  onPressed: _openGallery,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                height: 80,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    labelText: 'Enter name of pizza',),
                  controller: text,
                ),),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                height: 100,
                child: TextField(decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  labelText: 'Enter storage',
                ),
                  controller: subtext,
                ),),

              ButtonTheme(
                  minWidth: 130,
                  child:RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.orange,
                      padding: EdgeInsets.only(top:5, bottom: 5),
                      child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),),
                      onPressed: () {
                        createPizzaRecord(imageFile, text.text, subtext.text);
                        Navigator.pop(context);
                      }
                  ))
            ],
          ),
        ),
      ),
    );
  }

}