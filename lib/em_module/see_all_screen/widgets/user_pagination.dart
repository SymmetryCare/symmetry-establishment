
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/data/api_data/establishment_data/user/user_modal.dart';
import 'package:provider/provider.dart';

class SeeAllPaginationProvider extends ChangeNotifier {
  int _currentPage = 1;
  final int itemsPerPage;
  List<UserModal> _items = [];

  SeeAllPaginationProvider({required this.itemsPerPage});

  int get currentPage => _currentPage;
  int get totalPages => (_items.length / itemsPerPage).ceil();

  List<UserModal> get currentPageItems {
    int startIndex = (_currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    return _items.sublist(startIndex, endIndex > _items.length ? _items.length : endIndex);
  }

  void updateItems(List<UserModal> newItems) {
    _items = newItems; // Update the items list
    notifyListeners();
  }

  void goToPreviousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  void goToNextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }
}




class PaginationnControlsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SeeAllPaginationProvider>(
      builder: (context, paginationProvider, child) {
        final currentPage = paginationProvider.currentPage;
        final totalPages = paginationProvider.totalPages;

        return Container(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Previous Button
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
                  padding: EdgeInsets.only(bottom: 1.5),
                  icon: Icon(Icons.chevron_left),
                  onPressed: paginationProvider.goToPreviousPage,
                  color: Colors.black,
                  iconSize: 20,
                ),
              ),
              SizedBox(width: 3),

              // Page Number Buttons
              for (var i = 1; i <= totalPages; i++)
                if (i == 1 || i == currentPage || i == totalPages)
                  InkWell(
                    onTap: () => paginationProvider.goToPage(i),
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: EdgeInsets.only(left: 5, right: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: currentPage == i
                              ? ColorManager.bluebottom
                              : ColorManager.fmediumgrey.withOpacity(0.2),
                          width: currentPage == i ? 2.0 : 1.0,
                        ),
                        color: currentPage == i ? ColorManager.bluebottom : Colors.transparent,
                      ),
                      child: Text(
                        '$i',
                        style: TextStyle(
                          color: currentPage == i ? Colors.white : ColorManager.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                else if (i == currentPage - 1 || i == currentPage + 1)
                  Text(
                    '..',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),

              // Next Button
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
                  padding: EdgeInsets.only(bottom: 1.5),
                  icon: Icon(Icons.chevron_right),
                  onPressed: paginationProvider.goToNextPage,
                  color: Colors.black,
                  iconSize: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

