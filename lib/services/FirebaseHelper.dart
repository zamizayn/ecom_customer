import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/main.dart';
import 'package:emartconsumer/model/AddressModel.dart';
import 'package:emartconsumer/model/AttributesModel.dart';
import 'package:emartconsumer/model/BannerModel.dart';
import 'package:emartconsumer/model/BlockUserModel.dart';
import 'package:emartconsumer/model/BookTableModel.dart';
import 'package:emartconsumer/model/BrandsModel.dart';
import 'package:emartconsumer/model/CabOrderModel.dart';
import 'package:emartconsumer/model/ChatVideoContainer.dart';
import 'package:emartconsumer/model/CodModel.dart';
import 'package:emartconsumer/model/CurrencyModel.dart';
import 'package:emartconsumer/model/DeliveryChargeModel.dart';
import 'package:emartconsumer/model/FavouriteItemModel.dart';
import 'package:emartconsumer/model/FavouriteModel.dart';
import 'package:emartconsumer/model/MercadoPagoSettingsModel.dart';
import 'package:emartconsumer/model/OrderModel.dart';
import 'package:emartconsumer/model/ParcelCategory.dart';
import 'package:emartconsumer/model/PayFastSettingData.dart';
import 'package:emartconsumer/model/ProductModel.dart';
import 'package:emartconsumer/model/Ratingmodel.dart';
import 'package:emartconsumer/model/RentalVehicleType.dart';
import 'package:emartconsumer/model/ReviewAttributeModel.dart';
import 'package:emartconsumer/model/SectionModel.dart';
import 'package:emartconsumer/model/TaxModel.dart';
import 'package:emartconsumer/model/User.dart';
import 'package:emartconsumer/model/VehicleType.dart';
import 'package:emartconsumer/model/VendorCategoryModel.dart';
import 'package:emartconsumer/model/VendorModel.dart';
import 'package:emartconsumer/model/conversation_model.dart';
import 'package:emartconsumer/model/inbox_model.dart';
import 'package:emartconsumer/model/offer_model.dart';
import 'package:emartconsumer/model/paypalSettingData.dart';
import 'package:emartconsumer/model/paytmSettingData.dart';
import 'package:emartconsumer/model/popular_destination.dart';
import 'package:emartconsumer/model/razorpayKeyModel.dart';
import 'package:emartconsumer/model/referral_model.dart';
import 'package:emartconsumer/model/story_model.dart';
import 'package:emartconsumer/model/stripeKey.dart';
import 'package:emartconsumer/model/stripeSettingData.dart';
import 'package:emartconsumer/model/topupTranHistory.dart';
import 'package:emartconsumer/parcel_delivery/parcel_model/parcel_order_model.dart';
import 'package:emartconsumer/parcel_delivery/parcel_model/parcel_weight_model.dart';
import 'package:emartconsumer/rental_service/model/rental_order_model.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:emartconsumer/ui/reauthScreen/reauth_user_screen.dart';
import 'package:emartconsumer/userPrefrence.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../constants.dart';
import '../model/FlutterWaveSettingDataModel.dart';
import '../model/PayStackSettingsModel.dart';

