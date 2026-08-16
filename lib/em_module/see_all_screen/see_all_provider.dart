// TODO Implement this library.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/const_string.dart';
import 'package:prohealth/app/services/api/api.dart';
import 'package:prohealth/app/services/api/managers/establishment_manager/user.dart';
import 'package:prohealth/app/services/api/repository/establishment_manager/establishment_repository.dart';
import 'package:prohealth/app/services/token/token_manager.dart';
import 'package:prohealth/data/api_data/api_data.dart';


import '../../../../data/api_data/establishment_data/user/user_modal.dart';
import '../../../widgets/error_popups/delete_success_popup.dart';
//
// /// stream
// class SeeAllProvider with ChangeNotifier {
//   final StreamController<List<UserModal>> _companyUsersList = StreamController<List<UserModal>>();
//
//   Stream<List<UserModal>> get userStream => _companyUsersList.stream;
//
//   bool _isLoading = false;
//   final StreamController<List<UserModal>> _companyUsersStreamController = StreamController<List<UserModal>>.broadcast();
//
//   bool get isLoading => _isLoading;
//   Stream<List<UserModal>> get companyUsersListStream => _companyUsersStreamController.stream;
//
//   List<UserModal> _allUsers = [];
//   int _currentPage = 1;
//   int _itemsPerPage = 10;
//
//   String? userLogin;
//
//   /// Fetch user data
//   Future<void> fetchUser(BuildContext context) async {
//     try {
//       List<UserModal> fetchedUsers = await getUser(context);
//       userLogin = await TokenManager.getEmail();
//       _allUsers = fetchedUsers;
//       _companyUsersList.add(_allUsers);
//       // notifyListeners();
//     } catch (e) {
//       print("Error fetching users: $e");
//     }
//   }
//
//   ///update the user list
//   // void updateUserInList(UserModal updatedUser) {
//   //   int index = _allUsers.indexWhere((user) => user.userId == updatedUser.userId);
//   //   if (index != -1) {
//   //     _allUsers[index] = updatedUser;
//   //     _companyUsersList.add(_allUsers);
//   //     notifyListeners();
//   //   }
//   // }
//   ///
//   void updateUserInList(UserModal updatedUser) {
//     int index = _allUsers.indexWhere((user) => user.userId == updatedUser.userId);
//     if (index != -1) {
//       _allUsers[index] = updatedUser;
//
//       // Add a debounce mechanism to avoid frequent updates
//       Future.delayed(Duration(milliseconds: 100), () {
//         _companyUsersList.add([..._allUsers]);
//       });
//     }
//   }
//
//   /// Added the deleteUser method
//   Future<void> deleteUser(BuildContext context, String userId) async {
//     try {
//       ApiData response = await deleteUserApi(context, int.parse(userId));
//       if (response.success) {
//         _allUsers.removeWhere((user) => user.userId.toString() == userId);
//         _companyUsersList.add(_allUsers);
//         notifyListeners();
//       } else {
//         print("Error deleting user: ${response.message}");
//       }
//     } catch (e) {
//       print("Error deleting user: $e");
//     }
//   }
//
//
//   Future<ApiData> deleteUserApi(BuildContext context, int userId) async {
//     try {
//       var response = await Api(context).delete(
//         path: EstablishmentManagerRepository.userDelete(userId: userId),
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return ApiData(
//           statusCode: response.statusCode!,
//           success: true,
//           message: response.statusMessage!,
//         );
//       } else {
//         return ApiData(
//           statusCode: response.statusCode!,
//           success: false,
//           message: response.data['message'],
//         );
//       }
//     } catch (e) {
//       return ApiData(
//         statusCode: 404,
//         success: false,
//         message: AppString.somethingWentWrong,
//       );
//     }
//   }
//
//   /// Paginated list of users declared
//   List<UserModal> get paginatedUsers {
//     int startIndex = (_currentPage - 1) * _itemsPerPage;
//     int endIndex = startIndex + _itemsPerPage;
//     return _allUsers.sublist(
//       startIndex,
//       endIndex > _allUsers.length ? _allUsers.length : endIndex,
//     );
//   }
//
//   int get totalPages => (_allUsers.length / _itemsPerPage).ceil();
//   int get currentPage => _currentPage;
//
//   void goToPage(int pageNumber) {
//     if (pageNumber >= 1 && pageNumber <= totalPages) {
//       _currentPage = pageNumber;
//       notifyListeners();
//     }
//   }
//
//   void nextPage() {
//     if (_currentPage < totalPages) {
//       _currentPage++;
//       notifyListeners();
//     }
//   }
//
//   void previousPage() {
//     if (_currentPage > 1) {
//       _currentPage--;
//       notifyListeners();
//     }
//   }
//
//   void dispose() {
//     _companyUsersList.close();
//     _companyUsersStreamController.close();
//     super.dispose();
//   }
// }


/// future
// class SeeAllProvider with ChangeNotifier {
//   final StreamController<List<UserModal>> _companyUsersList = StreamController<List<UserModal>>();
//
//   Stream<List<UserModal>> get userStream => _companyUsersList.stream;
//
//   bool _isLoading = false;
//   final StreamController<List<UserModal>> _companyUsersStreamController = StreamController<List<UserModal>>.broadcast();
//
//   bool get isLoading => _isLoading;
//   Stream<List<UserModal>> get companyUsersListStream => _companyUsersStreamController.stream;
//
//   List<UserModal> _allUsers = [];
//   int _currentPage = 1;
//   int _itemsPerPage = 10;
//
//   /// Fetch user data
//   Future<List<UserModal>> fetchUser(BuildContext context) async {
//     try {
//       List<UserModal> fetchedUsers = await getUser(context); // Assuming getUser returns List<UserModal>
//       print("Fetched Users: $fetchedUsers"); // Debugging line to check the fetched data
//       _allUsers = fetchedUsers;
//       _companyUsersList.add(_allUsers);
//       notifyListeners();
//       return _allUsers; // Return the list of users
//     } catch (e) {
//       print("Error fetching users: $e");
//       return []; // Return an empty list in case of an error
//     }
//   }
//
//
//   /// Update the user list
//   void updateUserInList(UserModal updatedUser) {
//     int index = _allUsers.indexWhere((user) => user.userId == updatedUser.userId);
//     if (index != -1) {
//       _allUsers[index] = updatedUser;
//       _companyUsersList.add(_allUsers);
//       notifyListeners();
//     }
//   }
//
//   /// Added the deleteUser method
//   Future<void> deleteUser(BuildContext context, String userId) async {
//     try {
//       ApiData response = await deleteUserApi(context, int.parse(userId));
//       if (response.success) {
//         _allUsers.removeWhere((user) => user.userId.toString() == userId);
//         _companyUsersList.add(_allUsers);
//         notifyListeners();
//       } else {
//         print("Error deleting user: ${response.message}");
//       }
//     } catch (e) {
//       print("Error deleting user: $e");
//     }
//   }
//
//   Future<ApiData> deleteUserApi(BuildContext context, int userId) async {
//     try {
//       var response = await Api(context).delete(
//         path: EstablishmentManagerRepository.userDelete(userId: userId),
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return ApiData(
//           statusCode: response.statusCode!,
//           success: true,
//           message: response.statusMessage!,
//         );
//       } else {
//         return ApiData(
//           statusCode: response.statusCode!,
//           success: false,
//           message: response.data['message'],
//         );
//       }
//     } catch (e) {
//       return ApiData(
//         statusCode: 404,
//         success: false,
//         message: AppString.somethingWentWrong,
//       );
//     }
//   }
//
//   /// Paginated list of users declared
//   List<UserModal> get paginatedUsers {
//     int startIndex = (_currentPage - 1) * _itemsPerPage;
//     int endIndex = startIndex + _itemsPerPage;
//     return _allUsers.sublist(
//       startIndex,
//       endIndex > _allUsers.length ? _allUsers.length : endIndex,
//     );
//   }
//
//   int get totalPages => (_allUsers.length / _itemsPerPage).ceil();
//   int get currentPage => _currentPage;
//
//   void goToPage(int pageNumber) {
//     if (pageNumber >= 1 && pageNumber <= totalPages) {
//       _currentPage = pageNumber;
//       notifyListeners();
//     }
//   }
//
//   void nextPage() {
//     if (_currentPage < totalPages) {
//       _currentPage++;
//       notifyListeners();
//     }
//   }
//
//   void previousPage() {
//     if (_currentPage > 1) {
//       _currentPage--;
//       notifyListeners();
//     }
//   }
//
//   void dispose() {
//     _companyUsersList.close();
//     _companyUsersStreamController.close();
//     super.dispose();
//   }
// }
///
///
class SeeAllProvider with ChangeNotifier {
  final StreamController<List<UserModal>> _companyUsersList = StreamController<List<UserModal>>();

  Stream<List<UserModal>> get userStream => _companyUsersList.stream;

  bool _isLoading = false;
  final StreamController<List<UserModal>> _companyUsersStreamController = StreamController<List<UserModal>>.broadcast();

  bool get isLoading => _isLoading;
  Stream<List<UserModal>> get companyUsersListStream => _companyUsersStreamController.stream;

  List<UserModal> _allUsers = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  String? userLogin;

  /// Fetch user data
  Future<void> fetchUser(BuildContext context) async {
    try {
      List<UserModal> fetchedUsers = await getUser(context);
      userLogin = await TokenManager.getEmail();
      _allUsers = fetchedUsers;
      _companyUsersList.add(_allUsers);
      // notifyListeners();
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  /// Update the user list
  void updateUserInList(UserModal updatedUser) {
    int index = _allUsers.indexWhere((user) => user.userId == updatedUser.userId);
    if (index != -1) {
      _allUsers[index] = updatedUser;
      _companyUsersList.add([..._allUsers]);
    }
  }

  /// Added the deleteUser method
  Future<void> deleteUser(BuildContext context, String userId) async {
    try {
      ApiData response = await deleteUserApi(context, int.parse(userId));
      if (response.success) {
        _allUsers.removeWhere((user) => user.userId.toString() == userId);
        _companyUsersList.add(_allUsers);
        notifyListeners();
      } else {
        print("Error deleting user: ${response.message}");
      }
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  Future<ApiData> deleteUserApi(BuildContext context, int userId) async {
    try {
      var response = await Api(context).delete(
        path: EstablishmentManagerRepository.userDelete(userId: userId),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
        );
      } else {
        return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message'],
        );
      }
    } catch (e) {
      return ApiData(
        statusCode: 404,
        success: false,
        message: AppString.somethingWentWrong,
      );
    }
  }

  /// Paginated list of users declared
  List<UserModal> get paginatedUsers {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    return _allUsers.sublist(
      startIndex,
      endIndex > _allUsers.length ? _allUsers.length : endIndex,
    );
  }

  int get totalPages => (_allUsers.length / _itemsPerPage).ceil();
  int get currentPage => _currentPage;

  void goToPage(int pageNumber) {
    if (pageNumber >= 1 && pageNumber <= totalPages) {
      _currentPage = pageNumber;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  void dispose() {
    _companyUsersList.close();
    _companyUsersStreamController.close();
    super.dispose();
  }
}
