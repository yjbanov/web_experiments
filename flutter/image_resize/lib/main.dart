import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const double scale = 1.3;
const List<int> scaleTest3x3Png = <int>[
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x03, 0x08, 0x02, 0x00, 0x00, 0x00, 0xd9, 0x4a, 0x22, 0xe8, 0x00, 0x00, 0x00, 0x1b, 0x49, 0x44, 0x41, 0x54, 0x08, 0xd7, 0x63, 0x64, 0x60, 0x60, 0xf8, 0xff, 0xff, 0x3f, 0x03, 0x9c, 0xfa, 0xff, 0xff, 0x3f, 0xc3, 0xff, 0xff, 0xff, 0x21, 0x1c, 0x00, 0xcb, 0x70, 0x0e, 0xf3, 0x5d, 0x11, 0xc2, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
];

void main() async {
  var url = '/assets/assets/pixel-art.png';
  var image = html.ImageElement(src: url);
  await image.onLoad.first;

  var scaledWidth = (image.width * scale).toInt();
  var scaledHeight = (image.height * scale).toInt();
  var canvas = html.CanvasElement(width: scaledWidth, height: scaledHeight);
  var ctx = canvas.context2D;
  ctx.drawImageScaled(image, 0, 0, scaledWidth, scaledHeight);
  var dataUrl = canvas.toDataUrl();

  var codec = await ui.instantiateImageCodec(await http.readBytes(url));

  var completer = Completer<ui.Image>();
  ui.decodeImageFromList(Uint8List.fromList(scaleTest3x3Png), completer.complete);
  var frame = await codec.getNextFrame();
  // var uiImage = frame.image;
  var uiImage = await completer.future;

  Widget useDrawImageRect(FilterQuality quality) {
    return SizedBox(
      width: scaledWidth.toDouble(),
      height: scaledHeight.toDouble(),
      child: CustomPaint(
        painter: _DrawImageRectPainter(uiImage, quality),
      ),
    );
  }

  Widget useCanvasScale(FilterQuality quality) {
    return SizedBox(
      width: scaledWidth.toDouble(),
      height: scaledHeight.toDouble(),
      child: CustomPaint(
        painter: _CanvasScalePainter(uiImage, quality),
      ),
    );
  }

  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
    'image-painter',
    (int id) {
      return html.ImageElement()
        ..src = url;
    },
  );

  runApp(Directionality(
    textDirection: TextDirection.ltr,
    child: Column(
      children: [
        Text('Scale ${scale}x'),
        withTitle(
          'Image.asset (unscaled)',
          Image.asset('assets/pixel-art.png'),
        ),
        withTitle(
          'Transform > Image.asset (FilterQuality.none)',
          Transform(
            transform: Matrix4.diagonal3Values(scale, scale, 1.0),
            child: Image.asset('assets/pixel-art.png', filterQuality: FilterQuality.none)),
        ),
        withTitle(
          'Transform > Image.asset (FilterQuality.high)',
          Transform(
            transform: Matrix4.diagonal3Values(scale, scale, 1.0),
            child: Image.asset('assets/pixel-art.png', filterQuality: FilterQuality.high)),
        ),
        withTitle(
          'drawImageRect()',
          useDrawImageRect(FilterQuality.high),
        ),
        withTitle(
          'Canvas.scale() > drawImage()',
          useCanvasScale(FilterQuality.high),
        ),
        // withTitle(
        //   '<canvas>.toDataUrl()',
        //   Image.network(dataUrl, filterQuality: FilterQuality.none),
        // ),
        // withTitle(
        //   '<img>',
        //   SizedBox(
        //     width: scaledWidth.toDouble(),
        //     height: scaledHeight.toDouble(),
        //     child: HtmlElementView(viewType: 'image-painter'),
        //   ),
        // ),
      ],
    ),
  ));
}

Widget withTitle(String title, Widget child) {
  return Padding(
    padding: EdgeInsets.all(10),
    child: Row(
      children: [
        child,
        SizedBox(width: 10, height: 10,),
        Text(title),
      ],
    ),
  );
}

class _CanvasScalePainter extends CustomPainter {
  _CanvasScalePainter(this.image, this.quality);

  final ui.Image image;
  final FilterQuality quality;

  @override
  void paint(Canvas canvas, Size size) {
    double scale = size.width / image.width;
    canvas.scale(scale);
    canvas.drawImage(
      image,
      Offset.zero,
      Paint()
        ..filterQuality = quality,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _DrawImageRectPainter extends CustomPainter {
  _DrawImageRectPainter(this.image, this.quality);

  final ui.Image image;
  final FilterQuality quality;

  @override
  void paint(Canvas canvas, Size size) {
    final srcRect = Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble());
    final dstRect = Offset.zero & size;
    canvas.drawImageRect(
      image,
      srcRect,
      dstRect,
      Paint()
        ..filterQuality = quality,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