class FireStoreUtils {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static Reference storage = FirebaseStorage.instance.ref();

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await firestore.collection(REFERRAL).where("referralCode", isEqualTo: referralCode).get().then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }



  static Future<ReferralModel?> getReferralUserByCode(String referralCode) async {
    ReferralModel? referralModel;
    try {
      await firestore.collection(REFERRAL).where("referralCode", isEqualTo: referralCode).get().then((value) {
        referralModel = ReferralModel.fromJson(value.docs.first.data());
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<ReferralModel?> getReferralUserBy() async {
    ReferralModel? referralModel;
    try {
      print(MyAppState.currentUser!.userID);
      await firestore.collection(REFERRAL).doc(MyAppState.currentUser!.userID).get().then((value) {
        referralModel = ReferralModel.fromJson(value.data()!);
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }



  List<BlockUserModel> blockedList = [];

  Future<List<StoryModel>> getStory() async {
    List<StoryModel> story = [];
    QuerySnapshot<Map<String, dynamic>> storyQuery = await firestore.collection(STORY).where('sectionID',isEqualTo: SELECTED_CATEGORY).get();
    await Future.forEach(storyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        story.add(StoryModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return story;
  }

  static Future<List<AttributesModel>> getAttributes() async {
    List<AttributesModel> attributesList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(VENDOR_ATTRIBUTES).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        attributesList.add(AttributesModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return attributesList;
  }

  static Future<List<BrandsModel>> getBrands() async {
    List<BrandsModel> brandList = [];
    QuerySnapshot<Map<String, dynamic>> brandQuery = await firestore.collection(BRANDS).where('is_publish', isEqualTo: true).get();
    await Future.forEach(brandQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print("------>");
        print(document.data());
        brandList.add(BrandsModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return brandList;
  }

  static Future addRestaurantInbox(InboxModel inboxModel) async {
    return await firestore.collection("chat_store").doc(inboxModel.orderId).set(inboxModel.toJson()).then((document) {
      return inboxModel;
    });
  }

  static Future addRestaurantChat(ConversationModel conversationModel) async {
    return await firestore.collection("chat_store").doc(conversationModel.orderId).collection("thread").doc(conversationModel.id).set(conversationModel.toJson()).then((document) {
      return conversationModel;
    });
  }

  static Future addDriverInbox(InboxModel inboxModel) async {
    return await firestore.collection("chat_driver").doc(inboxModel.orderId).set(inboxModel.toJson()).then((document) {
      return inboxModel;
    });
  }

  static Future addDriverChat(ConversationModel conversationModel) async {
    return await firestore.collection("chat_driver").doc(conversationModel.orderId).collection("thread").doc(conversationModel.id).set(conversationModel.toJson()).then((document) {
      return conversationModel;
    });
  }

  Future<List<RatingModel>> getReviewList(String productId) async {
    List<RatingModel> reviewList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(Order_Rating).where('productId', isEqualTo: productId).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        reviewList.add(RatingModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return reviewList;
  }

  static Future<List<ProductModel>> getProductListByCategoryId(String categoryId) async {
    List<ProductModel> productList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(PRODUCTS).where('categoryID', isEqualTo: categoryId).where('publish', isEqualTo: true).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        productList.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return productList;
  }

  static Future<List<ProductModel>> getStoreProduct(String storeId) async {
    List<ProductModel> productList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: storeId).where('publish', isEqualTo: true).limit(6).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        productList.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return productList;
  }

  static Future<List<ProductModel>> getProductListByBrandId(String brandId) async {
    List<ProductModel> productList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(PRODUCTS).where('brandID', isEqualTo: brandId).where('publish', isEqualTo: true).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        productList.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return productList;
  }

  static Future<List<ReviewAttributeModel>> getAllReviewAttributes() async {
    List<ReviewAttributeModel> reviewAttributesList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(REVIEW_ATTRIBUTES).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        reviewAttributesList.add(ReviewAttributeModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return reviewAttributesList;
  }

  late StreamController<OrderModel> ordersByIdStreamController;
  late StreamSubscription ordersByIdStreamSub;

  Stream<OrderModel?> getOrderByID(String inProgressOrderID) async* {
    ordersByIdStreamController = StreamController();
    ordersByIdStreamSub = firestore.collection(ORDERS).doc(inProgressOrderID).snapshots().listen((onData) async {
      if (onData.data() != null) {
        OrderModel? orderModel = OrderModel.fromJson(onData.data()!);
        ordersByIdStreamController.sink.add(orderModel);
      }
    });
    yield* ordersByIdStreamController.stream;
  }

  static Future<VendorModel?> getVendor(String vid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await firestore.collection(VENDORS).doc(vid).get();
    if (userDocument.data() != null && userDocument.exists) {
      print("dataaaaaa aaa ");
      return VendorModel.fromJson(userDocument.data()!);
    } else {
      print("nulllll");
      return null;
    }
  }

  final geo = GeoFlutterFire();
  late StreamController<List<User>> nearestDriverStreamController;

  Stream<List<User>> getRentalCompanyDriver(RentalOrderModel? orderModel, String vehicleType, Timestamp date, Timestamp end) async* {
    nearestDriverStreamController = StreamController<List<User>>.broadcast();

    List<User> driverList = [];

    var collectionReference = firestore.collection(USERS).where('vehicleType', isEqualTo: vehicleType).where('serviceType', isEqualTo: "rental-service");

    String field = 'g';
    GeoFirePoint center = geo.point(latitude: orderModel!.pickupLatLong!.latitude, longitude: orderModel.pickupLatLong!.longitude);

    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: 100, field: field, strictMode: true);
    stream.listen((List<DocumentSnapshot> documentList) {
      if (documentList.isNotEmpty) {
        for (var element in documentList) {
          User user = User.fromJson(element.data() as Map<String, dynamic>);
          driverList.add(user);
          nearestDriverStreamController.add(driverList);
        }
      } else {
        nearestDriverStreamController.add(driverList);
        nearestDriverStreamController.close();
      }
    });

    yield* nearestDriverStreamController.stream;
  }

  Future<CabOrderModel> cabOrderPlace(CabOrderModel orderModel, bool isPaymentComplete) async {
    DocumentReference documentReference;
    if (orderModel.id.isEmpty) {
      documentReference = firestore.collection(RIDESORDER).doc();
      orderModel.id = documentReference.id;
    } else {
      documentReference = firestore.collection(RIDESORDER).doc(orderModel.id);
    }
    await documentReference.set(orderModel.toJson());
    if (isPaymentComplete) {
      MyAppState.currentUser!.inProgressOrderID = null;
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
    } else {
      MyAppState.currentUser!.inProgressOrderID = orderModel.id;
      await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
    }
    return orderModel;
  }

  Future<ParcelOrderModel> parcelOrderPlace(ParcelOrderModel orderModel, double totalAmount) async {
    DocumentReference documentReference;
    if (orderModel.id.isEmpty) {
      documentReference = firestore.collection(PARCELORDER).doc();
      orderModel.id = documentReference.id;
    } else {
      documentReference = firestore.collection(PARCELORDER).doc(orderModel.id);
    }
    if (orderModel.paymentCollectByReceiver == false && orderModel.paymentMethod == "wallet") {
      FireStoreUtils.createPaymentId().then((value) {
        final paymentID = value;
        FireStoreUtils.topUpWalletAmount(serviceType: "parcel-service", paymentMethod: "Wallet", isTopup: false, orderId: orderModel.id, amount: totalAmount, id: paymentID).then((value) {
          FireStoreUtils.updateWalletAmount(amount: -totalAmount);
        });
      });
    }
    await documentReference.set(orderModel.toJson());

    return orderModel;
  }

  Future<RentalOrderModel> rentalOrderPlace(RentalOrderModel orderModel, double totalAmount) async {
    DocumentReference documentReference;
    if (orderModel.id.isEmpty) {
      documentReference = firestore.collection(RENTALORDER).doc();
      orderModel.id = documentReference.id;
    } else {
      documentReference = firestore.collection(RENTALORDER).doc(orderModel.id);
    }
    if (orderModel.paymentMethod == "wallet") {
      FireStoreUtils.createPaymentId().then((value) {
        final paymentID = value;
        FireStoreUtils.topUpWalletAmount(serviceType: "rental-service", paymentMethod: "Wallet", isTopup: false, orderId: orderModel.id, amount: totalAmount, id: paymentID).then((value) {
          FireStoreUtils.updateWalletAmount(amount: -totalAmount);
        });
      });
    }

    await documentReference.set(orderModel.toJson());

    return orderModel;
  }

  Future setSos(String orderId, UserLocation userLocation) async {
    DocumentReference documentReference = firestore.collection(SOS).doc();
    Map<String, dynamic> sosMap = {'id': documentReference.id, 'orderId': orderId, 'status': "Initiated", 'latLong': userLocation.toJson()};

    print("------->------->" + sosMap.toString());
    await documentReference.set(sosMap);
  }

  Future<bool> getSOS(String orderId) async {
    bool isAdded = false;
    QuerySnapshot documentReference = await firestore.collection(SOS).where('orderId', isEqualTo: orderId).get();
    documentReference.docs.forEach((element) {
      if (element['orderId'] == orderId) {
        isAdded = true;
      }
    });

    return isAdded;
  }

  Future setRideComplain(
      {required String orderId,
      required String title,
      required String description,
      required String driverID,
      required String driverName,
      required String customerID,
      required String customerName}) async {
    DocumentReference documentReference = firestore.collection(complaints).doc();
    Map<String, dynamic> sosMap = {
      'id': documentReference.id,
      'createdAt': Timestamp.now(),
      'description': description,
      'driverId': driverID,
      'driverName': driverName,
      'orderId': orderId,
      'customerName': customerName,
      'customerId': customerID,
      'status': "Initiated",
      'title': title,
    };

    await documentReference.set(sosMap);
  }

  Future<bool> getRideComplain(String orderId) async {
    bool isAdded = false;
    QuerySnapshot documentReference = await firestore.collection(complaints).where('orderId', isEqualTo: orderId).get();
    documentReference.docs.forEach((element) {
      if (element['orderId'] == orderId) {
        isAdded = true;
      }
    });

    return isAdded;
  }

  Future<QueryDocumentSnapshot?> getRideComplainData(String orderId) async {
    QueryDocumentSnapshot? isAdded;
    QuerySnapshot documentReference = await firestore.collection(complaints).where('orderId', isEqualTo: orderId).get();
    documentReference.docs.forEach((element) {
      if (element['orderId'] == orderId) {
        isAdded = element;
      }
    });
    return isAdded;
  }

  Future<List<CabOrderModel>> getCabDriverOrders(String userID) async {
    List<CabOrderModel> orders = [];

    QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore.collection(RIDESORDER).where('authorID', isEqualTo: userID).orderBy('createdAt', descending: true).get();
    await Future.forEach(ordersQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        orders.add(CabOrderModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return orders;
  }

  Future<List<ParcelCategory>?> getParcelServiceCategory() async {
    List<ParcelCategory> parcelCategory = [];

    QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore.collection(PARCELCATEGORY).where('publish', isEqualTo: true).orderBy('set_order', descending: false).get();
    await Future.forEach(ordersQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print("---->${document.data()}");
        parcelCategory.add(ParcelCategory.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return parcelCategory;
  }

  Future<List<ParcelWeightModel>?> getParcelWeight() async {
    List<ParcelWeightModel> parcelCategory = [];

    QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore.collection(PARCELWEIGHT).get();
    await Future.forEach(ordersQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print("---->${document.data()}");
        parcelCategory.add(ParcelWeightModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return parcelCategory;
  }

  Future<List<ParcelOrderModel>> getParcelOrdes(String userID) async {
    List<ParcelOrderModel> orders = [];

    QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore.collection(PARCELORDER).where('authorID', isEqualTo: userID).orderBy('createdAt', descending: true).get();
    await Future.forEach(ordersQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        orders.add(ParcelOrderModel.fromJson(document.data()));
      } catch (e, stacksTrace) {
        print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
            '$stacksTrace');
      }
    });
    return orders;
  }

  Future<List<RentalOrderModel>> getRentalBook(String userID, String orderStatus) async {
    List<RentalOrderModel> orders = [];

    if (orderStatus.isEmpty) {
      QuerySnapshot<Map<String, dynamic>> ordersQuery = await firestore.collection(RENTALORDER).where('authorID', isEqualTo: userID).orderBy('createdAt', descending: true).get();
      await Future.forEach(ordersQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
        try {
          orders.add(RentalOrderModel.fromJson(document.data()));
        } catch (e, stacksTrace) {
          print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
              '$stacksTrace');
        }
      });
    } else {
      QuerySnapshot<Map<String, dynamic>> ordersQuery =
          await firestore.collection(RENTALORDER).where('authorID', isEqualTo: userID).where("status", isEqualTo: orderStatus).orderBy('createdAt', descending: true).get();
      await Future.forEach(ordersQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
        try {
          orders.add(RentalOrderModel.fromJson(document.data()));
        } catch (e, stacksTrace) {
          print('FireStoreUtils.getDriverOrders Parse error ${document.id} $e '
              '$stacksTrace');
        }
      });
    }

    return orders;
  }

  static Future updateRentalOrder(RentalOrderModel orderModel) async {
    await firestore.collection(RENTALORDER).doc(orderModel.id).set(orderModel.toJson(), SetOptions(merge: true));
  }

  late StreamController<CabOrderModel> cabOrdersStreamController;
  late StreamSubscription cabOrdersStreamSub;

  Stream<CabOrderModel> getCabOrder(String orderId) async* {
    cabOrdersStreamController = StreamController();
    cabOrdersStreamSub = firestore.collection(RIDESORDER).doc(orderId).snapshots().listen((onData) async {
      if (onData.data() != null) {
        CabOrderModel? orderModel = CabOrderModel.fromJson(onData.data()!);
        if (orderModel.rideType == "ride") {
          cabOrdersStreamController.sink.add(orderModel);
        }
      }
    });
    yield* cabOrdersStreamController.stream;
  }

  late StreamController<CabOrderModel> intercityOrdersStreamController;
  late StreamSubscription intercityOrdersStreamSub;

  Stream<CabOrderModel> getIntercityOrder(String orderId) async* {
    intercityOrdersStreamController = StreamController();
    intercityOrdersStreamSub = firestore.collection(RIDESORDER).doc(orderId).snapshots().listen((onData) async {
      if (onData.data() != null) {
        CabOrderModel? orderModel = CabOrderModel.fromJson(onData.data()!);
        if (orderModel.rideType == "intercity") {
          intercityOrdersStreamController.sink.add(orderModel);
        }
      }
    });
    yield* intercityOrdersStreamController.stream;
  }

  static Future updateCabOrder(CabOrderModel orderModel) async {
    print("------->${orderModel.adminCommission}");
    await firestore.collection(RIDESORDER).doc(orderModel.id).set(orderModel.toJson(), SetOptions(merge: true));
  }

  late StreamController<ParcelOrderModel> parcelOrdersStreamController;
  late StreamSubscription parcelOrdersStreamSub;

  Stream<ParcelOrderModel> getParcelOrder(String orderId) async* {
    parcelOrdersStreamController = StreamController();
    parcelOrdersStreamSub = firestore.collection(PARCELORDER).doc(orderId).snapshots().listen((onData) async {
      if (onData.data() != null) {
        ParcelOrderModel? orderModel = ParcelOrderModel.fromJson(onData.data()!);
        parcelOrdersStreamController.sink.add(orderModel);
      }
    });
    yield* parcelOrdersStreamController.stream;
  }

  static Future updateParcelOrder(ParcelOrderModel orderModel) async {
    print("------->${orderModel.adminCommission}");
    await firestore.collection(PARCELORDER).doc(orderModel.id).set(orderModel.toJson(), SetOptions(merge: true));
  }

  late StreamController<User> driverStreamController;
  late StreamSubscription driverStreamSub;

  Stream<User> getDriver(String userId) async* {
    driverStreamController = StreamController();
    driverStreamSub = firestore.collection(USERS).doc(userId).snapshots().listen((onData) async {
      if (onData.data() != null) {
        User? user = User.fromJson(onData.data()!);
        driverStreamController.sink.add(user);
      }
    });
    yield* driverStreamController.stream;
  }

  static Future<List<VehicleType>> getVehicleType() async {
    List<VehicleType> vehicleType = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(VEHICLETYPE).where('sectionId', isEqualTo: SELECTED_CATEGORY).where("isActive", isEqualTo: true).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        vehicleType.add(VehicleType.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return vehicleType;
  }

  static Future<List<PopularDestination>> getPopularDestination() async {
    List<PopularDestination> popularDestination = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(POPULAR_DESTINATION).where('is_publish',isEqualTo: true).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        popularDestination.add(PopularDestination.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return popularDestination;
  }

  static Future<List<RentalVehicleType>> getRentalVehicleType() async {
    List<RentalVehicleType> vehicleType = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(RENTALVEHICLETYPE).where("isActive", isEqualTo: true).get();
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print(document.data());
        vehicleType.add(RentalVehicleType.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return vehicleType;
  }

  static Future<User?> getCurrentUser(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await firestore.collection(USERS).doc(uid).get();
    if (userDocument.data() != null && userDocument.exists) {
      return User.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  Future<User?> getNearestDriver(LatLng? sourceLateLong) async {
    User? user;
    var collectionReference = firestore.collection(USERS).where("role", isEqualTo: "driver");

    GeoFirePoint center = geo.point(latitude: sourceLateLong!.latitude, longitude: sourceLateLong.longitude);

    String field = 'g';

    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        print("------->${user!.userID}");
        user = User.fromJson(data);
      }
    });

    return user;
  }

  static Future<bool> sendFcmMessage(String title, String message, String token) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=$SERVER_KEY",
      };
      var request = {
        "notification": {
          "title": title,
          "body": message,
          "sound": "default",
          // "color": COLOR_PRIMARY,
        },
        "priority": "high",
        'data': <String, dynamic>{ 'id': '1', 'status': 'done'},
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "to": token
      };

      var client = http.Client();
      await client.post(Uri.parse(url), headers: header, body: json.encode(request));
      print('done........$request');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<TaxModel?> getTaxSetting() async {
    DocumentSnapshot<Map<String, dynamic>> taxQuery = await firestore.collection(Setting).doc('taxSetting').get();
    if (taxQuery.data() != null) {
      return TaxModel.fromJson(taxQuery.data()!);
    }
    return null;
  }

  Future<TaxModel?> getSectionTaxSetting(String id) async {
    if (id.isNotEmpty) {
      DocumentSnapshot<Map<String, dynamic>> taxQuery = await firestore.collection(SECTION).doc(id).get();
      if (taxQuery.data() != null) {
        return TaxModel.fromJson(taxQuery.data()!);
      }
    }
    return null;
  }

  Future<String> uploadProductImage(File image, String progress) async {
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child(STORAGE_ROOT +
        '/productImages/$uniqueID'
            '.png');
    UploadTask uploadTask = upload.putFile(image);
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<User?> updateCurrentUser(User user) async {
    //UserPreference.setUserId(userID: user.userID);
    return await firestore.collection(USERS).doc(user.userID).set(user.toJson()).then((document) {
      return user;
    });
  }

  static Future<void> updateCurrentUserAddress(AddressModel userAddress) async {
    //UserPreference.setUserId(userID: user.userID);
    return await firestore.collection(USERS).doc(MyAppState.currentUser!.userID).update(
      {"shippingAddress": userAddress.toJson()},
    ).then((document) {
      print("AAADDDDDD");
    });
  }

  static Future<ProductModel?> updateProduct(ProductModel prodduct) async {
    return await firestore.collection(PRODUCTS).doc(prodduct.id).set(prodduct.toJson()).then((document) {
      return prodduct;
    });
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    return await firestore.collection(VENDORS).doc(vendor.id).set(vendor.toJson()).then((document) {
      return vendor;
    });
  }

  static Future<String> uploadUserImageToFireStorage(File image, String userID) async {
    Reference upload = storage.child(STORAGE_ROOT + '/User/images/$userID.png');
    File compressedImage = await compressImage(image);
    UploadTask uploadTask = upload.putFile(compressedImage);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Future<Url> uploadChatImageToFireStorage(File image, BuildContext context) async {
    showProgress(context, 'Uploading image...'.tr(), false);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child(STORAGE_ROOT + '/chat/images/$uniqueID.png');
    File compressedImage = await compressImage(image);
    UploadTask uploadTask = upload.putFile(compressedImage);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(decimal)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(decimal)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  Future<ChatVideoContainer> uploadChatVideoToFireStorage(File video, BuildContext context) async {
    showProgress(context, 'Uploading video...'.tr(), false);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child(STORAGE_ROOT + '/chat/videos/$uniqueID.mp4');
    File compressedVideo = await _compressVideo(video);
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('Uploading video ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(decimal)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(decimal)} '
          'KB');
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    final uint8list = await VideoThumbnail.thumbnailFile(video: downloadUrl, thumbnailPath: (await getTemporaryDirectory()).path, imageFormat: ImageFormat.PNG);
    final file = File(uint8list ?? '');
    String thumbnailDownloadUrl = await uploadVideoThumbnailToFireStorage(file);
    hideProgress();
    return ChatVideoContainer(videoUrl: Url(url: downloadUrl.toString(), mime: metaData.contentType ?? 'video'), thumbnailUrl: thumbnailDownloadUrl);
  }

  Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child(STORAGE_ROOT + '/thumbnails/$uniqueID.png');
    File compressedImage = await compressImage(file);
    UploadTask uploadTask = upload.putFile(compressedImage);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Stream<User> getUserByID(String id) async* {
    StreamController<User> userStreamController = StreamController();
    firestore.collection(USERS).doc(id).snapshots().listen((user) {
      try {
        User userModel = User.fromJson(user.data() ?? {});
        userStreamController.sink.add(userModel);
      } catch (e) {
        print('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });
    yield* userStreamController.stream;
  }

  Future<List> getVendorCusions(String id) async {
    List tagList = [];
    List prodtagList = [];
    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: id).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      if (document.data().containsKey("categoryID") && document.data()['categoryID'].toString().isNotEmpty) {
        prodtagList.add(document.data()['categoryID']);
      }
    });
    QuerySnapshot<Map<String, dynamic>> catQuery = await firestore.collection(CATEGORIES).where('publish', isEqualTo: true).get();
    await Future.forEach(catQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      Map<String, dynamic> catDoc = document.data();
      if (catDoc.containsKey("id") && catDoc['id'].toString().isNotEmpty && catDoc.containsKey("title") && catDoc['title'].toString().isNotEmpty && prodtagList.contains(catDoc['id'])) {
        tagList.add(catDoc['title']);
      }
    });

    return tagList;
  }

  Stream<StripeKeyModel> getStripe() async* {
    // ignore: close_sinks
    StreamController<StripeKeyModel> stripeStreamController = StreamController();
    firestore.collection(Setting).doc(StripeSetting).snapshots().listen((user) {
      try {
        StripeKeyModel userModel = StripeKeyModel.fromJson(user.data() ?? {});
        stripeStreamController.sink.add(userModel);
      } catch (e) {
        print('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });
    yield* stripeStreamController.stream;
  }

  Stream<RazorPayModel> getRazorPay() async* {
    // ignore: close_sinks
    StreamController<RazorPayModel> stripeStreamController = StreamController();
    firestore.collection(Setting).doc(StripeSetting).snapshots().listen((user) {
      try {
        RazorPayModel userModel = RazorPayModel.fromJson(user.data() ?? {});
        print(userModel.isEnabled);
        isRazorPayEnabled = userModel.isEnabled;
        isRazorPaySandboxEnabled = userModel.isSandboxEnabled;
        razorpayKey = userModel.razorpayKey;
        razorpaySecret = userModel.razorpaySecret;
        stripeStreamController.sink.add(userModel);
      } catch (e) {
        print('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });
    yield* stripeStreamController.stream;
  }

  static getPayFastSettingData() async {
    firestore.collection(Setting).doc("payFastSettings").get().then((payFastData) {
      print(payFastData.data().toString());
      try {
        PayFastSettingData payFastSettingData = PayFastSettingData.fromJson(payFastData.data() ?? {});
        print(payFastData);
        UserPreference.setPayFastData(payFastSettingData);
      } catch (error) {
        print("error>>>122");
        print(error.toString());
      }
    });
  }

  static getPaypalSettingData() async {
    firestore.collection(Setting).doc("paypalSettings").get().then((paypalData) {
      try {
        PaypalSettingData payplaDataModel = PaypalSettingData.fromJson(paypalData.data() ?? {});
        UserPreference.setPayPalData(payplaDataModel);
      } catch (error) {
        print(error.toString());
      }
    });
  }

  static getMercadoPagoSettingData() async {
    firestore.collection(Setting).doc("MercadoPago").get().then((mercadoPago) {
      print(mercadoPago.data());
      try {
        MercadoPagoSettingData mercadoPagoDataModel = MercadoPagoSettingData.fromJson(mercadoPago.data() ?? {});
        UserPreference.setMercadoPago(mercadoPagoDataModel);
      } catch (error) {
        print(error.toString());
      }
    });
  }

  static getStripeSettingData() async {
    firestore.collection(Setting).doc("stripeSettings").get().then((stripeData) {
      try {
        StripeSettingData stripeSettingData = StripeSettingData.fromJson(stripeData.data() ?? {});
        UserPreference.setStripeData(stripeSettingData);
      } catch (error) {
        print(error.toString());
      }
    });
  }

  static getFlutterWaveSettingData() async {
    firestore.collection(Setting).doc("flutterWave").get().then((flutterWaveData) {
      try {
        FlutterWaveSettingData flutterWaveSettingData = FlutterWaveSettingData.fromJson(flutterWaveData.data() ?? {});

        UserPreference.setFlutterWaveData(flutterWaveSettingData);
      } catch (error) {}
    });
  }

  static getPayStackSettingData() async {
    firestore.collection(Setting).doc("payStack").get().then((payStackData) {
      try {
        PayStackSettingData payStackSettingData = PayStackSettingData.fromJson(payStackData.data() ?? {});
        print(payStackSettingData);
        UserPreference.setPayStackData(payStackSettingData);
      } catch (error) {
        print(error.toString());
      }
    });
  }

  static getPaytmSettingData() async {
    firestore.collection(Setting).doc("PaytmSettings").get().then((paytmData) {
      try {
        PaytmSettingData paytmSettingData = PaytmSettingData.fromJson(paytmData.data() ?? {});
        UserPreference.setPaytmData(paytmSettingData);
      } catch (error) {
        print(error.toString());
      }
    });
  }

  static getWalletSettingData() {
    firestore.collection(Setting).doc('walletSettings').get().then((walletSetting) {
      try {
        bool walletEnable = walletSetting.data()!['isEnabled'];
        UserPreference.setWalletData(walletEnable);
      } catch (e) {
        print(e.toString());
      }
    });
  }

  getRazorPayDemo() async {
    RazorPayModel userModel;
    firestore.collection(Setting).doc("razorpaySettings").get().then((user) {
      try {
        print("====loj");
        userModel = RazorPayModel.fromJson(user.data() ?? {});
        UserPreference.setRazorPayData(userModel);
        RazorPayModel fhg = UserPreference.getRazorPayData();
        print(fhg.razorpayKey);
        print("====loj");
        print(userModel);
        //
        // RazorPayController().updateRazorPayData(razorPayData: userModel);

        isRazorPayEnabled = userModel.isEnabled;
        isRazorPaySandboxEnabled = userModel.isSandboxEnabled;
        razorpayKey = userModel.razorpayKey;
        razorpaySecret = userModel.razorpaySecret;
      } catch (e) {
        print('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });

    //yield* razorPayStreamController.stream;
  }

  Future<CodModel?> getCod() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('CODSettings').get();
    if (codQuery.data() != null) {
      print("dataaaaaa");
      return CodModel.fromJson(codQuery.data()!);
    } else {
      print("nulllll");
      return null;
    }
  }

  Future<DeliveryChargeModel?> getDeliveryCharges() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('DeliveryCharge').get();
    if (codQuery.data() != null) {
      return DeliveryChargeModel.fromJson(codQuery.data()!);
    } else {
      return null;
    }
  }

  Future<String?> getStoreNearBy() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('VendorNearBy').get();
    if (codQuery.data() != null) {
      if (serviceTypeFlag == "ecommerce-service") {
        radiusValue = 1000000;
      } else {
        radiusValue = double.parse(codQuery["radios"].toString());
      }
      return codQuery["radios"].toString();
    } else {
      return "";
    }
  }

  Future<Map<String, dynamic>?> getAdminCommission() async {
    DocumentSnapshot<Map<String, dynamic>> codQuery = await firestore.collection(Setting).doc('AdminCommission').get();
    if (codQuery.data() != null) {
      Map<String, dynamic> getValue = {"adminCommission": codQuery["fix_commission"].toString(), "isAdminCommission": codQuery["isEnabled"], 'adminCommissionType': codQuery["commissionType"]};
      print(getValue.toString() + "===____");
      return getValue;
    } else {
      return null;
    }
  }

  Future<List<SectionModel>> getSections() async {
    List<SectionModel> sections = [];
    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(SECTION).where("isActive", isEqualTo: true).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print("--->${document.data()}");
        sections.add(SectionModel.fromJson(document.data()));
      } catch (e) {
        print('**-FireStoreUtils.getSection Parse error $e');
      }
    });

    return sections;
  }

  Future<SectionModel?> getSectionsById(String sectionId) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await firestore.collection(SECTION).doc(sectionId).get();
    if (userDocument.data() != null && userDocument.exists) {
      return SectionModel.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).where("section_id", isEqualTo: SELECTED_CATEGORY).where('publish', isEqualTo: true).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print('${document.data()}');
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('productspppp**-FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    print('****DELIVERYproductspppp**-' + products.length.toString());
    return products;
  }

  Future<List<ProductModel>> getAllDelevryProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery =
        await firestore.collection(PRODUCTS).where("takeawayOption", isEqualTo: false).where("section_id", isEqualTo: SELECTED_CATEGORY).where('publish', isEqualTo: true).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print('${document.data()}');
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('productspppp**-FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    print('****DELIVERYproductspppp**-' + products.length.toString());
    return products;
  }

  Future<List<ProductModel>> getAllTakeAWayProducts() async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery =
        await firestore.collection(PRODUCTS).where("takeawayOption", isEqualTo: true).where("section_id", isEqualTo: SELECTED_CATEGORY).where('publish', isEqualTo: true).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('productspppp**-123--FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    print('****TAKEAproductspppp**-123--' + products.length.toString());
    return products;
  }

  Future<bool> blockUser(User blockedUser, String type) async {
    bool isSuccessful = false;
    BlockUserModel blockUserModel = BlockUserModel(type: type, source: MyAppState.currentUser!.userID, dest: blockedUser.userID, createdAt: Timestamp.now());
    await firestore.collection(REPORTS).add(blockUserModel.toJson()).then((onValue) {
      isSuccessful = true;
    });
    return isSuccessful;
  }

  Stream<bool> getBlocks() async* {
    StreamController<bool> refreshStreamController = StreamController();
    firestore.collection(REPORTS).where('source', isEqualTo: MyAppState.currentUser!.userID).snapshots().listen((onData) {
      List<BlockUserModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> block in onData.docs) {
        list.add(BlockUserModel.fromJson(block.data() ?? {}));
      }
      blockedList = list;
      refreshStreamController.sink.add(true);
    });
    yield* refreshStreamController.stream;
  }

  bool validateIfUserBlocked(String userID) {
    for (BlockUserModel blockedUser in blockedList) {
      if (userID == blockedUser.dest) {
        return true;
      }
    }
    return false;
  }

  Future<Url> uploadAudioFile(File file, BuildContext context) async {
    showProgress(context, 'Uploading Audio...'.tr(), false);
    var uniqueID = const Uuid().v4();
    Reference upload = storage.child(STORAGE_ROOT + '/audio/$uniqueID.mp3');
    SettableMetadata metadata = SettableMetadata(contentType: 'audio');
    UploadTask uploadTask = upload.putFile(file, metadata);
    uploadTask.snapshotEvents.listen((event) {
      updateProgress('Uploading Audio ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(decimal)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(decimal)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      print((onError as PlatformException).message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    hideProgress();
    return Url(mime: metaData.contentType ?? 'audio', url: downloadUrl.toString());
  }

  Future<List<VendorCategoryModel>> getCuisines() async {
    List<VendorCategoryModel> cuisines = [];
    QuerySnapshot<Map<String, dynamic>> cuisinesQuery = await firestore.collection(CATEGORIES).where("section_id", isEqualTo: SELECTED_CATEGORY).where('publish', isEqualTo: true).get();
    await Future.forEach(cuisinesQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        cuisines.add(VendorCategoryModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return cuisines;
  }

  Future<List<VendorCategoryModel>> getHomePageShowCategory() async {
    List<VendorCategoryModel> cuisines = [];
    QuerySnapshot<Map<String, dynamic>> cuisinesQuery =
        await firestore.collection(CATEGORIES).where("section_id", isEqualTo: SELECTED_CATEGORY).where("show_in_homepage", isEqualTo: true).where('publish', isEqualTo: true).get();
    await Future.forEach(cuisinesQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        cuisines.add(VendorCategoryModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return cuisines;
  }

  late StreamController<List<VendorModel>> allDineInResaturantStreamController;

  Stream<List<VendorModel>> getAllDineInRestaurants() async* {
    List<VendorModel> vendors = [];

    allDineInResaturantStreamController = StreamController<List<VendorModel>>.broadcast();
    var collectionReference = firestore.collection(VENDORS).where("section_id", isEqualTo: SELECTED_CATEGORY).where("enabledDiveInFuture", isEqualTo: true);
    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosition.latitude, longitude: MyAppState.selectedPosition.longitude);

    String field = 'g';
    print(radiusValue.toString() + "===RADIUSgetVendorsForNewArrival");
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      if (documentList.isEmpty) {
        allDineInResaturantStreamController.close();
      }
      // doSomething()
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;

        vendors.add(VendorModel.fromJson(data));

        allDineInResaturantStreamController.add(vendors);
      }
    });

    yield* allDineInResaturantStreamController.stream;
  }

  late StreamSubscription vendorStreamSub;
  StreamController<List<VendorModel>>? vendorStreamController;

  Stream<List<VendorModel>> getVendors1({String? path}) async* {
    vendorStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];
    var collectionReference = (path == null || path.isEmpty)
        ? firestore.collection(VENDORS).where("section_id", isEqualTo: SELECTED_CATEGORY)
        : firestore.collection(VENDORS).where("section_id", isEqualTo: SELECTED_CATEGORY).where("enabledDiveInFuture", isEqualTo: true);
    firestore.collection(VENDORS).where("section_id", isEqualTo: SELECTED_CATEGORY);

    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosition.latitude, longitude: MyAppState.selectedPosition.longitude);

    String field = 'g';
    print(radiusValue.toString() + "===RADIUSgetVendors1 ${MyAppState.selectedPosition.latitude} ${MyAppState.selectedPosition.longitude}");
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      print("doc list ${documentList.length}");

      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        vendors.add(VendorModel.fromJson(data));
        final GeoPoint point = data['g']['geopoint'];
        print("=========vendors  ${data['g']['id']} id " + point.latitude.toString() + " ||| " + point.longitude.toString() + " === " + data['title']);
        print(vendors.length.toString() + "----vendors11112222");
      }
      vendorStreamController!.add(vendors);
    });

    yield* vendorStreamController!.stream;
  }

  Future<List<VendorModel>> getVendors() async {
    List<VendorModel> vendors = [];
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(VENDORS).where("section_id", isEqualTo: SELECTED_CATEGORY).get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        vendors.add(VendorModel.fromJson(document.data()));
        print("*-*-/*-*-" + document["title"].toString());
      } catch (e) {
        print('FireStoreUtils.getVendors Parse error $e');
      }
    });
    return vendors;
  }

  Stream<List<BookTableModel>> getBookingOrders(String userID, bool isUpComing) async* {
    List<BookTableModel> orders = [];

    if (isUpComing) {
      StreamController<List<BookTableModel>> upcomingordersStreamController = StreamController();
      firestore
          .collection(ORDERS_TABLE)
          .where('author.id', isEqualTo: userID)
          .where('date', isGreaterThan: Timestamp.now())
          .where("section_id", isEqualTo: SELECTED_CATEGORY)
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((onData) async {
        await Future.forEach(onData.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
          try {
            orders.add(BookTableModel.fromJson(element.data()));
          } catch (e, s) {
            print('booktable parse error ${element.id} $e $s');
          }
        });
        upcomingordersStreamController.sink.add(orders);
      });
      yield* upcomingordersStreamController.stream;
    } else {
      StreamController<List<BookTableModel>> bookedordersStreamController = StreamController();
      firestore
          .collection(ORDERS_TABLE)
          .where('author.id', isEqualTo: userID)
          .where('date', isLessThan: Timestamp.now())
          .where("section_id", isEqualTo: SELECTED_CATEGORY)
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((onData) async {
        await Future.forEach(onData.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
          try {
            orders.add(BookTableModel.fromJson(element.data()));
          } catch (e, s) {
            print('booktable parse error ${element.id} $e $s');
          }
        });
        bookedordersStreamController.sink.add(orders);
      });
      yield* bookedordersStreamController.stream;
    }
  }

  late StreamSubscription ordersStreamSub;
  late StreamController<List<OrderModel>> ordersStreamController;

  Stream<List<OrderModel>> getOrders(String userID) async* {
    List<OrderModel> orders = [];
    ordersStreamController = StreamController();
    ordersStreamSub =
        firestore.collection(ORDERS).where('authorID', isEqualTo: userID).where('section_id', isEqualTo: SELECTED_CATEGORY).orderBy('createdAt', descending: true).snapshots().listen((onData) async {
          orders.clear();

          await Future.forEach(onData.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
        try {
          OrderModel orderModel = OrderModel.fromJson(element.data());
          if (!orders.contains(orderModel)) {
            orders.add(orderModel);
          }
        } catch (e, s) {
          print('watchOrdersStatus parse error ${element.id} $e $s');
        }
      });
      ordersStreamController.sink.add(orders);
    });
    yield* ordersStreamController.stream;
  }

  closeOrdersStream() {
    ordersStreamSub.cancel();
    ordersStreamController.close();
  }

  void setFavouriteStore(FavouriteModel favouriteModel) {
    var collectionReference = firestore.collection(FavouriteStore).add(favouriteModel.toJson()).then((value) {
      print("===FAVOURITE ADDED===");
    });
  }

  void removeFavouriteStore(FavouriteModel favouriteModel) {
    FirebaseFirestore.instance.collection(FavouriteStore).where("store_id", isEqualTo: favouriteModel.store_id).where("section_id", isEqualTo: SELECTED_CATEGORY).get().then((value) {
      for (var element in value.docs) {
        FirebaseFirestore.instance.collection(FavouriteStore).doc(element.id).delete().then((value) {
          print("Success!");
        });
      }
    });
  }

  Future<List<FavouriteItemModel>> getFavouritesProductList(String userId) async {
    List<FavouriteItemModel> lstFavourites = [];

    QuerySnapshot<Map<String, dynamic>> favourites = await firestore.collection(FavouriteItem).where('user_id', isEqualTo: userId).where("section_id", isEqualTo: SELECTED_CATEGORY).get();
    await Future.forEach(favourites.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print('------------> ${document.data()}');
        lstFavourites.add(FavouriteItemModel.fromJson(document.data()));
      } catch (e) {
        print('FavouriteModel.getCurrencys Parse error $e');
      }
    });
    return lstFavourites;
  }

  Future<void> setFavouriteStoreItem(FavouriteItemModel favouriteModel) async {
    await firestore.collection(FavouriteItem).add(favouriteModel.toJson()).then((value) {
      print("===FAVOURITE ADDED===");
    });
  }

  void removeFavouriteItem(FavouriteItemModel favouriteModel) {
    FirebaseFirestore.instance.collection(FavouriteItem).where("product_id", isEqualTo: favouriteModel.product_id).where("section_id", isEqualTo: SELECTED_CATEGORY).get().then((value) {
      for (var element in value.docs) {
        FirebaseFirestore.instance.collection(FavouriteItem).doc(element.id).delete().then((value) {
          print("Success!");
        });
      }
    });
  }

  /*closeFavouriteStream() {
    favouriteStreamSub.cancel();
    favouriteStreamControleer.close();
  }*/

  StreamController<List<VendorModel>>? allResaturantStreamController;

  Stream<List<VendorModel>> getAllStores() async* {
    allResaturantStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];
    print("sectionID---->$SELECTED_CATEGORY");

    try {
      var collectionReference = firestore.collection(VENDORS).where("section_id", isEqualTo: SELECTED_CATEGORY);

      GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosition.latitude, longitude: MyAppState.selectedPosition.longitude);

      String field = 'g';
      Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);

      stream.listen((List<DocumentSnapshot> documentList) {
        if (documentList.isEmpty) {
          allResaturantStreamController!.close();
        }

        for (var document in documentList) {
          print("----------->  ${documentList.toString()}");
          final data = document.data() as Map<String, dynamic>;
          vendors.add(VendorModel.fromJson(data));
          allResaturantStreamController!.add(vendors);
        }
      });
    } catch (e) {
      print('FavouriteModel $e');
    }

    yield* allResaturantStreamController!.stream;
  }

  closeVendorStream() {
    if (vendorStreamController != null) {
      vendorStreamController!.close();
    }
    if (allResaturantStreamController != null) {
      allResaturantStreamController!.close();
    }
    //newArrivalStreamController.close();
    //productStreamController123.close();
    //productStreamController.close();
  }

  late StreamController<List<VendorModel>> popularStreamController;

  Stream<List<VendorModel>> getPopularsVendors({String? path}) async* {
    List<VendorModel> vendors = [];

    popularStreamController = StreamController<List<VendorModel>>.broadcast();
    var collectionReference = (path == null || path.isEmpty)
        ? firestore.collection(VENDORS).where("section_id", isEqualTo: SELECTED_CATEGORY)
        : firestore.collection(VENDORS).where("section_id", isEqualTo: SELECTED_CATEGORY).where("enabledDiveInFuture", isEqualTo: true);
    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosition.latitude, longitude: MyAppState.selectedPosition.longitude);
    String field = 'g';
    print(radiusValue.toString() + "===RADIUSgetVendorsForNewArrival");
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);
    stream.listen((List<DocumentSnapshot> documentList) {
      if (documentList.isEmpty) {
        popularStreamController.close();
      }

      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        VendorModel vendorModel = VendorModel.fromJson(data);
        if ((vendorModel.reviewsSum / vendorModel.reviewsCount) >= 4.0) {
          vendors.add(vendorModel);
          popularStreamController.add(vendors);
        }
      }
    });

    yield* popularStreamController.stream;
  }

  late StreamController<List<VendorModel>> newArrivalStreamController;

  Stream<List<VendorModel>> getVendorsForNewArrival({String? path}) async* {
    List<VendorModel> vendors = [];

    newArrivalStreamController = StreamController<List<VendorModel>>.broadcast();
    var collectionReference = (path == null || path.isEmpty)
        ? firestore.collection(VENDORS).where("section_id", isEqualTo: SELECTED_CATEGORY)
        : firestore.collection(VENDORS).where("section_id", isEqualTo: SELECTED_CATEGORY).where("enabledDiveInFuture", isEqualTo: true);

    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosition.latitude, longitude: MyAppState.selectedPosition.longitude);

    String field = 'g';

    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      if (documentList.isEmpty) {
        newArrivalStreamController.close();
      }
      print(documentList.toString() + "=======>");
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;

        print(data.toString() + "=======>");
        vendors.add(VendorModel.fromJson(data));

        newArrivalStreamController.add(vendors);
      }
    });

    yield* newArrivalStreamController.stream;
  }

  closeNewArrivalStream() {
    newArrivalStreamController.close();
  }

  late StreamController<List<VendorModel>> cusionStreamController;

  Stream<List<VendorModel>> getVendorsByCuisineID(String cuisineID, {bool? isDinein}) async* {
    await getStoreNearBy();
    cusionStreamController = StreamController<List<VendorModel>>.broadcast();
    List<VendorModel> vendors = [];
    var collectionReference = isDinein!
        ? firestore.collection(VENDORS).where('categoryID', isEqualTo: cuisineID).where("enabledDiveInFuture", isEqualTo: true)
        : firestore.collection(VENDORS).where('categoryID', isEqualTo: cuisineID);

    String field = 'g';
    GeoFirePoint center = geo.point(latitude: MyAppState.selectedPosition.latitude, longitude: MyAppState.selectedPosition.longitude);
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radiusValue, field: field, strictMode: true);
    stream.listen((List<DocumentSnapshot> documentList) {
      Future.forEach(documentList, (DocumentSnapshot element) {
        final data = element.data() as Map<String, dynamic>;
        vendors.add(VendorModel.fromJson(data));
        cusionStreamController.add(vendors);
      });
      cusionStreamController.close();
    });

    yield* cusionStreamController.stream;
  }

  Future<List<OfferModel>> getViewAllOffer() async {
    List<OfferModel> offersData = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(COUPONS).where("isEnabled", isEqualTo: true).where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now()).get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        offersData.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getVendors Parse error $e');
      }
    });
    return offersData;
  }

  // Stream<List<OfferModel>>? getOfferStream() async* {
  //   List<OfferModel> offers = [];
  //   offerStreamController = StreamController<List<OfferModel>>.broadcast();
  //   var date = DateTime.now();
  //
  //   offerStreamSub = firestore
  //       .collection(COUPONS)
  //       .where("isEnabled", isEqualTo: true)
  //       .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
  //       .snapshots()
  //       .listen((event) async {
  //     offers.clear();
  //     if (event.docs.isEmpty) {
  //       offerStreamController!.add(offers);
  //     } else {
  //       await Future.forEach(event.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
  //         try {
  //           offers.add(OfferModel.fromJson(element.data()));
  //         } catch (e, s) {
  //           print('getOrder parse error ${element.id}$e $s');
  //         }
  //       });
  //       offerStreamController!.add(offers);
  //     }
  //
  //     print(offers.length.toString() + "{}{}====+++999");
  //   });
  //   yield* offerStreamController!.stream;
  // }

  StreamController<List<OfferModel>>? offerStreamController;
  StreamSubscription? offerStreamSub;

  Stream<List<OfferModel>> getOfferStreamByVendorID(String vendorID) async* {
    print(vendorID.toString() + "{}");
    List<OfferModel> offers = [];
    offerStreamController = StreamController<List<OfferModel>>();
    offerStreamSub = firestore
        .collection(COUPONS)
        .where("vendorID", isEqualTo: vendorID)
        .where("isEnabled", isEqualTo: true)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .snapshots()
        .listen((event) async {
      offers.clear();
      await Future.forEach(event.docs, (QueryDocumentSnapshot<Map<String, dynamic>> element) {
        try {
          offers.add(OfferModel.fromJson(element.data()));
          print(element.data().toString());
        } catch (e, s) {
          print('getProductsStream parse error ${element.id}$e $s');
        }
      });
      print(offers.length.toString() + "{}{}");
      print(offers.length.toString() + "{}{}====+++999000");
      offerStreamController!.add(offers);
    });
    yield* offerStreamController!.stream;
  }

  Future<List<OfferModel>> getOfferByVendorID(String vendorID) async {
    List<OfferModel> offers = [];
    QuerySnapshot<Map<String, dynamic>> bannerHomeQuery =
        await firestore.collection(COUPONS).where("vendorID", isEqualTo: vendorID).where("isEnabled", isEqualTo: true).where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now()).get();

    print("-------->${bannerHomeQuery.docs}");
    await Future.forEach(bannerHomeQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print("-------->");
        print(document.data());
        offers.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return offers;
  }

  closeOfferStream() {
    if (offerStreamSub != null) {
      offerStreamSub!.cancel();
    }
    if (offerStreamController != null) {
      offerStreamController!.close();
    }
  }

  Future<String?> getplaceholderimage() async {
//  var variable = await firestore.collection(Setting)
//  .doc('placeHolderImage').get();
// Map<String, dynamic>? mapEventData = variable.data() ;
//  Map<String, dynamic> getField = jsonDecode(mapEventData!['image']);
//  print(getField['data']);
    var collection = FirebaseFirestore.instance.collection(Setting);
    var docSnapshot = await collection.doc('placeHolderImage').get();
// if (docSnapshot.exists) {
    Map<String, dynamic>? data = docSnapshot.data();
    var value = data?['image'];
    // <-- The value you want to retrieve.
    // print(value);
    // Call setState if needed.
// }
    placeholderImage = value;
    return placeholderImage;
  }

  Future<List<BannerModel>> getHomeTopBanner() async {
    List<BannerModel> bannerHome = [];
    print(SELECTED_CATEGORY);
    QuerySnapshot<Map<String, dynamic>> bannerHomeQuery = await firestore
        .collection(MENU_ITEM)
        .where("is_publish", isEqualTo: true)
        .where('sectionId', isEqualTo: SELECTED_CATEGORY)
        .where("position", isEqualTo: "top")
        .orderBy("set_order", descending: false)
        .get();

    await Future.forEach(bannerHomeQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print("{{{-------->${document.data()}");
        bannerHome.add(BannerModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return bannerHome;
  }

  Future<List<BannerModel>> getHomeMiddleBanner() async {
    List<BannerModel> bannerHome = [];
    print(SELECTED_CATEGORY);
    QuerySnapshot<Map<String, dynamic>> bannerHomeQuery = await firestore
        .collection(MENU_ITEM)
        .where("is_publish", isEqualTo: true)
        .where('sectionId', isEqualTo: SELECTED_CATEGORY)
        .where("position", isEqualTo: "middle")
        .orderBy("set_order", descending: false)
        .get();

    print("-------->${bannerHomeQuery.docs}");
    await Future.forEach(bannerHomeQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print("-------->");
        print(document.data());
        bannerHome.add(BannerModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCuisines Parse error $e');
      }
    });
    return bannerHome;
  }

  Future<List<CurrencyModel>> getCurrency() async {
    List<CurrencyModel> currency = [];

    QuerySnapshot<Map<String, dynamic>> currencyQuery = await firestore.collection(Currency).where("isActive", isEqualTo: true).get();
    print(currencyQuery.docs);
    await Future.forEach(currencyQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        currency.add(CurrencyModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getCurrencys Parse error $e');
      }
    });
    return currency;
  }

  Future<List<OfferModel>> getAllCoupons() async {
    List<OfferModel> coupon = [];

    QuerySnapshot<Map<String, dynamic>> couponsQuery = await firestore.collection(COUPON).where('isEnabled', isEqualTo: true).where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now()).get();
    await Future.forEach(couponsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        coupon.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return coupon;
  }

  Future<List<OfferModel>> getCabCoupons() async {
    List<OfferModel> coupon = [];

    QuerySnapshot<Map<String, dynamic>> couponsQuery = await firestore.collection(CAB_COUPONS).where('isEnabled', isEqualTo: true).where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now()).get();
    await Future.forEach(couponsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        coupon.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return coupon;
  }

  Future<List<OfferModel>> getParcelCoupan() async {
    List<OfferModel> coupon = [];

    QuerySnapshot<Map<String, dynamic>> couponsQuery = await firestore.collection(PARCELCOUPONS).where('isEnabled', isEqualTo: true).where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now()).get();
    await Future.forEach(couponsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        coupon.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return coupon;
  }

  Future<List<OfferModel>> getRentalCoupons() async {
    List<OfferModel> coupon = [];

    QuerySnapshot<Map<String, dynamic>> couponsQuery = await firestore.collection(RENTALCOUPONS).where('isEnabled', isEqualTo: true).where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now()).get();
    await Future.forEach(couponsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        coupon.add(OfferModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    return coupon;
  }

  Future<List<ProductModel>> getVendorProducts(String vendorID) async {
    print(vendorID);
    print('we are Enter getVendorProducts--*');
    print('**622a02b704d84');
    List<ProductModel> products = [];
    print('we are Enter getVendorProducts');

    QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: vendorID).where('publish', isEqualTo: true).get();
    print(productsQuery.docs.length);
    print('we are Enter getVendorProducts--.');
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        print('dmolk');
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getVendorProducts Parse error $e');
      }
    });
    print('product data1');
    print(products.toString());
    return products;
  }

  Future<List<ProductModel>> getVendorProductsTakeAWay(String vendorID) async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery =
        await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: vendorID).where("takeawayOption", isEqualTo: true).where('publish', isEqualTo: true).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
        //print('=====TP+++++ ${document.data().toString()}');
      } catch (e) {
        print('FireStoreUtils.getVendorProducts Parse error $e');
      }
    });
    print("=====IDDDDDD" + products.length.toString());
    return products;
  }

  Future<List<ProductModel>> getVendorProductsDelivery(String vendorID) async {
    List<ProductModel> products = [];

    QuerySnapshot<Map<String, dynamic>> productsQuery =
        await firestore.collection(PRODUCTS).where('vendorID', isEqualTo: vendorID).where("takeawayOption", isEqualTo: false).where('publish', isEqualTo: true).get();
    await Future.forEach(productsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        products.add(ProductModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getVendorProducts Parse error $e');
      }
    });
    print("=====IDDDDDD----" + products.length.toString());
    return products;
  }

  //  Future<List<ProductModel>> updatevendorProduct(ProductModel productModel) async {
  //   return await firestore
  //       .collection(PRODUCTS)
  //       .doc(productModel.id).collection("quentity").doc(productModel.quantity)
  //       .set(user.toJson())
  //       .then((document) {
  //     return user;
  //   });
  // }
