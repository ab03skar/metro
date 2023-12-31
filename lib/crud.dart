import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

class Crud {
  final db = FirebaseFirestore.instance;

  bool insertAdmin(
    String? uid,
    String? name,
    String? bd,
    String? email,
    String? phone,
    String? password,
    bool? status,
  ) {
    if (uid == null ||
        name == null ||
        bd == null ||
        email == null ||
        phone == null ||
        password == null ||
        status == null) {
      return false;
    } else {
      final data = <String, dynamic>{
        "FULLNAME": name,
        "BIRTHDATE": bd,
        "EMAIL": email,
        "PHONE": phone,
        "PASSWORD": password,
        "STATUS": status,
      };
      db.collection("Admin").doc(uid).set(data);
    }
    return true;
  }

  bool insertClient(
      String? uid,
      String? name,
      double? balance,
      String? bd,
      String? email,
      String? phone,
      String? walletID,
      String? password,
      bool? status,
      List? tickets,
      double? pass) {
    if (uid == null ||
        name == null ||
        balance == null ||
        bd == null ||
        email == null ||
        phone == null ||
        walletID == null ||
        password == null ||
        status == null ||
        tickets == null ||
        pass == null) {
      return false;
    } else {
      final data = <String, dynamic>{
        "FULLNAME": name,
        "BALANCE": balance,
        "BIRTHDATE": bd,
        "EMAIL": email,
        "PHONE": phone,
        "WALLETID": walletID,
        "PASSWORD": password,
        "STATUS": status,
        "TICKETS": tickets,
        "PASS": pass
      };
      db.collection("User").doc(uid).set(data);
    }
    return true;
  }

  void signOut() async {
    final SignOut = await FirebaseAuth.instance.signOut();
  }

  Future<String> getId() async {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    return uid;
  }

  Future<String> getAdminId() async {
    final admin = FirebaseAuth.instance.currentUser;
    String uid = admin!.uid;
    return uid;
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    CollectionReference users = FirebaseFirestore.instance.collection('User');
    DocumentReference userDocument = users.doc(uid);

    DocumentSnapshot snapshot = await userDocument.get();
    if (snapshot.exists) {
      String mapString = jsonEncode(snapshot.data());
      var mapObject = jsonDecode(mapString);

      Map<String, dynamic> data = mapObject;

      return data;
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>> getAdminData(String uid) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Admin');
    DocumentReference userDocument = users.doc(uid);

    DocumentSnapshot snapshot = await userDocument.get();
    if (snapshot.exists) {
      String mapString = jsonEncode(snapshot.data());
      var mapObject = jsonDecode(mapString);

      Map<String, dynamic> data = mapObject;

      return data;
    } else {
      return {};
    }
  }

  Future<bool> userExist(String? uid) async {
    if (uid == null) return false;
    if (getUserData(uid) == {}) return false;
    return true;
  }

  CollectionReference cR = FirebaseFirestore.instance.collection("Admin");
  Future<void> retrieveAdminEmail() async {
    QuerySnapshot qS = await cR.get();

    final allData = qS.docs.map((doc) => doc.data()).toList();
  }

  void InsertTicket(String tickID) async {
    String uid = await getId();
    Map<String, dynamic> data = await getUserData(uid);
    List tickets = data["TICKETS"];
    tickets.add(tickID);
    db.collection("User").doc(uid).update({"TICKETS": tickets});
  }

  String idGenerator() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toString();
  }

  void updateBalance(double amt) async {
    String id = await getId();
    Map<String, dynamic> data = await getUserData(id);
    double newBalance = data["BALANCE"] + amt;
    db.collection("User").doc(id).update({"BALANCE": newBalance});
  }

  void updatePass(double amt) async {
    String id = await getId();
    Map<String, dynamic> data = await getUserData(id);
    double newPass = data["PASS"] + amt;
    db.collection("User").doc(id).update({"PASS": newPass});
  }

  void updateName(String name) async {
    String id = await getId();
    Map<String, dynamic> data = await getUserData(id);
    db.collection("User").doc(id).update({"FULLNAME": name});
  }

  void updateAdminName(String name) async {
    String id = await getAdminId();
    Map<String, dynamic> data = await getAdminData(id);
    db.collection("Admin").doc(id).update({"FULLNAME": name});
  }

  void updatePassword(String password) async {
    String id = await getId();
    try {
      FirebaseAuth.instance.currentUser!.updatePassword(password);
    } on FirebaseAuthException {
      return;
    } catch (e) {
      return;
    }
    Map<String, dynamic> data = await getUserData(id);
    db.collection("User").doc(id).update({"PASSWORD": password});
  }

