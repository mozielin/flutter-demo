import 'package:flutter/material.dart';
class RouteDemo extends StatefulWidget {
  const RouteDemo({super.key, required this.title});

  final String title;

  @override
  State<RouteDemo> createState() => _RouteDemoState();
}

class _RouteDemoState extends State<RouteDemo> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
              widget.title,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton.icon(
              onPressed: () {
                //Navigator.pushNamed(context, '/route_demo');
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.local_offer_outlined),
              label: Text(
                'RouteDemo',
                style: TextStyle(color: Colors.red),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}