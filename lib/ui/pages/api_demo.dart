import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ionicons/ionicons.dart';

class ApiDemo extends StatefulWidget {
  const ApiDemo({super.key});

  @override
  State<ApiDemo> createState() => _ApiDemoState();
}

class _ApiDemoState extends State<ApiDemo> {
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

    return Material(
      color: Theme.of(context).colorScheme.background,
      child: Center(
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
                  icon:Icon(Ionicons.paper_plane_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Http GET',
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
                    setState(() {
                      _load = true;
                    });
                    postData();
                  },
                  icon:Icon(Ionicons.paper_plane_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Http POST',
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
                    setState(() {
                      _load = true;
                    });
                    putData();
                  },
                  icon:Icon(Ionicons.paper_plane_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Http PUT',
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
                    setState(() {
                      _load = true;
                    });
                    deleteData();
                  },
                  icon:Icon(Ionicons.paper_plane_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Http DELETE',
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
            const SizedBox(height: 36),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
