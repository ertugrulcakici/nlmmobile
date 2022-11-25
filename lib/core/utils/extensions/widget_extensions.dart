import 'package:flutter/material.dart';
import 'package:nlmmobile/core/services/theme/custom_theme_data.dart';

extension RoundedImage on Image {
  ClipRRect get frd => ClipRRect(
        borderRadius: CustomThemeData.fullInfiniteRounded,
        child: this,
      );
}
