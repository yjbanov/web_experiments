import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const scale = 1;

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
  var frame = await codec.getNextFrame();
  var uiImage = frame.image;

  Widget useDrawImageRect(FilterQuality quality) {
    return SizedBox(
      width: scaledWidth.toDouble(),
      height: scaledHeight.toDouble(),
      child: CustomPaint(
        painter: _ScaledImagePainter(uiImage, quality),
      ),
    );
  }

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
        withTitle(
          'original (quality: none)',
          Image.asset('assets/pixel-art.png', filterQuality: FilterQuality.none),
        ),
        withTitle(
          'original (quality: high)',
          Image.asset('assets/pixel-art.png', filterQuality: FilterQuality.high),
        ),
        withTitle(
          'scale (quality: none)',
          Image.asset('assets/pixel-art.png', scale: 1 / scale, filterQuality: FilterQuality.none),
        ),
        withTitle(
          'scale (quality: high)',
          Image.asset('assets/pixel-art.png', scale: 1 / scale, filterQuality: FilterQuality.high),
        ),
        withTitle(
          'drawImageRect (quality: none)',
          useDrawImageRect(FilterQuality.none),
        ),
        withTitle(
          'drawImageRect (quality: high)',
          useDrawImageRect(FilterQuality.high),
        ),
        withTitle(
          'HTML canvas',
          Image.network(dataUrl, filterQuality: FilterQuality.none),
        ),
        withTitle(
          '<img>',
          SizedBox(
            width: scaledWidth.toDouble(),
            height: scaledHeight.toDouble(),
            child: HtmlElementView(viewType: 'image-painter'),
          ),
        ),
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

class _ScaledImagePainter extends CustomPainter {
  _ScaledImagePainter(this.image, this.quality);

  final ui.Image image;
  final FilterQuality quality;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size,
      Paint()
        ..filterQuality = quality,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
