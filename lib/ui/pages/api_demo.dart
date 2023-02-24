import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hws_app/cubit/bottom_nav_cubit.dart';
import 'package:ionicons/ionicons.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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
        msg = e.message!;
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
        msg = e.message!;
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
        msg = e.message!!;
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
        msg = e.message!!;
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
            Column (
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {
                    String credentials = "username:password";
                    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
                    String encoded = stringToBase64Url.encode(credentials);      // dXNlcm5hbWU6cGFzc3dvcmQ=
                    String tzucode = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJId2Fjb21FSVAiLCJpYXQiOjE2NzI4MjU3MTUsImV4cCI6MTY3MjgyNjYxNSwic3ViIjoiaHdhY29tLmNvbSIsImp0aSI6ImY5YmYwN2ExNzNhZmNlOWUzMTdiMDgwOGY4MjFiNGFlIiwiZ29vZ2xlX3Rva2VuIjoiIiwibmFtZSI6IueuoeWtkOS6mCIsImVtYWlsIjoidHp1aHN1YW4ua3VhbkBod2Fjb20uY29tIiwiZW51bWJlciI6IkhXLU82OCIsImF2YXRhciI6IlwvYXZhdGFyXC8xNWI5ZWRiYy00Mzg4LTRkYTAtOWU5YS05YjBkMTQxNzJlYmIucG5nIn0.5gDRwmqGAnXfYO2NS6wchUv02hwuAWNIY53JMYygJJg';
                    var array = tzucode.split('.');
                    var remainder = array[1].length % 4;
                    var addlen = 4 - remainder;

                    for(var i = 0; i < addlen; i++){
                      array[1] += '=';
                    }
                    //print(array[1]);
                    String decoded = stringToBase64Url.decode(array[1]);

                    //print(decoded);
                    final parsed = jsonDecode(decoded);
                    //print(parsed['exp']);
                    var date = DateTime.fromMillisecondsSinceEpoch(parsed['exp'] * 1000);
                    //print(date);

                    print(DateTime.now());

                    print(DateTime.fromMillisecondsSinceEpoch(
                      parsed['exp'] * 1000,
                      isUtc: false,
                    ));

                    bool isExpired = DateTime.now().isAfter(
                      DateTime.fromMillisecondsSinceEpoch(
                        parsed['exp'] * 1000,
                        isUtc: false,
                      ),
                    );

                    print(isExpired);
                  },
                  icon:Icon(Ionicons.paper_plane_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Crypto Test',
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
                    //判斷可以跳頁才pop，不然沒有上一頁會掉到黑洞裡
                    if (Navigator.of(context).canPop()){
                      Navigator.of(context).pop();
                    }else {
                      //不能跳頁用bloc控制screen index state 回到要的頁面
                      context.read<BottomNavCubit>().updateIndex(1);
                    }
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
