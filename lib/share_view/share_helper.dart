import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';

class ShareHelper {
  static void saveAndShareImage(GlobalKey globalKey) async {
    final boundary =
        globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final image = await boundary?.toImage(pixelRatio: 2.0);
    final byteData = await image?.toByteData(format: ImageByteFormat.png);
    final imageBytes = byteData?.buffer.asUint8List();
    if (imageBytes != null) {
      return shareImage(imageBytes);
    } else {
      throw "이미지 캡처 오류";
    }
  }

  static void shareImage(Uint8List bytesImage) async {
    final directory = (await getTemporaryDirectory()).path;

    String path = "$directory/이미지공유.png";
    File imgFile = File(path);
    imgFile.writeAsBytes(bytesImage);
    await FlutterShare.shareFile(
      title: '계획, 기록 이미지 공유',
      filePath: imgFile.path,
    );
  }
}
