import 'piece.dart';

class DragData {
  final Piece piece;
  final bool fromTray;
  final int sourceIndex;

  const DragData({
    required this.piece,
    required this.fromTray,
    required this.sourceIndex,
  });
}