//  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
//     return await firestore
//         .collection(VENDORS)
//         .doc(vendor.id)
//         .set(vendor.toJson())
//         .then((document) {
//       return vendor;
//     });
//   }

  Future<VendorCategoryModel?> getVendorCategoryById(String vendorCategoryID) async {
    print('we are enter-->${vendorCategoryID}');
    VendorCategoryModel? vendorCategoryModel;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery =
        await firestore.collection(CATEGORIES).where('id', isEqualTo: vendorCategoryID).where("section_id", isEqualTo: SELECTED_CATEGORY).where('publish', isEqualTo: true).get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        print('we are enter-->${vendorsQuery.docs.first.data()}');

        vendorCategoryModel = VendorCategoryModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return vendorCategoryModel;
  }

  Future<VendorCategoryModel?> getVendorCategoryByCategoryId(String vendorCategoryID) async {
    DocumentSnapshot<Map<String, dynamic>> documentReference = await firestore.collection(CATEGORIES).doc(vendorCategoryID).get();
    if (documentReference.data() != null && documentReference.exists) {
      print("dataaaaaa aaa ");
      return VendorCategoryModel.fromJson(documentReference.data()!);
    } else {
      print("nulllll");
      return null;
    }
  }

  Future<ReviewAttributeModel?> getVendorReviewAttribute(String attrubuteId) async {
    DocumentSnapshot<Map<String, dynamic>> documentReference = await firestore.collection(REVIEW_ATTRIBUTES).doc(attrubuteId).get();
    if (documentReference.data() != null && documentReference.exists) {
      print("dataaaaaa aaa ");
      return ReviewAttributeModel.fromJson(documentReference.data()!);
    } else {
      print("nulllll");
      return null;
    }
  }

  Future<VendorModel> getVendorByVendorID(String vendorID) async {
    late VendorModel vendor;
    print(vendorID.toString() + "----VENDORIDPLACEORDER");
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(VENDORS).where('id', isEqualTo: vendorID).get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        vendor = VendorModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return vendor;
  }

  Future<ProductModel> getProductByProductID(String productId) async {
    late ProductModel productModel;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(PRODUCTS).where('id', isEqualTo: productId).where('publish', isEqualTo: true).get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        productModel = ProductModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return productModel;
  }

  Future<ProductModel> getProductByID(String productId) async {
    late ProductModel productModel;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(PRODUCTS).where('id', isEqualTo: productId).get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        productModel = ProductModel.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return productModel;
  }

  Future<User?> getUserByIDS(String userId) async {
    User? vendor;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(USERS).where('id', isEqualTo: userId).get();
    try {
      if (vendorsQuery.docs.isNotEmpty) {
        vendor = User.fromJson(vendorsQuery.docs.first.data());
      }
    } catch (e) {
      print('FireStoreUtils.getVendorByVendorID Parse error $e');
    }
    return vendor;
  }

  Future<RatingModel?> getReviewsbyID(String ordertId) async {
    RatingModel? ratingproduct;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(Order_Rating).where('orderid', isEqualTo: ordertId).get();
    if (vendorsQuery.docs.isNotEmpty) {
      try {
        if (vendorsQuery.docs.isNotEmpty) {
          ratingproduct = RatingModel.fromJson(vendorsQuery.docs.first.data());
        }
      } catch (e) {
        print('FireStoreUtils.getVendorByVendorID Parse error $e');
      }
    }
    return ratingproduct;
  }

  Future<RatingModel?> getOrderReviewsbyID(String ordertId, String productId) async {
    RatingModel? ratingproduct;
    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(Order_Rating).where('orderid', isEqualTo: ordertId).where('productId', isEqualTo: productId).get();
    if (vendorsQuery.docs.isNotEmpty) {
      try {
        if (vendorsQuery.docs.isNotEmpty) {
          ratingproduct = RatingModel.fromJson(vendorsQuery.docs.first.data());
        }
      } catch (e) {
        print('FireStoreUtils.getVendorByVendorID Parse error $e');
      }
    }
    return ratingproduct;
  }

  // Future<RatingModel> getReviewsbyVendorID(String vendorId) async {
  //   late RatingModel ratingproduct;
  //   QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
  //       .collection(Order_Rating)
  //       .where('VendorId', isEqualTo: vendorId)
  //       .get();
  //   try {
  //     ratingproduct = RatingModel.fromJson(vendorsQuery.docs.first.data());
  //   } catch (e) {
  //     print('FireStoreUtils.getVendorByVendorID Parse error $e');
  //   }
  //   return ratingproduct;
  // }

  Future<List<RatingModel>> getReviewsbyVendorID(String vendorId) async {
    List<RatingModel> vendorreview = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(Order_Rating)
        .where('VendorId', isEqualTo: vendorId)
        // .orderBy('createdAt', descending: true)
        .get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      print(document);
      try {
        vendorreview.add(RatingModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getOrders Parse error ${document.id} $e');
      }
    });
    return vendorreview;
  }

  Future<List<RatingModel>> getReviewByDriverId(String driverId) async {
    List<RatingModel> vendorreview = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore
        .collection(Order_Rating)
        .where('driverId', isEqualTo: driverId)
        // .orderBy('createdAt', descending: true)
        .get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      print(document);
      try {
        vendorreview.add(RatingModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getOrders Parse error ${document.id} $e');
      }
    });
    return vendorreview;
  }

  static Future<RatingModel?> updateReviewbyId(RatingModel ratingproduct) async {
    return await firestore.collection(Order_Rating).doc(ratingproduct.id).set(ratingproduct.toJson()).then((document) {
      return ratingproduct;
    });
  }

  Future<List<FavouriteModel>> getFavouriteStore(String userId) async {
    List<FavouriteModel> favouriteItem = [];

    QuerySnapshot<Map<String, dynamic>> vendorsQuery = await firestore.collection(FavouriteStore).where('user_id', isEqualTo: userId).where("section_id", isEqualTo: SELECTED_CATEGORY).get();
    await Future.forEach(vendorsQuery.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        favouriteItem.add(FavouriteModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getVendors Parse error $e');
      }
    });
    print(favouriteItem.length.toString() + "===FL===" + userId);
    return favouriteItem;
  }

  Future<BookTableModel> bookTable(BookTableModel orderModel) async {
    DocumentReference documentReference = firestore.collection(ORDERS_TABLE).doc();
    orderModel.id = documentReference.id;
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  Future<OrderModel> placeOrder(OrderModel orderModel) async {
    DocumentReference documentReference = firestore.collection(ORDERS).doc(UserPreference.getOrderId());
    orderModel.id = documentReference.id;
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  Future<OrderModel> placeOrderWithTakeAWay(OrderModel orderModel) async {
    DocumentReference documentReference;
    if (orderModel.id.isEmpty) {
      documentReference = firestore.collection(ORDERS).doc();
      orderModel.id = documentReference.id;
    } else {
      documentReference = firestore.collection(ORDERS).doc(orderModel.id);
    }
    await documentReference.set(orderModel.toJson());
    return orderModel;
  }

  static createOrder() async {
    DocumentReference documentReference = firestore.collection(ORDERS).doc();
    final orderId = documentReference.id;
    UserPreference.setOrderId(orderId: orderId);
  }

  static Future createPaymentId() async {
    DocumentReference documentReference = firestore.collection(Wallet).doc();
    final paymentId = documentReference.id;
    UserPreference.setPaymentId(paymentId: paymentId);
    return paymentId;
  }

  static Future<List<TopupTranHistoryModel>> getTopUpTransaction() async {
    final userId = MyAppState.currentUser!.userID; //UserPreference.getUserId();
    List<TopupTranHistoryModel> topUpHistoryList = [];
    QuerySnapshot<Map<String, dynamic>> documentReference = await firestore.collection(Wallet).where('user_id', isEqualTo: userId).get();
    await Future.forEach(documentReference.docs, (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        topUpHistoryList.add(TopupTranHistoryModel.fromJson(document.data()));
      } catch (e) {
        print('FireStoreUtils.getAllProducts Parse error $e');
      }
    });
    // QuerySnapshot<Map<String, dynamic>> productsQuery = await firestore.collection(Wallet).get();
    // await Future.forEach(productsQuery.docs,
    //         (QueryDocumentSnapshot<Map<String, dynamic>> document) {
    //       try {
    //         products.add(TopupTranHistoryModel.fromJson(document.data()));
    //       } catch (e) {
    //         print('FireStoreUtils.getAllProducts Parse error $e');
    //       }
    //     });

    // final paymentId = documentReference;
    // UserPreference.setPaymentId(paymentId: paymentId);
    return topUpHistoryList;
  }

  static Future topUpWalletAmount({String serviceType = "", String paymentMethod = "test", bool isTopup = true, required amount, required id, orderId = ""}) async {
    print("this is te payment id");
    print(id);
    print(MyAppState.currentUser!.userID);

    await firestore.collection(Wallet).doc(id).set({
      "serviceType": serviceType,
      "user_id": MyAppState.currentUser!.userID,
      "payment_method": paymentMethod,
      "amount": amount,
      "id": id,
      "order_id": orderId,
      "isTopUp": isTopup,
      "payment_status": "success",
      "date": DateTime.now(),
    }).then((value) {
      firestore.collection(Wallet).doc(id).get().then((value) {
        DocumentSnapshot<Map<String, dynamic>> documentData = value;
        print("nato");
        print(documentData.data());
      });
    });

    return "updated Amount";
    // if (userDocument.data() != null && userDocument.exists) {
    //   try{
    //     print(userDocument.data());
    //     walletAmount = userDocument["wallet_amount"];
    //     print(userDocument["wallet_amount"]);
    //     print(userDocument["active"]);
    //   }catch(erro){
    //     print(erro);
    //     print(erro.toString());
    //     if(erro.toString() == "Bad state: field does not exist within the DocumentSnapshotPlatform"){
    //       print("dones not exist");
    //       await firestore.collection(USERS).doc(userId).set({"wallet_amount": 0});
    //       walletAmount = 0;
    //     }else{
    //       print("went wrong!!");
    //       walletAmount = "ERROR";
    //     }
    //
    //   }
    //   return walletAmount;//User.fromJson(userDocument.data()!);
    // } else {
    //   return null;
    // }
  }

  static Future updateWalletAmount({required amount}) async {
    dynamic walletAmount = 0;
    final userId = MyAppState.currentUser!.userID; //UserPreference.getUserId();
    /* DocumentSnapshot<Map<String, dynamic>> userDocument =*/
    await firestore.collection(USERS).doc(userId).get().then((value) async {
      DocumentSnapshot<Map<String, dynamic>> userDocument = value;
      if (userDocument.data() != null && userDocument.exists) {
        try {
          print(userDocument.data());
          User user = User.fromJson(userDocument.data()!);
          MyAppState.currentUser = user;
          print(user.lastName.toString() + "=====.....(user.wallet_amount");
          print("add ${user.lastName} + $amount");
          await firestore.collection(USERS).doc(userId).update({"wallet_amount": user.wallet_amount + amount}).then((value) => print("north"));
          /*print(user.wallet_amount);


          walletAmount = user.wallet_amount! + amount;*/
          DocumentSnapshot<Map<String, dynamic>> newUserDocument = await firestore.collection(USERS).doc(userId).get();
          MyAppState.currentUser = User.fromJson(newUserDocument.data()!);
          print(MyAppState.currentUser);
        } catch (error) {
          print(error);
          if (error.toString() == "Bad state: field does not exist within the DocumentSnapshotPlatform") {
            print("does not exist");
            //await firestore.collection(USERS).doc(userId).update({"wallet_amount": 0});
            //walletAmount = 0;
          } else {
            print("went wrong!!");
            walletAmount = "ERROR";
          }
        }
        print("data val");
        print(walletAmount);
        return walletAmount; //User.fromJson(userDocument.data()!);
      } else {
        return 0.111;
      }
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchOrderStatus(String orderID) async* {
    yield* firestore.collection(ORDERS).doc(orderID).snapshots();
  }

  /// compress image file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the image after
  /// being compressed(100 = max quality - 0 = low quality)
  /// @param file the image file that will be compressed
  /// @return File a new compressed file with smaller size
  static Future<File> compressImage(File file) async {
    File compressedImage = await FlutterNativeImage.compressImage(
      file.path,
      quality: 25,
    );
    return compressedImage;
  }

  /// compress video file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the video after
  /// being compressed
  /// @param file the video file that will be compressed
  /// @return File a new compressed file with smaller size
  Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path, quality: VideoQuality.DefaultQuality, deleteOrigin: false, includeAudio: true, frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static loginWithFacebook() async {
    /// creates a user for this facebook login when this user first time login
    /// and save the new user object to firebase and firebase auth
    FacebookAuth facebookAuth = FacebookAuth.instance;
    bool isLogged = await facebookAuth.accessToken != null;
    print("isLogged $isLogged");
    if (!isLogged) {
      LoginResult result = await facebookAuth.login(
        permissions: [
          'public_profile',
          'email',
        ],
      ); // by default we request the email and the public profile
      if (result.status == LoginStatus.success) {
        // you are logged
        AccessToken? token = await facebookAuth.accessToken;
        return await handleFacebookLogin(await facebookAuth.getUserData(), token!);
      }
    } else {
      AccessToken? token = await facebookAuth.accessToken;
      return await handleFacebookLogin(await facebookAuth.getUserData(), token!);
    }
  }

  static handleFacebookLogin(Map<String, dynamic> userData, AccessToken token) async {
    auth.UserCredential authResult = await auth.FirebaseAuth.instance.signInWithCredential(auth.FacebookAuthProvider.credential(token.token));
    User? user = await getCurrentUser(authResult.user?.uid ?? ' ');
    List<String> fullName = (userData['name'] as String).split(' ');
    String firstName = '';
    String lastName = '';
    if (fullName.isNotEmpty) {
      firstName = fullName.first;
      lastName = fullName.skip(1).join(' ');
    }
    print("USer role ${user?.role}");
    if (user != null && user.role == USER_ROLE_CUSTOMER) {
      user.profilePictureURL = userData['picture']['data']['url'];
      user.firstName = firstName;
      user.lastName = lastName;
      user.email = userData['email'];
      //user.active = true;
      user.role = USER_ROLE_CUSTOMER;
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      dynamic result = await updateCurrentUser(user);
      return result;
    } else if (user == null) {
      user = User(
          email: userData['email'] ?? '',
          firstName: firstName,
          profilePictureURL: userData['picture']['data']['url'] ?? '',
          userID: authResult.user?.uid ?? '',
          lastOnlineTimestamp: Timestamp.now(),
          lastName: lastName,
          active: true,
          role: USER_ROLE_CUSTOMER,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: '',
          settings: UserSettings());
      String? errorMessage = await firebaseCreateNewUser(user,"");
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  static loginWithApple() async {
    final appleCredential = await apple.TheAppleSignIn.performRequests([
      const apple.AppleIdRequest(requestedScopes: [apple.Scope.email, apple.Scope.fullName])
    ]);
    if (appleCredential.error != null) {
      return "Couldn't login with apple.".tr();
    }

    if (appleCredential.status == apple.AuthorizationStatus.authorized) {
      final auth.AuthCredential credential = auth.OAuthProvider('apple.com').credential(
        accessToken: String.fromCharCodes(appleCredential.credential?.authorizationCode ?? []),
        idToken: String.fromCharCodes(appleCredential.credential?.identityToken ?? []),
      );
      return await handleAppleLogin(credential, appleCredential.credential!);
    } else {
      return "Couldn't login with apple.".tr();
    }
  }

  static handleAppleLogin(
    auth.AuthCredential credential,
    apple.AppleIdCredential appleIdCredential,
  ) async {
    auth.UserCredential authResult = await auth.FirebaseAuth.instance.signInWithCredential(credential);
    User? user = await getCurrentUser(authResult.user?.uid ?? '');
    if (user != null) {
      //user.active = true;
      user.role = USER_ROLE_CUSTOMER;
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      dynamic result = await updateCurrentUser(user);
      return result;
    } else {
      user = User(
          email: appleIdCredential.email ?? '',
          firstName: appleIdCredential.fullName?.givenName ?? '',
          profilePictureURL: '',
          userID: authResult.user?.uid ?? '',
          lastOnlineTimestamp: Timestamp.now(),
          lastName: appleIdCredential.fullName?.familyName ?? '',
          role: USER_ROLE_CUSTOMER,
          active: true,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          phoneNumber: '',
          settings: UserSettings());
      String? errorMessage = await firebaseCreateNewUser(user,"");
      if (errorMessage == null) {
        return user;
      } else {
        return errorMessage;
      }
    }
  }

  /// save a new user document in the USERS table in firebase firestore
  /// returns an error message on failure or null on success
  static Future<String?> firebaseCreateNewUser(User user, String referralCode) async {
    try {
      if (referralCode.isNotEmpty) {
        FireStoreUtils.getReferralUserByCode(referralCode.toString()).then((value) async {
          if (value != null) {
            ReferralModel ownReferralModel = ReferralModel(id: user.userID, referralBy: value.id, referralCode: getReferralCode());
            await referralAdd(ownReferralModel);
          } else {
            ReferralModel referralModel = ReferralModel(id: user.userID, referralBy: "", referralCode: getReferralCode());
            await referralAdd(referralModel);
          }
        });
      } else {
        ReferralModel referralModel = ReferralModel(id: user.userID, referralBy: "", referralCode: getReferralCode());
        await referralAdd(referralModel);
      }

      await firestore.collection(USERS).doc(user.userID).set(user.toJson());
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return "notSignUp".tr();
    }
    return null;
  }

  static Future<String?> referralAdd(ReferralModel ratingModel) async {
    try {
      await firestore.collection(REFERRAL).doc(ratingModel.id).set(ratingModel.toJson());
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return 'Couldn\'t review'.tr();
    }
    return null;
  }

  static Future<String?> firebaseCreateNewReview(RatingModel ratingModel) async {
    try {
      await firestore.collection(Order_Rating).doc(ratingModel.id).set(ratingModel.toJson());
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return "Couldn't review".tr();
    }
  }

  /// login with email and password with firebase
  /// @param email user email
  /// @param password user password
  static Future<dynamic> loginWithEmailAndPassword(String email, String password) async {
    try {
      print('FireStoreUtils.loginWithEmailAndPassword');
      auth.UserCredential result = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // result.user.
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firestore.collection(USERS).doc(result.user?.uid ?? '').get();
      User? user;

      if (documentSnapshot.exists) {
        // if(user!.role != 'vendor'){
        user = User.fromJson(documentSnapshot.data() ?? {});
        // if(  USER_ROLE_CUSTOMER ==user.role)
        // {
        user.fcmToken = await firebaseMessaging.getToken() ?? '';

        //user.active = true;

        //      }
      }
      return user;
    } on auth.FirebaseAuthException catch (exception, s) {
      print(exception.toString() + '$s');
      switch ((exception).code) {
        case 'invalid-email':
          return "Email address is malformed.".tr();
        case 'wrong-password':
          return 'Wrong password.'.tr();
        case 'user-not-found':
          return 'No user corresponding to the given email address.'.tr();
        case 'user-disabled':
          return 'This user has been disabled.'.tr();
        case 'too-many-requests':
          return 'Too many attempts to sign in as this user.'.tr();
      }
      return 'Unexpected firebase error, Please try again.'.tr();
    } catch (e, s) {
      print(e.toString() + '$s');
      return 'Login failed, Please try again.'.tr();
    }
  }

  ///submit a phone number to firebase to receive a code verification, will
  ///be used later to login
  static firebaseSubmitPhoneNumber(
    String phoneNumber,
    auth.PhoneCodeAutoRetrievalTimeout? phoneCodeAutoRetrievalTimeout,
    auth.PhoneCodeSent? phoneCodeSent,
    auth.PhoneVerificationFailed? phoneVerificationFailed,
    auth.PhoneVerificationCompleted? phoneVerificationCompleted,
  ) {
    auth.FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(minutes: 2),
      phoneNumber: phoneNumber,
      verificationCompleted: phoneVerificationCompleted!,
      verificationFailed: phoneVerificationFailed!,
      codeSent: phoneCodeSent!,
      codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout!,
    );
  }

  /// submit the received code to firebase to complete the phone number
  /// verification process
  static Future<dynamic> firebaseSubmitPhoneNumberCode(String verificationID, String code, String phoneNumber, {String firstName = 'Anonymous', String lastName = 'User', File? image, String referralCode = ''}) async {
    auth.AuthCredential authCredential = auth.PhoneAuthProvider.credential(verificationId: verificationID, smsCode: code);
    auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithCredential(authCredential);
    User? user = await getCurrentUser(userCredential.user?.uid ?? '');
    if (user != null && user.role == USER_ROLE_CUSTOMER) {
      user.fcmToken = await firebaseMessaging.getToken() ?? '';
      user.role = USER_ROLE_CUSTOMER;
      //user.active = true;
      await updateCurrentUser(user);
      return user;
    } else if (user == null) {
      /// create a new user from phone login
      String profileImageUrl = '';
      if (image != null) {
        profileImageUrl = await uploadUserImageToFireStorage(image, userCredential.user?.uid ?? '');
      }
      User user = User(
        firstName: firstName,
        lastName: lastName,
        fcmToken: await firebaseMessaging.getToken() ?? '',
        phoneNumber: phoneNumber,
        profilePictureURL: profileImageUrl,
        userID: userCredential.user?.uid ?? '',
        role: USER_ROLE_CUSTOMER,
        active: true,
        lastOnlineTimestamp: Timestamp.now(),
        settings: UserSettings(),
        email: '',
      );
      String? errorMessage = await firebaseCreateNewUser(user, referralCode);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t create new user with phone number.';
      }
    }
  }

  static firebaseSignUpWithEmailAndPassword(String emailAddress, String password, File? image, String firstName, String lastName, String mobile, String referralCode) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailAddress, password: password);
      String profilePicUrl = '';
      if (image != null) {
        updateProgress('Uploading image, Please wait...'.tr());
        profilePicUrl = await uploadUserImageToFireStorage(image, result.user?.uid ?? '');
      }
      User user = User(
          email: emailAddress,
          settings: UserSettings(),
          lastOnlineTimestamp: Timestamp.now(),
          active: true,
          phoneNumber: mobile,
          firstName: firstName,
          role: USER_ROLE_CUSTOMER,
          userID: result.user?.uid ?? '',
          lastName: lastName,
          fcmToken: await firebaseMessaging.getToken() ?? '',
          profilePictureURL: profilePicUrl);
      String? errorMessage = await firebaseCreateNewUser(user,referralCode);
      if (errorMessage == null) {
        return user;
      } else {
        return 'Couldn\'t sign up for firebase, Please try again.';
      }
    } on auth.FirebaseAuthException catch (error) {
      print(error.toString() + '${error.stackTrace}');
      String message = 'Couldn\'t sign up';
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Email already in use, Please pick another email!';
          break;
        case 'invalid-email':
          message = 'Enter valid e-mail';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          message = 'Password must be more than 5 characters';
          break;
        case 'too-many-requests':
          message = 'Too many requests, Please try again later.';
          break;
      }
      return message;
    } catch (e) {
      return 'Couldn\'t sign up';
    }
  }

  static Future<auth.UserCredential?> reAuthUser(AuthProviders provider,
      {String? email, String? password, String? smsCode, String? verificationId, AccessToken? accessToken, apple.AuthorizationResult? appleCredential}) async {
    late auth.AuthCredential credential;
    switch (provider) {
      case AuthProviders.PASSWORD:
        credential = auth.EmailAuthProvider.credential(email: email!, password: password!);
        break;
      case AuthProviders.PHONE:
        credential = auth.PhoneAuthProvider.credential(smsCode: smsCode!, verificationId: verificationId!);
        break;
      case AuthProviders.FACEBOOK:
        credential = auth.FacebookAuthProvider.credential(accessToken!.token);
        break;
      case AuthProviders.APPLE:
        credential = auth.OAuthProvider('apple.com').credential(
          accessToken: String.fromCharCodes(appleCredential!.credential?.authorizationCode ?? []),
          idToken: String.fromCharCodes(appleCredential.credential?.identityToken ?? []),
        );
        break;
    }
    return await auth.FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
  }

  static resetPassword(String emailAddress) async => await auth.FirebaseAuth.instance.sendPasswordResetEmail(email: emailAddress);

  static deleteUser() async {
    try {
      // delete user records from CHANNEL_PARTICIPATION table
      // delete user records from REPORTS table
      await firestore.collection(REPORTS).where('source', isEqualTo: MyAppState.currentUser!.userID).get().then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from REPORTS table
      await firestore.collection(REPORTS).where('dest', isEqualTo: MyAppState.currentUser!.userID).get().then((value) async {
        for (var doc in value.docs) {
          await firestore.doc(doc.reference.path).delete();
        }
      });

      // delete user records from users table
      await firestore.collection(USERS).doc(auth.FirebaseAuth.instance.currentUser!.uid).delete();

      // delete user  from firebase auth
      await auth.FirebaseAuth.instance.currentUser!.delete();
    } catch (e, s) {
      print('FireStoreUtils.deleteUser $e $s');
    }
  }

  getBannerUrl() async {
    await firestore.collection(Setting).doc(BANNER).get().then((value) {
      Banner_Url = value['url'];
    });
  }

  getContactUs() async {
    Map<String, dynamic> contactData = {};
    await firestore.collection(Setting).doc(CONTACT_US).get().then((value) {
      contactData = value.data()!;
    });

    return contactData;
  }
}