  void updateAdminPassword(String password) async {
    String id = await getAdminId();
    try {
      FirebaseAuth.instance.currentUser!.updatePassword(password);
    } on FirebaseAuthException {
      return;
    }
    Map<String, dynamic> data = await getAdminData(id);
    db.collection("Admin").doc(id).update({"PASSWORD": password});
  }

  void updateEmail(String email) async {
    String id = await getId();
    try {
      FirebaseAuth.instance.currentUser!.updateEmail(email);
    } on FirebaseAuthException {
      return;
    }
    Map<String, dynamic> data = await getUserData(id);
    db.collection("User").doc(id).update({"EMAIL": email});
  }

  void updateAdminEmail(String email) async {
    String id = await getAdminId();
    try {
      FirebaseAuth.instance.currentUser!.updateEmail(email);
    } on FirebaseAuthException {
      return;
    }
    Map<String, dynamic> data = await getAdminData(id);
    db.collection("Admin").doc(id).update({"EMAIL": email});
  }

  void updatePhone(String phone) async {
    String id = await getId();
    Map<String, dynamic> data = await getUserData(id);
    db.collection("User").doc(id).update({"PHONE": phone});
  }

  void updateAdminPhone(String phone) async {
    String id = await getAdminId();
    Map<String, dynamic> data = await getAdminData(id);
    db.collection("Admin").doc(id).update({"PHONE": phone});
  }

  Future<List> retrieveStations() async {
    QuerySnapshot qS = await db.collection("STATIONS").get();
    final data = qS.docs.map((e) => e.id).toList();
    return data;
  }

  Future<List> ListStations() async {
    QuerySnapshot qS =
        await db.collection("STATIONS").where("status", isEqualTo: true).get();
    final data = qS.docs.map((e) => e.id).toList();
    return data;
  }

  void setCounter(String name, String time) async {
    Map<String, dynamic> data = await getStationInfo(name);
    double count;
    try {
      count = data["time_count"][time];
      count = count + 1;
    } catch (e) {
      count = 1;
    }
    data['time_count'][time] = count;
    db.collection("STATIONS").doc(name).set(data);
  }

  void setCancelCounter(String name, String time) async {
    Map<String, dynamic> data = await getStationInfo(name);

    final timeCount = data["time_count"] as Map<String, dynamic>;
    if (timeCount.containsKey(time)) {
      double count = timeCount[time] - 1;
      if (count <= 0) {
        timeCount.remove(time);
      } else {
        timeCount[time] = count;
      }
      db.collection("STATIONS").doc(name).update({"time_count": timeCount});
    }
  }

  void deletePastTimes() async {
    var formatter = DateFormat('HH:mm');
    String currentTime = formatter.format(DateTime.now());

    CollectionReference stationsCollection =
        FirebaseFirestore.instance.collection('STATIONS');

    QuerySnapshot querySnapshot = await stationsCollection.get();

    for (var documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      if (data.containsKey('time_count')) {
        Map<String, dynamic> timeCount = data['time_count'];

        List<String> keysToRemove = timeCount.keys.where((time) {
          List<String> parts = time.split(" ");
          String firstElement = parts[1];
          return isPastTime(firstElement, currentTime);
        }).toList();

        for (var key in keysToRemove) {
          String keyDay = key;
          List keyDayList = keyDay.split(" ");
          keyDay = keyDayList[0];
          if (keyDay == "Today") timeCount.remove(key);
        }

        documentSnapshot.reference.update({'time_count': timeCount});
      }
    }
  }

  void ticketsPastTime() async {
    var formatter = DateFormat('HH:mm');
    String currentTime = formatter.format(DateTime.now());
    CollectionReference ticketsCollection =
        FirebaseFirestore.instance.collection('Tickets');
    QuerySnapshot querySnapshot = await ticketsCollection.get();

    for (var documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      if (data.containsKey('Date')) {
        String temp = data['Date'];
        List timeList = temp.split(" ");
        String ticketTime = timeList[1];
        if (isPastTime(ticketTime, currentTime)) {
          if (timeList[0] == "Today") {
            documentSnapshot.reference.update({'Status': false});
          }
        }
      }
    }
  }

  bool isPastTime(String time, String currentTime) {
    List<String> timeComponents = time.split(':');
    List<String> currentComponents = currentTime.split(':');
    int timeHour = int.parse(timeComponents[0]);
    int timeMinute = int.parse(timeComponents[1]);

    int currentHour = int.parse(currentComponents[0]);
    int currentMinute = int.parse(currentComponents[1]);

    if (currentHour < timeHour) {
      return false; // Current hour is less than time hour, not in the past
    } else if (currentHour == timeHour && currentMinute < timeMinute) {
      return false; // Current hour is the same, but current minute is less than time minute, not in the past
    } else if (currentHour == 23 && timeHour < 24 && currentMinute >= 30) {
      return true;
    } else {
      return true; // All other cases, considered in the past
    }
  }

