import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDemo extends StatefulWidget {
  const HiveDemo({super.key, required this.title});

  final String title;

  @override
  State<HiveDemo> createState() => _HiveDemoState();
}

class _HiveDemoState extends State<HiveDemo> {
  String msg = 'Ready for API requests';
  late final Box box = Hive.box('userBox');

  @override
  void dispose() {
    // Closes all Hive boxes
    Hive.close();
    super.dispose();
  }

  _setMsg(context){
    setState(() {
      msg = '$context';
    });
  }

  // Add info to user box
  _addInfo() async {
    // Storing key-value pair
    box.put('name', 'Ryan');
    box.put('country', 'Taiwan');
    print(box);
    _setMsg('User added to box!');
  }

  // Read info from user box
  _getInfo() {
    var name = box.get('name');
    var country = box.get('country');
    _setMsg('$name ($country)');
  }

  // Update info of user box
  _updateInfo() {
    box.put('name', 'Mike');
    box.put('country', 'US');
    _setMsg('User updated in box!');
  }

  // Delete info from user box
  _deleteInfo() {
    box.delete('name');
    box.delete('country');
    _setMsg('User deleted from box!');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              msg,
              style: Theme.of(context).textTheme.headline5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _addInfo();
                  },
                  icon: Icon(Icons.local_offer_outlined),
                  label: Text(
                    'Create',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _getInfo();
                  },
                  icon: Icon(Icons.local_offer_outlined),
                  label: Text(
                    'Read',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _updateInfo();
                  },
                  icon: Icon(Icons.local_offer_outlined),
                  label: Text(
                    'Update',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _deleteInfo();
                  },
                  icon: Icon(Icons.local_offer_outlined),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.local_offer_outlined),
                  label: Text(
                    'ReturnHome',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
