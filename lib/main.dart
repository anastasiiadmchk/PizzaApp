
import 'BottomSheet.dart';
import 'PizzaEditPage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/painting.dart';


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
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.only(top: 4, right: 4),
                            child:Row(
                                children : [
                                  Container(
                                    padding: EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(width: 1)),
                                      child:GestureDetector(
                                        child: Icon(Icons.edit, color: Colors.black, size: 13,),
                                        onTap: (){
                                          Future(() => showDialog(
                                          context: context,
                                          builder: (context) {
                                            return MyPizzaEditor(photo: document['photo'], name: document['name'], storage: capitalize(document['storage'].reduce((value, element) => value + ', ' + element)), document: document,);
                                          }
                                      ));
                                    },
                                  )),
                                  SizedBox(width: 4,),
                                  Container(
                                    padding: EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(width: 1)),
                                    child:GestureDetector(
                                      child: Icon(Icons.delete, color: Colors.black, size: 12,),
                                      onTap: () async {
                                      String url = document['photo'];
                                      await Firestore.instance.runTransaction((Transaction transaction) async {
                                        await transaction.delete(document.reference);
                                      });
                                      if (url != null){
                                        StorageReference storageReference = await FirebaseStorage.instance.getReferenceFromUrl(url);
                                        await storageReference.delete();}
                                    },
                                  )),
                                ]))
                      ],
                      ),
                    ),
                    Row(children:[Text("Storage:", style: TextStyle(color: Colors.blueGrey, fontSize: 11),),
                    ]),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(right: 10, top: 3),
                        child:Text(capitalize(document['storage'].reduce((value, element) => value + ', ' + element)), style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),)),
                  ],
                )
              ),

            ]
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
      height: 790,
      padding: EdgeInsets.only(bottom: 400),
              child: StreamBuilder(
            stream: Firestore.instance.collection("pizzas").snapshots(),
            builder: (context, snapshot){
              if (!snapshot.hasData) return Center(child:Text("Loading...", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),));
              return ListView.builder(
                  scrollDirection: Axis.vertical,
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
          SizedBox(height: 200,)

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


