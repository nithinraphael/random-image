import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:transparent_image/transparent_image.dart';

class BFadeInImageFallback extends HookWidget {
  const BFadeInImageFallback._({
    super.key,
    required this.url,
    this.fit,
    this.onError,
    this.fallBackImage,
    this.errorFallbackWidget,
    this.gradientLoader,
  });

  factory BFadeInImageFallback.withImageFallback({
    Key? key,
    required String url,
    required AssetImage fallBackImage,
    BoxFit? fit,
    void Function({bool isErrored})? onError,
    Gradient? gradientLoader,
  }) => BFadeInImageFallback._(
    key: key,
    url: url,
    fallBackImage: fallBackImage,
    fit: fit,
    onError: onError,
    gradientLoader: gradientLoader,
  );

  factory BFadeInImageFallback.withWidgetFallback({
    Key? key,
    required String url,
    BoxFit? fit,
    void Function({bool isErrored})? onError,
    required Widget errorFallbackWidget,
    Gradient? gradientLoader,
  }) => BFadeInImageFallback._(
    key: key,
    url: url,
    fit: fit,
    onError: onError,
    errorFallbackWidget: errorFallbackWidget,
    gradientLoader: gradientLoader,
  );

  final String url;
  final BoxFit? fit;
  final void Function({bool isErrored})? onError;
  final AssetImage? fallBackImage;
  final Widget? errorFallbackWidget;
  final Gradient? gradientLoader;

  bool _isValidUrl(String u) {
    final trimmed = u.trim();
    return trimmed.isNotEmpty &&
        (trimmed.startsWith('http') || trimmed.startsWith('data:image'));
  }

  bool _isBase64(String u) =>
      u.startsWith('data:image') ||
      (u.length > 100 && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(u));

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl(url)) return _handleError();

    final isBase64 = useMemoized(() => _isBase64(url), [url]);
    final bytes = useMemoized(() {
      if (!isBase64) return null;
      try {
        final base64Str = url.contains(',') ? url.split(',').last : url;
        return base64Decode(base64Str);
      } catch (_) {
        return null;
      }
    }, [url, isBase64]);

    if (isBase64 && bytes != null) {
      return Image.memory(
        bytes,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (c, e, s) => _handleError(),
      );
    }

    if (gradientLoader != null) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (_, __) =>
            Container(decoration: BoxDecoration(gradient: gradientLoader)),
        fadeInDuration: const Duration(milliseconds: 300),
        errorWidget: (_, __, ___) => _handleError(),
      );
    }

    return FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      image: CachedNetworkImageProvider(url),
      fit: fit,
      imageErrorBuilder: (context, error, stackTrace) => _handleError(),
      fadeInDuration: const Duration(milliseconds: 600),
    );
  }

  Widget _handleError() {
    onError?.call(isErrored: true);
    return errorFallbackWidget ?? _buildFallbackImage();
  }

  Widget _buildFallbackImage() => fallBackImage == null
      ? const SizedBox()
      : Image(image: fallBackImage!, fit: fit ?? BoxFit.cover);
}

class BFadeInAssetImage extends StatelessWidget {
  const BFadeInAssetImage({super.key, required this.image, this.fit});
  final AssetImage image;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) => FadeInImage(
    placeholder: MemoryImage(kTransparentImage),
    image: image,
    fit: fit,
    fadeInDuration: const Duration(milliseconds: 600),
  );
}
