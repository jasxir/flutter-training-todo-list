import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/components/Item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ToDoList(title: 'To Do List App'),
    );
  }
}

class Storage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/Item.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(String jsonString) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(jsonString);
  }
}

class ToDoList extends StatefulWidget {
  ToDoList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  Item item =  new Item();
  List<Item> itemList = List<Item>();
  TextEditingController itemController = new TextEditingController();
  final Storage storage = new Storage();

  @override
  void initState(){
    super.initState();
//    _loadCounter();

  }

  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String itemStr = prefs.getString('itemList');
    setState(() {
      var tagObjsJson = jsonDecode(itemStr) as List;
      itemList = tagObjsJson.map((tagJson) => Item.fromJson(tagJson)).toList();

    });
  }

  Future<File> _addTask(String task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String itemStr = prefs.getString('itemList');

    setState(() {
      var tagObjsJson = jsonDecode(itemStr) as List;
      itemList = tagObjsJson.map((tagJson) => Item.fromJson(tagJson)).toList();

      item =  new Item();
      item.text = task;
      item.selected = false;
    });
    itemList.add(item);
    String jsonItem =  jsonEncode(itemList);
    return storage.writeCounter(jsonItem);
//    prefs.setString('itemList', jsonItem);
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: itemController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter item list'
              ),
            ),
            FlatButton(
              color: Colors.blueAccent,
              textColor: Colors.white,
              child: Text('Add'),
              onPressed: () {
                _addTask(itemController.text);
              },
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(8.0),
                children: itemList.map((e) => CheckboxListTile(
                    title: Text(e.text),
                    value: e.selected,
                    onChanged: (val){
                      setState(() {
                        e.selected = val;
                      });
                    })).toList(),
              ),
            ),
          ],
        ),

      ),
    );
  }
}
