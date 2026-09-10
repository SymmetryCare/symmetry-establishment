import 'package:flutter/material.dart';


/// Call this anywhere to show the toast
void showTopRightToast(
    BuildContext context, {
      String message = "Your action was successful!",
      bool isSuccess = true, // NEW VARIABLE
    }) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: 100,
        right: 16,
        child: _ToastContent(
          isSuccess: isSuccess,           // PASS VALUE
          message: message,
          onClose: () => entry.remove(),
        ),
      );
    },
  );

  overlay.insert(entry);
}

/// Toast widget
class _ToastContent extends StatefulWidget {
  final VoidCallback onClose;
  final String message;
  final bool isSuccess;  // NEW VARIABLE

  const _ToastContent({
    required this.onClose,
    required this.message,
    required this.isSuccess,
  });

  @override
  State<_ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<_ToastContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.isSuccess ? Icons.check_circle : Icons.cancel,   // 👈 CHANGE
                  color: widget.isSuccess ? Colors.greenAccent : Colors.redAccent,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 3,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 1 - _controller.value,
                      child: Container(
                        height: 3,
                        color: widget.isSuccess
                            ? Colors.greenAccent
                            : Colors.redAccent,  // 👈 CHANGE
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

