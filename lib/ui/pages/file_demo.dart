import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:hws_app/service/ImageController.dart';
import 'package:dio/dio.dart' as api;

import '../../cubit/bottom_nav_cubit.dart';

class FileDemo extends StatefulWidget {
  const FileDemo({super.key});

  @override
  State<FileDemo> createState() => _FileDemoState();
}

class _FileDemoState extends State<FileDemo> {
  String msg = 'Try to Upload a photo';
  late File img = File('your initial file');
  late final Box box = Hive.box('userBox');
  final api.Dio dio = api.Dio();
  bool _load = false;
  final _imageFilePath = "".obs;
  set imageFilePath(value) => this._imageFilePath.value = value;
  get imageFilePath => this._imageFilePath.value;

  @override
  void initState() {
    super.initState();
  }

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

  /// 取得app flutter目錄(移除APP才會消失)
  Future<File> _getLocalDocumentFile() async {
    final dir = await getApplicationDocumentsDirectory();
    var directory = await Directory('${dir.path}/userUpload').create(recursive: true);
    print(directory);
    return File('${dir.path}/userUpload/str.txt');
  }

  /// 取得cache目錄(可被清空)
  Future<File> _getLocalTemporaryFile() async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/str.txt');
  }

  /// 取得App內檔案目錄(移除APP才會消失)
  Future<File> _getLocalSupportFile() async {
    final dir = await getApplicationSupportDirectory();
    print(dir);
    return File('${dir.path}/str.txt');
  }

  /// 測試寫入
  Future<void> writeString(String str) async {
    String txt = 'Test';
    final file = await _getLocalDocumentFile();
    await file.writeAsString(txt);

    final file1 = await _getLocalTemporaryFile();
    await file1.writeAsString(txt);

    final file2 = await _getLocalSupportFile();
    await file2.writeAsString('txt');
    print("Success write Files");
  }

  ///寫入圖片
  Future<void> getImage(ImageSource source) async{
    // Step 1: 彈出圖片選擇
    final XFile? image = await ImagePicker().pickImage(source: source);

    // Step 2: 判斷是否有選擇到圖片
    if (image == null) return;

    // Step 3: 取得檔案目錄.
    final dir = await getTemporaryDirectory();
    // Step 4: 複製檔案到儲存目錄;
    // final localImage = await image.saveTo(directory.path + image.name);

    var imageFile = await cropImage(image.path);
    //GallerySaver.saveImage(imageFilePath);
   // var imgFile = GallerySaver.saveImage(imageFilePath);
    postData(imageFile);
  }

  postData(file) async {
    try {
      api.FormData formData = api.FormData.fromMap({
        "files": await api.MultipartFile.fromFile(
          file.path,
          filename: 'test.png',
        ),
      });
      api.Response res = await dio.post('http://10.0.2.2/api/app_demo', data: formData);
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
    } on api.DioError catch (e) {
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

  ///擷取圖片
  Future cropImage(String pickedFilePath) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFilePath,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.original,
          //CropAspectRatioPreset.ratio4x3,
          //CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          //CropAspectRatioPreset.ratio4x3,
          //CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blueAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(title: 'Cropper'));
    if (croppedFile != null) {
      setState(() {
        img = croppedFile;
      });
      return croppedFile;
    } else {
      return null;
    }
  }

  ///測試讀取文字
  Future<void> readString() async {
    try {
      final file = await _getLocalDocumentFile();
      final result  = await file.readAsString();
      print("result-----$result");

      final file1 = await _getLocalTemporaryFile();
      final result1  = await file1.readAsString();
      print("result1-----$result1");

      final file2 = await _getLocalSupportFile();
      final result2  = await file2.readAsString();
      print("result2-----$result2");

    } catch (e) {
      print(e);
    }
  }

  ///取得asset圖片轉成File
  Future<File> _getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/img/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            msg,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .apply(fontWeightDelta: 2, fontSizeDelta: -2),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(img),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(5.0),
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border.all(width: 8.0, color: Colors.white30),
                  ),
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              getImage(ImageSource.camera);
              //ImageController().getImage(ImageSource.camera);
            },
            icon:Icon(Ionicons.camera_outline, color: Theme.of(context).colorScheme.primary),
            label: Text(
              '相機',
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
            onPressed: () async {
              getImage(ImageSource.gallery);
              //ImageController().getImage(ImageSource.camera);
            },
            icon:Icon(Ionicons.image_outline, color: Theme.of(context).colorScheme.primary),
            label: Text(
              '相簿',
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
          const SizedBox(height: 5),
          //buildimage(),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
