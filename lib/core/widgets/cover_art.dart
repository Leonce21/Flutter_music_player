import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_radius.dart';

const _hues = [18.0, 200.0, 280.0, 340.0, 150.0, 45.0];

/// Deterministic gradient placeholder, or real embedded artwork when present.
class CoverArt extends StatelessWidget {
  const CoverArt({super.key, required this.id, required this.type,
    required this.seed, this.size = 52, this.radius = AppRadius.md,
    this.artwork});
  final int id;
  final ArtworkType type;
  final String seed;
  final double size;
  final double radius;
  final Uint8List? artwork;

  static Color _hue(String s) =>
      HSLColor.fromAHSL(1, _hues[s.hashCode.abs() % _hues.length], 0.55, 0.35)
          .toColor();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: artwork != null
          ? Image.memory(artwork!, width: size, height: size, fit: BoxFit.cover)
          : Container(
              width: size, height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_hue(seed), AppColors.primaryAlpha(140)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Icon(AppIcons.musicNote,
                  size: size * 0.4, color: AppColors.textPrimary.withValues(alpha: 0.8)),
            ),
    );
  }
}

class ArtworkLoader extends StatelessWidget {
  const ArtworkLoader({super.key, required this.id, required this.type,
    required this.seed, this.size = 52, this.radius = AppRadius.md});
  final int id; final ArtworkType type; final String seed;
  final double size; final double radius;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: OnAudioQuery().queryArtwork(id, type),
      builder: (c, snap) => CoverArt(id: id, type: type, seed: seed,
          size: size, radius: radius, artwork: snap.data),
    );
  }
}

/// Big folder-with-dash glyph seen on Folders tab / Folder detail.
class FolderGlyph extends StatelessWidget {
  const FolderGlyph({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(AppIcons.folder, size: size, color: AppColors.primary);
  }
}

class CircleAvatarArt extends StatelessWidget {
  const CircleAvatarArt({super.key, required this.id, required this.seed,
      this.size = 56});
  final int id; final String seed; final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(child: ArtworkLoader(id: id, type: ArtworkType.ARTIST,
        seed: seed, size: size, radius: size));
  }
}

double hashHue(String s) => Random(s.hashCode).nextDouble() * 360;