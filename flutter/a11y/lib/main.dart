import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
  // RendererBinding.instance.setSemanticsEnabled(true);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  bool _showTextFields = false;

  void _flipVisibility() {
    setState(() {
      _showTextFields = !_showTextFields;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _showTextFields
            ? <Widget>[
              Semantics(
                label: 'First name',
                child: TextField(),
              ),
              Semantics(
                label: 'Last name',
                child: TextField(),
              ),
              Checkbox(value: true, onChanged: (_) {}),
              // TextField(autofocus: true),
            ]
          : <Widget>[],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _flipVisibility,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
