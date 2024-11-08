import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sona/application/common/utils/full_state_widget.dart';

typedef BytesResolver = Future<Uint8List> Function();

final Logger _log = Logger();

class ImageBuilder extends StatefulWidget {
  final BytesResolver? resolver;
  final String? src;
  final Uint8List? image;
  final String? asset;
  final Widget errorIndicator;
  final Widget loadingIndicator;
  final ImageFrameBuilder? frameBuilder;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final double? width;
  final double? height;
  final Color? color;
  final Animation<double>? opacity;
  final FilterQuality filterQuality;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final bool isAntiAlias;

  ImageBuilder({
    super.key,
    this.resolver,
    this.src,
    this.image,
    this.asset,
    this.errorIndicator = const Icon(Icons.error),
    this.loadingIndicator = const CircularProgressIndicator(),
    final ImageFrameBuilder? frameBuilder,
    final ImageLoadingBuilder? loadingBuilder,
    final ImageErrorWidgetBuilder? errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
  })  : errorBuilder = errorBuilder ?? _defaultImageErrorWidgetBuilder(errorIndicator),
        loadingBuilder = loadingBuilder ?? _defaultImageLoadingBuilder(loadingIndicator),
        frameBuilder = frameBuilder ?? _defaultImageFrameBuilder() {
    if (resolver == null && src == null && image == null && asset == null) {
      throw ArgumentError('At least one of resolver, imageUrl, image or asset must be provided');
    }

    final posible = [resolver, src, image, asset].where((element) => element != null).length;
    if (posible != 1) {
      throw ArgumentError('Only one of resolver, imageUrl, image or asset must be provided');
    }
  }

  static ImageErrorWidgetBuilder _defaultImageErrorWidgetBuilder(Widget errorIndicator) {
    return (BuildContext context, Object error, StackTrace? stackTrace) {
      _log.e("Error on load image", error: error, stackTrace: stackTrace);
      return errorIndicator;
    };
  }

  static ImageLoadingBuilder _defaultImageLoadingBuilder(Widget loadingIndicator) {
    return (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) return child;
      return loadingIndicator;
    };
  }

  static ImageFrameBuilder _defaultImageFrameBuilder() {
    return (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
      if (wasSynchronouslyLoaded) return child;
      return AnimatedOpacity(
        opacity: frame == null ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: child,
      );
    };
  }

  @override
  State<ImageBuilder> createState() => _ImageState();
}

class _ImageState extends FullState<ImageBuilder> {
  Uint8List? image;
  bool error = false;

  @override
  void initState() {
    super.initState();
    widget.resolver?.call().then((image) {
      this.image = image;
    }).catchError((Object? e, StackTrace? s) {
      error = true;
      _log.e("Error on load image", error: e, stackTrace: s);
    }).whenComplete(refresh);
  }

  @override
  Widget build(BuildContext context) {
    if (error) return widget.errorIndicator;
    if (widget.image != null) return _memory(widget.image);
    if (widget.src != null) return _network();
    if (widget.asset != null) return _asset();
    if (widget.resolver != null) return _resolved();
    return widget.errorIndicator;
  }

  Widget _memory(Uint8List? image) {
    return Image.memory(
      image!,
      frameBuilder: widget.frameBuilder,
      errorBuilder: widget.errorBuilder,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      width: widget.width,
      height: widget.height,
      color: widget.color,
      opacity: widget.opacity,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: widget.gaplessPlayback,
      isAntiAlias: widget.isAntiAlias,
      filterQuality: widget.filterQuality,
    );
  }

  Widget _asset() {
    return Image.asset(
      widget.asset!,
      frameBuilder: widget.frameBuilder,
      errorBuilder: widget.errorBuilder,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      width: widget.width,
      height: widget.height,
      color: widget.color,
      opacity: widget.opacity,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: widget.gaplessPlayback,
      isAntiAlias: widget.isAntiAlias,
      filterQuality: widget.filterQuality,
    );
  }

  Widget _resolved() {
    return image != null ? _memory(image) : widget.loadingIndicator;
  }

  Widget _network() {
    return Image.network(
      widget.src!,
      loadingBuilder: widget.loadingBuilder,
      errorBuilder: widget.errorBuilder,
      frameBuilder: widget.frameBuilder,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      width: widget.width,
      height: widget.height,
      color: widget.color,
      opacity: widget.opacity,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: widget.gaplessPlayback,
      isAntiAlias: widget.isAntiAlias,
      filterQuality: widget.filterQuality,
    );
  }
}
