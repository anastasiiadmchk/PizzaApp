//import 'dart:html';
import 'dart:convert';
import 'dart:ffi';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/painting.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
//import 'dart:async';
import 'package:path/path.dart' as Path;

import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Widget _buildListItem(BuildContext context, DocumentSnapshot document){
    return Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(13), ),
      //height: 300,
        child: Row(
            children: [
              Container(
                width: 150,
                height: 100,
                padding: EdgeInsets.only(right: 10,),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(document['photo'],  fit: BoxFit.fill,),)),
              Expanded(
                //width: 300,
                //height: 170,
                //padding: EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 7, bottom: 5, right: 5),
                      height: 38,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children : [
                        Text(capitalize(document['name']), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17), ),
                        Container(
                          padding: EdgeInsets.only(right: 5),
                            child:Row(
                            verticalDirection: VerticalDirection.down,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children : [
                              IconButton(
                                    icon: Icon(Icons.edit, color: Colors.white, size: 18,),
                                    onPressed: (){
                                      Future(() => showDialog(
                                          context: context,
                                          builder: (context) {
                                            return MyPizzaEditor(photo: document['photo'], name: document['name'], storage: capitalize(document['storage'].reduce((value, element) => value + ', ' + element)), document: document,);
                                          }
                                      ));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.white, size: 18,),
                                    onPressed: () async {
                                      String url = document['photo'];
                                      await Firestore.instance.runTransaction((Transaction transaction) async {
                                        await transaction.delete(document.reference);
                                      });
                                      if (url != null){
                                      StorageReference storageReference = await FirebaseStorage.instance.getReferenceFromUrl(url);
                                      await storageReference.delete();}
                                    },
                                  ),
                                ]))

                      ],
                      ),
                    ),
                    Row(children:[Text("Storage:", style: TextStyle(color: Colors.blueGrey, fontSize: 11),),]),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(right: 10, top: 3),
                        child:Text(capitalize(document['storage'].reduce((value, element) => value + ', ' + element)), style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),)),
                  ],
                )
              ),]
        ),

    );
  }

  Widget _buildMyPage(){
    return ListView(
        children: [
          Container(
              padding: EdgeInsets.only(top: 32, left: 13, right: 13, bottom: 30),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/819jYvIkK3L._AC_SL1500_.jpg', width: 60, height: 70, fit: BoxFit.fill,),),
                title: Text("Hello,", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                subtitle: Text("Anastasiia", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),),
              )),
          Container(
            padding:EdgeInsets.only(left: 20),
            child:Text("Pizza List", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold,),),
          ),
          //Expanded(child: Center(child: ))
    Container(
      height: 600,
      padding: EdgeInsets.only(bottom: 200),
              child: StreamBuilder(
            stream: Firestore.instance.collection("pizzas").snapshots(),
            builder: (context, snapshot){
              if (!snapshot.hasData) return const Text("Loading...");
              return ListView.builder(
                  //scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  //itemExtent: 80.0,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index){
                    return Container(
                        margin: EdgeInsets.only(left:20, right:25, top:13, bottom: 3),
                      height: 100,
                        child:_buildListItem(context, snapshot.data.documents[index]));
                  }
              );
            },
          )),



        ]
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: _buildMyPage()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Align (
          alignment: Alignment.bottomCenter,
            child: Container(
              height: 110,
              padding: EdgeInsets.all(17),
                child:ButtonBar(
              alignment:MainAxisAlignment.center,
              buttonMinWidth: 400,
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.greenAccent[400],
                  onPressed: () {
                    Future(() => showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return MyBottomSheet();
                        }
                    ));
                    /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondRoute()),
                  );*/
                  },
                  child: Text("+ Add new pizza", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                ),
              ],

            )))
    );

  }

  String capitalize( String string) {
    if (string == null) {
      throw ArgumentError("string: $string");
    }

    if (string.isEmpty) {
      return string;
    }

    return string[0].toUpperCase() + string.substring(1);
  }
}

class MyBottomSheet extends StatefulWidget {
  //MyBottomSheet({Key key, this.bestOffers, this.callback}): super(key:key);
  //final List<ListTile> bestOffers;
  Function(List<ListTile>) callback;

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet>{
  int _counter = 6;
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

    //Navigator.of(context).pop();
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
