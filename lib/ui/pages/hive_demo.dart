import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ionicons/ionicons.dart';

import '../../models/user.dart';

class HiveDemo extends StatefulWidget {
  const HiveDemo({super.key});

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
    User newUser = User(
      enumber: 'HW-M59',
      name: 'Ryan',
      dept: '5503',
    );
    //檢查Key是否已存在
    if(box.containsKey('HW-M59')){
      _setMsg('${newUser.enumber} already added to box!');
    }else{
      box.put('HW-M59', newUser);
      _setMsg('${newUser.name} added to box!');
      print(newUser.key);
    }
  }

  // Read info from user box
  _getInfo() {
    //檢查box是否有資料
    if(box.values.isEmpty){
      _setMsg('No User in the box!');
    }else{
      //可以抓出全部
      // box.values.forEach((element) { _setMsg('${element.enumber} ${element.name} In The box!'); });
      if(box.containsKey('HW-M59')){
        User user = box.get('HW-M59');
        print(box.values.length);
        _setMsg('${user.dept}-${user.name} in the box!');
      }else{
        _setMsg('No HW-M59 in the box!');
      }

    }

  }

  // Update info of user box
  _updateInfo() {
    //檢查Key是否已存在
    if(box.containsKey('HW-M59')){
      User user = box.get('HW-M59');
      user.dept = '5502';
      user.save();
      print(box.values.length);
      _setMsg('${user.dept} updated in box!');
    }else{
      _setMsg('No HW-M59 in the box!');
    }
  }

  // Delete info from user box
  _deleteInfo() {
    if(box.containsKey('HW-M59')){
      box.delete('HW-M59');
      print(box.values.length);
      _setMsg('HW-M59 deleted from box!');
    }else{
      _setMsg('No HW-M59 in the box!');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Theme.of(context).colorScheme.background,
      child: Center(
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
                  icon:Icon(Ionicons.server_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Create',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _getInfo();
                  },
                  icon:Icon(Ionicons.server_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Read',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _updateInfo();
                  },
                  icon:Icon(Ionicons.server_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Update',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _deleteInfo();
                  },
                  icon:Icon(Ionicons.server_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Delete',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon:Icon(Ionicons.backspace_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Return Home',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
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
