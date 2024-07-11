import 'package:agro_bharat/services/notificationservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference users = FirebaseFirestore.instance.collection("users");
  final CollectionReference expenses = FirebaseFirestore.instance.collection("expenses");

  // Check if a phone number exists
  Future<bool> doesPhoneNumberExist(String phoneNumber) async {
    final querySnapshot = await users.where('phoneNumber', isEqualTo: phoneNumber).get();
    return querySnapshot.docs.isNotEmpty;
  }

  // Add a new user
  Future<void> addUser(String phoneNumber, String userId, String name, String dob, String address, String state, String pincode) async {
    try {
      String? fcmToken = await FCMService.getFcmToken();

      await users.doc(userId).set({
        'userId': userId,
        'phoneNumber': phoneNumber,
        'name': name,
        'dob': dob,
        'address': address,
        'state': state,
        'pincode': pincode,
        'fcmToken': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle or log the error
      print("Error adding user: $e");
      rethrow;
    }
  }


  Future<void> updateUserFcmToken(String userId) async {
    try {
      String? fcmToken = await FCMService.getFcmToken();

      if (fcmToken != null) {
        await users.doc(userId).update({
          'fcmToken': fcmToken,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      } else {
        print("Failed to retrieve FCM token");
      }
    } catch (e) {
      print("Error updating FCM token: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      DocumentSnapshot docSnapshot = await users.doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        // print("No user found with ID: $userId");
        return null;
      }
    } catch (e) {
      // print("Error retrieving user: $e");
      return null;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      String? token = await FCMService.getFcmToken();
      if (token != null) {
        data['fcmToken'] = token;  // Add the token to the data if needed
      }
      await users.doc(userId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot?> getUserDataByPhoneNumber(String phoneNumber) async {
    final querySnapshot = await users.where('phoneNumber', isEqualTo: phoneNumber).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    } else {
      return null;
    }
  }

  // Future<void> addExpense(double amount, String category, String description) async {
  //   await expenses.add({
  //     'amount': amount,
  //     'category': category,
  //     'description': description,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  // }

  Future<void> addExpense(String userId, double amount, String category, String description) async {
    await users.doc(userId).collection('expenses').add({
      'amount': amount,
      'category': category,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getExpenses(DateTime startDate, DateTime endDate) async {
    QuerySnapshot querySnapshot = await expenses
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    List<Map<String, dynamic>> expenseList = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    return expenseList;
  }

  Stream<QuerySnapshot> getExpenseStream(String userId, DateTime? startDate, DateTime? endDate) {
    return users.doc(userId).collection('expenses')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate!))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate!))
        .orderBy('timestamp', descending: true) // Order by timestamp in descending order
        .snapshots();
  }

  Future<double> getTotalExpensesForDateRange(String userId, DateTime startDate, DateTime endDate) async {
    double totalExpenses = 0;

    // Create a query to fetch expenses within the specified date range
    QuerySnapshot expensesSnapshot = await users
        .doc(userId)
        .collection('expenses')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    // Calculate the total expenses
    for (QueryDocumentSnapshot expenseDoc in expensesSnapshot.docs) {
      double amount = expenseDoc.get('amount');
      totalExpenses += amount;
    }

    return totalExpenses;
  }
// Delete an expense by ID for a specific user
  Future<void> deleteExpense(String userId, String expenseId) async {
    await users.doc(userId).collection('expenses').doc(expenseId).delete();
  }

// Update an expense by ID for a specific user
  Future<void> updateExpense(String userId, String expenseId, double amount, String category, String description) async {
    await users.doc(userId).collection('expenses').doc(expenseId).update({
      'amount': amount,
      'category': category,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(), // Update the updatedAt field to the current time
    });
  }
}
