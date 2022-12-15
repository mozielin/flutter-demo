import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RouteDemo extends StatefulWidget {
  const RouteDemo({super.key, required this.title});

  final String title;

  @override
  State<RouteDemo> createState() => _RouteDemoState();
}

class _RouteDemoState extends State<RouteDemo> {
  final Dio dio = Dio();
  bool _load = false;
  String msg = 'Ready for API requests';

  getData() async {
    try {
      Response res = await dio.get('http://10.0.2.2/api/app_demo');
      if (res.statusCode == 200 && res.data != null) {
        print(res.data['message']);
        setState(() {
          msg = res.data['message'];
          _load = false;
        });
        return msg;
      } else {
        debugPrint('Response Error');
        setState(() {
          var code = res.statusCode;
          msg = '$code';
          _load = false;
        });
      }
    } on DioError catch (e) {
      debugPrint('Dio Error => $e');
      setState(() {
        msg = e.message;
        _load = false;
      });
      rethrow;
    } catch (e) {
      debugPrint('$e');
      setState(() {
        _load = false;
      });
      rethrow;
    }

    if (mounted) {
      setState(() {});
    }
  }

  postData() async {
    try {
      Response res = await dio.post('http://10.0.2.2/api/app_demo');
      if (res.statusCode == 200 && res.data != null) {
        print(res.data['message']);
        setState(() {
          msg = res.data['message'];
          _load = false;
        });
        return msg;
      } else {
        setState(() {
          var code = res.statusCode;
          msg = '$code';
          _load = false;
        });
      }
    } on DioError catch (e) {
      debugPrint('Dio Error => $e');
      setState(() {
        msg = e.message;
        _load = false;
      });
      rethrow;
    } catch (e) {
      debugPrint('$e');
      setState(() {
        _load = false;
      });
      rethrow;
    }

    if (mounted) {
      setState(() {});
    }
  }

  putData() async {
    try {
      Response res = await dio.put('http://10.0.2.2/api/app_demo/1');
      if (res.statusCode == 200 && res.data != null) {
        print(res.data['message']);
        setState(() {
          msg = res.data['message'];
          _load = false;
        });
        return msg;
      } else {
        debugPrint('Response Error');
        setState(() {
          var code = res.statusCode;
          msg = '$code';
          _load = false;
        });
      }
    } on DioError catch (e) {
      debugPrint('Dio Error => $e');
      setState(() {
        msg = e.message;
        _load = false;
      });
      rethrow;
    } catch (e) {
      debugPrint('$e');
      setState(() {
        _load = false;
      });
      rethrow;
    }

    if (mounted) {
      setState(() {});
    }
  }

  deleteData() async {
    try {
      Response res = await dio.delete('http://10.0.2.2/api/app_demo/1');
      if (res.statusCode == 200 && res.data != null) {
        print(res.data['message']);
        setState(() {
          msg = res.data['message'];
          _load = false;
        });
        return msg;
      } else {
        debugPrint('Response Error');
        setState(() {
          var code = res.statusCode;
          msg = '$code';
          _load = false;
        });
      }
    } on DioError catch (e) {
      debugPrint('Dio Error => $e');
      setState(() {
        msg = e.message;
        _load = false;
      });
      rethrow;
    } catch (e) {
      debugPrint('$e');
      setState(() {
        _load = false;
      });
      rethrow;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _load
        ? Container(
            width: 70.0,
            height: 70.0,
            child: Padding(padding: EdgeInsets.all(5.0), child: Center(child: CircularProgressIndicator())),
          )
        : SizedBox(width:70, height: 70 );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(alignment: FractionalOffset.center, child: loadingIndicator),
            Text(
              msg,
              style: Theme.of(context).textTheme.headline4,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _load = true;
                    });
                    getData();
                  },
                  icon: const Icon(Icons.add_link_rounded),
                  label: const Text(
                    'Http GET',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _load = true;
                    });
                    postData();
                  },
                  icon: Icon(Icons.add_link_rounded),
                  label: Text(
                    'Http POST',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _load = true;
                    });
                    putData();
                  },
                  icon: Icon(Icons.add_link_rounded),
                  label: Text(
                    'Http PUT',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _load = true;
                    });
                    deleteData();
                  },
                  icon: Icon(Icons.add_link_rounded),
                  label: Text(
                    'Http DELETE',
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
