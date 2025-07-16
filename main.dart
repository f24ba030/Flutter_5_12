import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(CheckListApp());

class CheckListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '持ち物チェックリスト',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: CheckListPage(),
    );
  }
}

class CheckListPage extends StatefulWidget {
  @override
  _CheckListPageState createState() => _CheckListPageState();
}

class _CheckListPageState extends State<CheckListPage> {
  List<Map<String, dynamic>> items = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('checklist') ?? '[]';
    setState(() {
      items = List<Map<String, dynamic>>.from(json.decode(jsonStr));
    });
  }

  Future<void> saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('checklist', json.encode(items));
  }

  void addItem(String text) {
    setState(() {
      items.add({'title': text, 'checked': false});
    });
    saveItems();
  }

  void toggleItem(int index) {
    setState(() {
      items[index]['checked'] = !items[index]['checked'];
    });
    saveItems();
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
    saveItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('持ち物チェックリスト')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: 'アイテムを入力'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      addItem(controller.text);
                      controller.clear();
                    }
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) => CheckboxListTile(
                title: Text(items[index]['title']),
                value: items[index]['checked'],
                onChanged: (_) => toggleItem(index),
                secondary: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => removeItem(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
