import 'package:flutter/material.dart';
import 'database_helper.dart';

final dbHelper = DatabaseHelper();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Database Demo',
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 0, 109, 98),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController idController = TextEditingController();
  String _output = '';

  void _showResult(String text) {
    setState(() => _output = text);
  }

  Future<void> _insert() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: 'User ${DateTime.now().millisecondsSinceEpoch % 1000}',
      DatabaseHelper.columnAge: 18 + (DateTime.now().second % 40)
    };
    final id = await dbHelper.insert(row);
    _showResult('Inserted row id: $id');
  }

  Future<void> _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    if (allRows.isEmpty) {
      _showResult('No data found.');
      return;
    }
    String data = allRows.map((r) => '${r['_id']}: ${r['name']} (${r['age']})').join('\n');
    _showResult('All Records:\n$data');
  }

  Future<void> _queryById() async {
    if (idController.text.isEmpty) {
      _showResult('Enter an ID first.');
      return;
    }
    final id = int.tryParse(idController.text);
    if (id == null) {
      _showResult('Invalid ID.');
      return;
    }
    final record = await dbHelper.queryById(id);
    if (record == null) {
      _showResult('No record found for ID $id');
    } else {
      _showResult('Found: ${record['name']} (${record['age']})');
    }
  }

  Future<void> _update() async {
    if (idController.text.isEmpty) {
      _showResult('Enter an ID to update.');
      return;
    }
    final id = int.tryParse(idController.text);
    if (id == null) return;
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: 'Updated User',
      DatabaseHelper.columnAge: 99
    };
    final rowsAffected = await dbHelper.update(row);
    _showResult('Updated $rowsAffected record(s).');
  }

  Future<void> _delete() async {
    if (idController.text.isEmpty) {
      _showResult('Enter an ID to delete.');
      return;
    }
    final id = int.tryParse(idController.text);
    if (id == null) return;
    final rowsDeleted = await dbHelper.delete(id);
    _showResult('Deleted $rowsDeleted record(s).');
  }

  Future<void> _deleteAll() async {
    final rowsDeleted = await dbHelper.deleteAll();
    _showResult('Deleted all ($rowsDeleted) records.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQFlite Local Storage'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 101, 91),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Database Actions',
                        style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 17),
                      TextField(
                        controller: idController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter ID (for query, Update, Delete)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _insert,
                            icon: const Icon(Icons.add),
                            label: const Text('Insert'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _queryAll,
                            icon: const Icon(Icons.list),
                            label: const Text('Query All'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _queryById,
                            icon: const Icon(Icons.search),
                            label: const Text('Query by ID'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _update,
                            icon: const Icon(Icons.edit),
                            label: const Text('Updates'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _delete,
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete ID'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _deleteAll,
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Delete all'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 241, 81, 78),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Card(
                color: const Color.fromARGB(255, 224, 245, 244),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _output,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

