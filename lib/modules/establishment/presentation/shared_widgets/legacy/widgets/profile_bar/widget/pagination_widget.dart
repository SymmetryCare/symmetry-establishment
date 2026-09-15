import 'package:flutter/material.dart';
import 'package:symmetry_establishment/app/resources/color.dart';
import 'package:symmetry_establishment/modules/establishment/data/models/establishment_data/user/user_modal.dart';
import 'package:provider/provider.dart';


///old code

class PaginationControlsWidget extends StatefulWidget {
  final int currentPage;
  final List<dynamic> items;
   int itemsPerPage;
   void Function() onPreviousPagePressed;
   void Function(int) onPageNumberPressed;
   void Function() onNextPagePressed;

   PaginationControlsWidget({
    required this.currentPage,
    required this.items,
    required this.itemsPerPage,
    required this.onPreviousPagePressed,
    required this.onPageNumberPressed,
    required this.onNextPagePressed,
  });

  @override
  State<PaginationControlsWidget> createState() => _PaginationControlsWidgetState();
}

class _PaginationControlsWidgetState extends State<PaginationControlsWidget> {
  @override
  Widget build(BuildContext context) {
    // FIX: hide pagination entirely when everything fits on one page, and
    // show it automatically as soon as the record count grows past a page —
    // this widget is shared across every EM screen with pagination, so this
    // single check covers all of them.
    final totalPages = (widget.items.length / widget.itemsPerPage).ceil();
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: ColorManager.fmediumgrey.withOpacity(0.2),
                width: 0.79,
              ),
            ),
            child: IconButton(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              padding: const EdgeInsets.only(bottom: 1.5),
              icon: const Icon(Icons.chevron_left),
              onPressed: widget.onPreviousPagePressed,
              color: Colors.black,
              iconSize: 20,
            ),
          ),
          const SizedBox(width: 3),
          for (var i = 1; i <= (widget.items.length / widget.itemsPerPage).ceil(); i++)
            if (i == 1 ||
                i == widget.currentPage ||
                i == (widget.items.length / widget.itemsPerPage).ceil())
              InkWell(
                onTap: () => widget.onPageNumberPressed(i),
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: widget.currentPage == i ? ColorManager.blueprime : ColorManager.fmediumgrey.withOpacity(0.2),
                      width: widget.currentPage == i ? 2.0 : 1.0,
                    ),
                    color: widget.currentPage == i ? ColorManager.blueprime : Colors.transparent,
                  ),
                  child: Text(
                    '$i',
                    style: TextStyle(
                      color: widget.currentPage == i ? Colors.white : ColorManager.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            else if (i == widget.currentPage - 1 || i == widget.currentPage + 1)
              const Text(
                '..',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: ColorManager.fmediumgrey.withOpacity(0.2),
                width: 0.79,
              ),
            ),
            child: IconButton(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              padding: const EdgeInsets.only(bottom: 1.5),
              icon: const Icon(Icons.chevron_right),
              onPressed: widget.onNextPagePressed,
              color: Colors.black,
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
