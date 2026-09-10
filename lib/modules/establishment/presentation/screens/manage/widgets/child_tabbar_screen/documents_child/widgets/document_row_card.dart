import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// One document row in the Documents tabs — a file tile, its id and file name,
/// and the edit / print / download / delete actions.
///
/// Built to the same visual language as the Qualifications cards: white
/// surface, hairline border, rounded corners, Fira Sans labels.
class DocumentRowCard extends StatelessWidget {
  /// Small grey line above the file name, e.g. "ID: Demo - A1". Omit it and
  /// the file name sits centred on its own (Form Status rows).
  final String? idLabel;

  /// Optional pill pinned to the card's top-right corner, e.g. "Signed".
  final String? statusLabel;
  final Color? statusColor;

  /// The file name, e.g. "Dummy.pdf".
  final String fileName;

  final VoidCallback? onEdit;
  final VoidCallback? onPrint;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

  /// Tapping the file tile itself (usually the same as [onDownload]).
  final VoidCallback? onTap;

  /// The glyph in the file tile, and the color the tile is washed in.
  /// Defaults to the red PDF badge the Documents rows use.
  final String iconAsset;
  final Color accentColor;

  /// Shorter card with a smaller tile and smaller actions — for cards that
  /// sit two-up in a grid rather than full width, as Clinical license does.
  final bool dense;

  const DocumentRowCard({
    super.key,
    this.idLabel,
    required this.fileName,
    this.statusLabel,
    this.statusColor,
    this.onEdit,
    this.onPrint,
    this.onDownload,
    this.onDelete,
    this.onTap,
    this.iconAsset = 'images/doc_pdf.svg',
    this.accentColor = _red,
    this.dense = false,
  });

  static const Color _red = Color(0xFFE05D5F);
  static const Color _border = Color(0xFFE8E8E8);
  static const Color _idGrey = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: dense ? 72 : 84,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _fileTile(),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (idLabel != null) ...[
                Text(
                  idLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 17 / 14,
                    color: _idGrey,
                  ),
                ),
                const SizedBox(height: 8),
                ],
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 18 / 15,
                    color: Color(0xFF171717),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (onEdit != null)
            _actionButton('images/doc_edit_pencil.svg', onEdit!),
          if (onPrint != null) _actionButton('images/doc_print.svg', onPrint!),
          if (onDownload != null)
            _actionButton('images/doc_download.svg', onDownload!),
          if (onDelete != null)
            _actionButton('images/doc_delete.svg', onDelete!, danger: true),
        ],
      ),
    );

    if (statusLabel == null) return card;
    // The pill sits flush in the card's top-right corner, so it shares the
    // card's corner radius on that side and is square where it meets the
    // card's edges.
    return Stack(
      children: [
        card,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 70,
            height: 19,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusColor ?? const Color(0xFF1AB595),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Text(
              statusLabel!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fileTile() {
    final double size = dense ? 44 : 58;
    final tile = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(dense ? 10 : 12),
      ),
      child: SvgPicture.asset(
        iconAsset,
        width: dense ? 22 : 26,
        height: dense ? 22 : 31,
      ),
    );
    if (onTap == null) return tile;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: tile,
    );
  }

  Widget _actionButton(String asset, VoidCallback onPressed,
      {bool danger = false}) {
    final double size = dense ? 34 : 38;
    return Padding(
      padding: EdgeInsets.only(left: dense ? 8 : 10),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: danger
                ? _red.withValues(alpha: 0.12)
                : const Color(0xFF000000).withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            asset,
            width: dense ? 14 : 15,
            height: dense ? 14 : 15,
          ),
        ),
      ),
    );
  }
}
