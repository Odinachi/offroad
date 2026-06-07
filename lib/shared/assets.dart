import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssets {
  static const String apple = 'assets/svg/apple.svg';
  static const String attachment = 'assets/svg/attachment.svg';
  static const String brain = 'assets/svg/brain.svg';
  static const String camera = 'assets/svg/camera.svg';
  static const String chat = 'assets/svg/chat.svg';
  static const String code = 'assets/svg/code.svg';
  static const String doc = 'assets/svg/doc.svg';
  static const String eyeActive = 'assets/svg/eye_active.svg';
  static const String eyeClose = 'assets/svg/eye_close.svg';
  static const String flash = 'assets/svg/flash.svg';
  static const String google = 'assets/svg/google.svg';
  static const String hardDrive = 'assets/svg/hard_drive.svg';
  static const String home = 'assets/svg/home.svg';
  static const String light = 'assets/svg/light.svg';
  static const String lock = 'assets/svg/lock.svg';
  static const String mic = 'assets/svg/mic.svg';
  static const String music = 'assets/svg/music.svg';
  static const String offWifi = 'assets/svg/off_wifi.svg';
  static const String photo = 'assets/svg/photo.svg';
  static const String ramMemory = 'assets/svg/ram_memory.svg';
  static const String search = 'assets/svg/search.svg';
  static const String settings = 'assets/svg/settings.svg';
  static const String shield = 'assets/svg/shield.svg';
  static const String store = 'assets/svg/store.svg';
  static const String text = 'assets/svg/text.svg';
  static const String transcript = 'assets/svg/transcript.svg';
  static const String trash = 'assets/svg/trash.svg';
  static const String url = 'assets/svg/url.svg';
  static const String web = 'assets/svg/web.svg';
}

class AppSvg extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const AppSvg(
    this.assetName, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      fit: fit,
    );
  }
}