  void updateTimeNames() async {
    DateTime now = DateTime.now();
    int currentHour = now.hour;

    bool isPastMidnight = currentHour >= 0 && currentHour < 1;

    if (isPastMidnight) {
      CollectionReference stationsCollection =
          FirebaseFirestore.instance.collection('STATIONS');

      QuerySnapshot snapshot = await stationsCollection.get();

      for (QueryDocumentSnapshot docSnapshot in snapshot.docs) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('time_count')) {
          Map<String, dynamic> timeCount = data['time_count'];

          List<String> keys = timeCount.keys.toList();
          for (String key in keys) {
            if (key.startsWith('Tomorrow')) {
              String time = key.split(' ')[1];
              var count = timeCount.remove(key);
              String newKey = 'Today $time';

              timeCount[newKey] = count;
            }
          }
          await docSnapshot.reference.update({'time_count': timeCount});
          await updateTicketsDateField();
        }
      }
    }
  }

  Future<void> updateTicketsDateField() async {
    CollectionReference ticketsCollection =
        FirebaseFirestore.instance.collection('Tickets');

    QuerySnapshot ticketsSnapshot = await ticketsCollection.get();

    for (QueryDocumentSnapshot ticketDocSnapshot in ticketsSnapshot.docs) {
      Map<String, dynamic> ticketData =
          ticketDocSnapshot.data() as Map<String, dynamic>;

      if (ticketData.containsKey('Date')) {
        String date = ticketData['Date'];

        if (date.startsWith('Tomorrow')) {
          List timeList = date.split(' ');
          String time = timeList[1];
          String newDate = 'Today $time';

          await ticketDocSnapshot.reference.update({'Date': newDate});
        }
      }
    }
  }

  void deleteTicketPermanantly(String id) async {
    //delete from tickets
    await db.collection("Tickets").doc(id).delete();
    //delete from user
    String uid = await getId();
    Map<String, dynamic> data = await getUserData(uid);
    List availableTickets = data["TICKETS"];
    availableTickets.remove(id);
    db.collection("User").doc(uid).update({"TICKETS": availableTickets});
  }

  Future<Map<String, dynamic>> getStationInfo(String key) async {
    DocumentSnapshot stationSnapshot =
        await db.collection("STATIONS").doc(key).get();
    if (stationSnapshot.exists) {
      String mapString = jsonEncode(stationSnapshot.data());
      var mapObject = jsonDecode(mapString);

      Map<String, dynamic> data = mapObject;
      return data;
    } else {
      return {"Test": "falied"};
    }
  }

  bool insertTicket(String? id, String? startStation, String? Date,
      bool? Status, String? uid) {
    if (id == null ||
        startStation == null ||
        Date == null ||
        Status == null ||
        uid == null) {
      return false;
    }
    final data = <String, dynamic>{
      "Date": Date,
      "Start_station": startStation,
      "Status": Status,
      "UID": uid
    };
    db.collection("Tickets").doc(id).set(data);
    return true;
  }

  bool insertFeedback(String? title, String? body, String? id) {
    if (title == null || body == null || id == null) {
      return false;
    }
    final String date = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now());
    final data = <String, dynamic>{
      "TITLE": title,
      "BODY": body,
      "ID": id,
      "DATE": date
    };
    db.collection("FEEDBACKS").doc().set(data);
    return true;
  }

  Future<List> retrieveFeedbackIds() async {
    QuerySnapshot qS = await db.collection("FEEDBACKS").get();
    final data = qS.docs.map((e) => e.id).toList();
    return data;
  }

  Future<Map<String, String>> getFeedbackNameId() async {
    List ids = await retrieveFeedbackIds();
    Map<String, String> data = {};
    for (var element in ids) {
      Map<String, dynamic> feedback = await getFeedbackInfo(element.toString());
      String name = feedback["TITLE"].toString();
      data[element.toString()] = name.toString();
    }
    return data;
  }

  Future<Map<String, dynamic>> getFeedbackInfo(String key) async {
    DocumentSnapshot stationSnapshot =
        await db.collection("FEEDBACKS").doc(key).get();
    if (stationSnapshot.exists) {
      String mapString = jsonEncode(stationSnapshot.data());
      var mapObject = jsonDecode(mapString);

      Map<String, dynamic> data = mapObject;
      return data;
    } else {
      return {};
    }
  }

  void removeFeedback(String id) async {
    await db.collection("FEEDBACKS").doc(id).delete();
  }

  String createTicketID(String stationName) {
    if (stationName.substring(0, 2).toLowerCase() == "al") {
      stationName = stationName.substring(2);
    }
    stationName = stationName.substring(0, 4);
    DateTime now = DateTime.now();
    String dateID = now.weekday.toString();
    String subID = idGenerator();
    subID = subID.substring(subID.length - 5, subID.length - 1);

    return "${stationName}_${dateID}_$subID";
  }

  Future<Map<String, dynamic>> getTicketInfo(String tickID) async {
    DocumentSnapshot ticketSnapshot =
        await db.collection("Tickets").doc(tickID).get();

    if (ticketSnapshot.exists) {
      String mapString = jsonEncode(ticketSnapshot.data());
      var mapObject = jsonDecode(mapString);

      Map<String, dynamic> data = mapObject;
      return data;
    } else {
      return {};
    }
  }

  void insertCanceledTicket(String tickID) async {
    String id = "c$tickID";
    String uid = await getId();

    final data = <String, dynamic>{
      "refunded": false,
      "uid": uid,
    };

    db.collection("CANCELED").doc(id).set(data);
  }

  void changeTicketStatus(String tickID) async {
    Map<String, dynamic> data = await getTicketInfo(tickID);
    db.collection("Tickets").doc(tickID).update({"Status": false});
  }

  Future<List<dynamic>> retrieveCanceledIds() async {
    QuerySnapshot qS = await db.collection("CANCELED").get();
    final data = qS.docs.map((e) => e.id).toList();
    return data;
  }

  Future<Map<String, dynamic>> getCancelInfo(String id) async {
    DocumentSnapshot cancelSnapshot =
        await db.collection("CANCELED").doc(id).get();

    if (cancelSnapshot.exists) {
      String mapString = jsonEncode(cancelSnapshot.data());
      var mapObject = jsonDecode(mapString);

      Map<String, dynamic> data = mapObject;
      return data;
    } else {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getCancelMap() async {
    List ids = await retrieveCanceledIds();
    List<Map<String, dynamic>> data = [];
    for (var element in ids) {
      Map<String, dynamic> info = {};
      Map<String, dynamic> temp = await getCancelInfo(element);
      if (temp["refunded"]) continue;
      String tickID = element.toString().substring(1);
      String uid = temp["uid"].toString();
      temp = await getUserData(uid);
      String name = temp["FULLNAME"].toString();
      temp = await getTicketInfo(tickID);
      String station = temp["Start_station"];

      info["id"] = tickID;
      info["uid"] = uid;
      info["name"] = name;
      info["station"] = station;
      data.add(info);
    }

    return data;
  }

  void Refund(String id, String uid) async {
    Map<String, dynamic> temp = await getUserData(uid);
    double pass = temp["PASS"] + 1;
    db.collection("User").doc(uid).update({"PASS": pass});
    db.collection("CANCELED").doc("c$id").update({"refunded": true});
  }

  Future<bool> isCanceled(String id) async {
    DocumentSnapshot snapshot =
        await db.collection("CANCELED").doc("c${id}").get();
    if (snapshot.exists) {
      Map<String, dynamic> data = await getCancelInfo("c${id}");
      if (!data["refunded"]) return true;
    }
    return false;
  }

  Future<bool> switchFreezeAccount(String? id) async {
    if (id != null && id != "") {
      try {
        Map<String, dynamic> data = await getUserData(id);
        db.collection("User").doc(id).update({"STATUS": !data["STATUS"]});
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}

class userObject {
  String uid;
  String name;
  double balance;
  String email;
  String phone;
  String walletID;
  String password;
  bool status;
  List tickets;
  double pass;

  userObject(
      {required this.uid,
      required this.name,
      required this.balance,
      required this.email,
      required this.phone,
      required this.walletID,
      required this.password,
      required this.status,
      required this.tickets,
      required this.pass});

  factory userObject.fromJson(Map<String, dynamic> json) {
    return userObject(
      uid: json["USER"] as String,
      name: json["FULLNAME"] as String,
      balance: json["BALANCE"] as double,
      email: json["EMAIL"] as String,
      phone: json["PHONE"] as String,
      walletID: json["WALLETID"] as String,
      status: json["STATUS"] as bool,
      password: json["PASSWORD"] as String,
      tickets: json["TICKET"] as List,
      pass: json["PASS"] as double,
    );
  }
}
