import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final class SvgAsset {
  const SvgAsset(this.path);

  final String path;

  /// Renders this asset via [SvgPicture.asset].
  SvgPicture svg({
    Key? key,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    AssetBundle? bundle,
    String? package,
    WidgetBuilder? placeholderBuilder,
    SvgTheme? theme,
    ColorFilter? colorFilter,
  }) {
    return SvgPicture.asset(
      path,
      key: key,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      colorFilter:
          colorFilter ??
          (color != null ? ColorFilter.mode(color, colorBlendMode) : null),
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      bundle: bundle,
      package: package,
      placeholderBuilder: placeholderBuilder,
      theme: theme,
    );
  }
}

/// Bundled raster under `assets/pngs/` (declared in `pubspec.yaml`).
final class ImageAsset {
  const ImageAsset(this.path);

  final String path;

  /// Renders this asset via [Image.asset].
  Image image({
    Key? key,
    double? width,
    double? height,
    Color? color,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
  }) {
    return Image.asset(
      path,
      key: key,
      width: width,
      height: height,
      color: color,
      fit: fit,
      alignment: alignment,
    );
  }
}

final class PngAssets {
  final ImageAsset deepseek;
  final ImageAsset gemma;
  final ImageAsset qwen;
  final ImageAsset microsoft;

  const PngAssets({
    this.deepseek = const ImageAsset('assets/pngs/deepseek.png'),
    this.gemma = const ImageAsset('assets/pngs/gemma.png'),
    this.qwen = const ImageAsset('assets/pngs/qwen.png'),
    this.microsoft = const ImageAsset('assets/pngs/microsoft.png'),
  });
}

/// All SVGs under `assets/svgs/`. Example: `Assets.svg.home.svg(width: 24)`.
final class SvgAssets {
  final SvgAsset apple;
  final SvgAsset attachment;
  final SvgAsset brain;
  final SvgAsset camera;
  final SvgAsset chat;
  final SvgAsset code;
  final SvgAsset doc;
  final SvgAsset eyeActive;
  final SvgAsset eyeClose;
  final SvgAsset flash;
  final SvgAsset google;
  final SvgAsset hardDrive;
  final SvgAsset home;
  final SvgAsset light;
  final SvgAsset lock;
  final SvgAsset mic;
  final SvgAsset music;
  final SvgAsset offWifi;
  final SvgAsset photo;
  final SvgAsset ramMemory;
  final SvgAsset search;
  final SvgAsset settings;
  final SvgAsset shield;
  final SvgAsset store;
  final SvgAsset text;
  final SvgAsset transcript;
  final SvgAsset trash;
  final SvgAsset url;
  final SvgAsset web;
  final SvgAsset appLogo;

  const SvgAssets({
    this.web = const SvgAsset('assets/svg/web.svg'),
    this.url = const SvgAsset('assets/svg/url.svg'),
    this.attachment = const SvgAsset('assets/svg/attachment.svg'),
    this.brain = const SvgAsset('assets/svg/brain.svg'),
    this.camera = const SvgAsset('assets/svg/camera.svg'),
    this.chat = const SvgAsset('assets/svg/chat.svg'),
    this.code = const SvgAsset('assets/svg/code.svg'),
    this.doc = const SvgAsset('assets/svg/doc.svg'),
    this.eyeActive = const SvgAsset('assets/svg/eye_active.svg'),
    this.eyeClose = const SvgAsset('assets/svg/eye_close.svg'),
    this.flash = const SvgAsset('assets/svg/flash.svg'),
    this.google = const SvgAsset('assets/svg/google.svg'),
    this.hardDrive = const SvgAsset('assets/svg/hard_drive.svg'),
    this.home = const SvgAsset('assets/svg/home.svg'),
    this.light = const SvgAsset('assets/svg/light.svg'),
    this.lock = const SvgAsset('assets/svg/lock.svg'),
    this.mic = const SvgAsset('assets/svg/mic.svg'),
    this.music = const SvgAsset('assets/svg/music.svg'),
    this.offWifi = const SvgAsset('assets/svg/off_wifi.svg'),
    this.photo = const SvgAsset('assets/svg/photo.svg'),
    this.ramMemory = const SvgAsset('assets/svg/ram_memory.svg'),
    this.search = const SvgAsset('assets/svg/search.svg'),
    this.settings = const SvgAsset('assets/svg/settings.svg'),
    this.shield = const SvgAsset('assets/svg/shield.svg'),
    this.store = const SvgAsset('assets/svg/store.svg'),
    this.text = const SvgAsset('assets/svg/text.svg'),
    this.transcript = const SvgAsset('assets/svg/transcript.svg'),
    this.trash = const SvgAsset('assets/svg/trash.svg'),
    this.apple = const SvgAsset('assets/svg/apple.svg'),
    this.appLogo = const SvgAsset('assets/svg/app_logo.svg'),
  });
}

/// Typed asset entry points (AGENT.md §8).
abstract final class Assets {
  static const svg = SvgAssets();
  static const png = PngAssets();
}
