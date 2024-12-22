import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'full_state_widget.dart';

class ImageBuilder extends StatefulWidget {
  final String? src;
  final Uint8List? image;
  final String? asset;
  final ImageProvider? provider;
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
    this.src,
    this.image,
    this.asset,
    this.provider,
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
  })  : errorBuilder = errorBuilder ?? _defaultImageErrorWidgetBuilder(),
        loadingBuilder = loadingBuilder ?? _defaultImageLoadingBuilder(),
        frameBuilder = frameBuilder ?? _defaultImageFrameBuilder() {
    if (src == null && image == null && asset == null && provider == null) {
      throw ArgumentError('At least one of resolver, imageUrl, image, asset or provider must be provided');
    }

    final posible = [src, image, asset, provider].where((element) => element != null).length;
    if (posible != 1) {
      throw ArgumentError('Only one of resolver, imageUrl, image or asset must be provided');
    }
  }

  static ImageErrorWidgetBuilder _defaultImageErrorWidgetBuilder() {
    return (BuildContext context, Object error, StackTrace? stackTrace) {
      return const Icon(Icons.error);
    };
  }

  static ImageLoadingBuilder _defaultImageLoadingBuilder() {
    return (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) return child;
      return const CircularProgressIndicator();
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
  @override
  Widget build(BuildContext context) {
    if (widget.image != null) return _memory();
    if (widget.src != null) return _network();
    if (widget.asset != null) return _asset();
    if (widget.provider != null) return _provider();
    return const SizedBox();
  }

  Widget _memory() {
    return Image.memory(
      widget.image!,
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

  Widget _provider() {
    return Image(
      image: widget.provider!,
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
}
