
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class PaperSizeModel{
  final PaperSize paperSize;
  final String sizeName;

  const PaperSizeModel({
    required this.paperSize,
    required this.sizeName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaperSizeModel &&
          paperSize == other.paperSize &&
          sizeName == other.sizeName;

  @override
  int get hashCode => paperSize.hashCode ^ sizeName.hashCode;
}