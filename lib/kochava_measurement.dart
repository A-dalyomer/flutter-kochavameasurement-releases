///
///  KochavaMeasurement (Flutter)
///
///  Copyright (c) 2020 - 2024 Kochava, Inc. All rights reserved.
///

///
/// Kochava Measurement SDK
///
/// A lightweight and easy to integrate SDK, providing first-class integration with Kochava’s installation attribution and analytics platform.
///
/// Getting Started: https://support.kochava.com/sdk-integration/flutter-sdk-integration
///
library kochava_measurement;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

///
/// Kochava Measurement Deeplink Result
///
class KochavaMeasurementDeeplink {
  final String destination;
  final Map<String, dynamic> raw;

  /// Constructor
  KochavaMeasurementDeeplink._(
    this.destination,
    this.raw,
  );

  /// Default Value Constructor
  KochavaMeasurementDeeplink.withDefaults()
      : destination = "",
        raw = Map();

  /// From Json Constructor
  factory KochavaMeasurementDeeplink(Map<String, dynamic> json) {
    final String destination = json["destination"];
    final Map<String, dynamic> raw = json["raw"];
    return KochavaMeasurementDeeplink._(destination, raw);
  }
}

///
/// Kochava Measurement Install Attribution Result
///
class KochavaMeasurementInstallAttribution {
  final bool retrieved;
  final Map<String, dynamic> raw;
  final bool attributed;
  final bool firstInstall;

  /// Constructor
  KochavaMeasurementInstallAttribution._(
    this.retrieved,
    this.raw,
    this.attributed,
    this.firstInstall,
  );

  /// Default Value Constructor
  KochavaMeasurementInstallAttribution.withDefaults()
      : retrieved = false,
        raw = Map(),
        attributed = false,
        firstInstall = false;

  /// Json Json Constructor
  factory KochavaMeasurementInstallAttribution(Map<String, dynamic> json) {
    final bool retrieved = json["retrieved"];
    final Map<String, dynamic> raw = json["raw"];
    final bool attributed = json["attributed"];
    final bool firstInstall = json["firstInstall"];
    return KochavaMeasurementInstallAttribution._(
        retrieved, raw, attributed, firstInstall);
  }
}

///
/// Kochava Measurement Init Result
///
class KochavaMeasurementInit {
  final bool consentGdprApplies;

  /// Constructor
  KochavaMeasurementInit._(this.consentGdprApplies);

  /// Default Value Constructor
  KochavaMeasurementInit.withDefaults() : consentGdprApplies = false;

  /// From Json Constructor
  factory KochavaMeasurementInit(Map<String, dynamic> json) {
    final bool consentGdprApplies = json["consentGdprApplies"];
    return KochavaMeasurementInit._(consentGdprApplies);
  }
}

/// Init completed callback handler.
typedef KochavaMeasurementInitCallback = void Function(
    KochavaMeasurementInit init);

/// Log Levels
///
/// Defaults to Info
///
enum KochavaMeasurementLogLevel {
  None,
  Error,
  Warn,
  Info,
  Debug,
  Trace,
}

///
/// Standard Event Types
///
/// For samples and expected usage see: https://support.kochava.com/reference-information/post-install-event-examples/
///
enum KochavaMeasurementEventType {
  Achievement,
  AddToCart,
  AddToWishList,
  CheckoutStart,
  LevelComplete,
  Purchase,
  Rating,
  RegistrationComplete,
  Search,
  TutorialComplete,
  View,
  AdView,
  PushReceived,
  PushOpened,
  ConsentGranted,
  Deeplink,
  AdClick,
  StartTrial,
  Subscribe,
}

///
/// Kochava Measurement Event
///
class KochavaMeasurementEvent {
  final String _eventName;
  final Map<String, dynamic> _eventData = Map();
  String? _iosAppStoreReceiptBase64String;
  String? _androidGooglePlayReceiptData;
  String? _androidGooglePlayReceiptSignature;

  /// Constructor
  KochavaMeasurementEvent.withName(this._eventName);

  /// Event Type Constructor
  factory KochavaMeasurementEvent.withType(
      KochavaMeasurementEventType eventType) {
    switch (eventType) {
      case KochavaMeasurementEventType.Achievement:
        return KochavaMeasurementEvent.withName("Achievement");
      case KochavaMeasurementEventType.AddToCart:
        return KochavaMeasurementEvent.withName("Add to Cart");
      case KochavaMeasurementEventType.AddToWishList:
        return KochavaMeasurementEvent.withName("Add to Wish List");
      case KochavaMeasurementEventType.CheckoutStart:
        return KochavaMeasurementEvent.withName("Checkout Start");
      case KochavaMeasurementEventType.LevelComplete:
        return KochavaMeasurementEvent.withName("Level Complete");
      case KochavaMeasurementEventType.Purchase:
        return KochavaMeasurementEvent.withName("Purchase");
      case KochavaMeasurementEventType.Rating:
        return KochavaMeasurementEvent.withName("Rating");
      case KochavaMeasurementEventType.RegistrationComplete:
        return KochavaMeasurementEvent.withName("Registration Complete");
      case KochavaMeasurementEventType.Search:
        return KochavaMeasurementEvent.withName("Search");
      case KochavaMeasurementEventType.TutorialComplete:
        return KochavaMeasurementEvent.withName("Tutorial Complete");
      case KochavaMeasurementEventType.View:
        return KochavaMeasurementEvent.withName("View");
      case KochavaMeasurementEventType.AdView:
        return KochavaMeasurementEvent.withName("Ad View");
      case KochavaMeasurementEventType.PushReceived:
        return KochavaMeasurementEvent.withName("Push Received");
      case KochavaMeasurementEventType.PushOpened:
        return KochavaMeasurementEvent.withName("Push Opened");
      case KochavaMeasurementEventType.ConsentGranted:
        return KochavaMeasurementEvent.withName("Consent Granted");
      case KochavaMeasurementEventType.Deeplink:
        return KochavaMeasurementEvent.withName("_Deeplink");
      case KochavaMeasurementEventType.AdClick:
        return KochavaMeasurementEvent.withName("Ad Click");
      case KochavaMeasurementEventType.StartTrial:
        return KochavaMeasurementEvent.withName("Start Trial");
      case KochavaMeasurementEventType.Subscribe:
        return KochavaMeasurementEvent.withName("Subscribe");
      default:
        return KochavaMeasurementEvent.withName("");
    }
  }

  /// Send the event.
  void send() {
    KochavaMeasurement.instance.sendEventWithEvent(this);
  }

  /// Set a custom key/value on the event where the type of the value is a string.
  void setCustomStringValue(String key, String value) {
    if (key.isNotEmpty && value.isNotEmpty) {
      _eventData[key] = value;
    }
  }

  /// Set a custom key/value on the event where the type of the value is a boolean.
  void setCustomBoolValue(String key, bool value) {
    if (key.isNotEmpty) {
      _eventData[key] = value;
    }
  }

  /// Set a custom key/value on the event where the type of the value is a number.
  void setCustomNumberValue(String key, num value) {
    if (key.isNotEmpty) {
      _eventData[key] = value;
    }
  }

  /// (Internal) Set a custom key/value on the event where the type of the value is a dictionary.
  void _setCustomDictionaryValue(String key, Map<String, dynamic> value) {
    if (key.isNotEmpty) {
      _eventData[key] = value;
    }
  }

  /// (Android Only) Set the receipt from the Android Google Play Store.
  void setAndroidGooglePlayReceipt(String data, String signature) {
    if (data.isNotEmpty && signature.isNotEmpty) {
      _androidGooglePlayReceiptData = data;
      _androidGooglePlayReceiptSignature = signature;
    }
  }

  /// (iOS Only) Set the receipt from the iOS Apple App Store.
  void setIosAppStoreReceipt(String base64String) {
    if (base64String.isNotEmpty) {
      _iosAppStoreReceiptBase64String = base64String;
    }
  }

  ///
  /// Standard Event Parameters.
  ///
  void setAction(String value) => setCustomStringValue("action", value);
  void setBackground(bool value) => setCustomBoolValue("background", value);
  void setCheckoutAsGuest(String value) =>
      setCustomStringValue("checkout_as_guest", value);
  void setCompleted(bool value) => setCustomBoolValue("completed", value);
  void setContentId(String value) => setCustomStringValue("content_id", value);
  void setContentType(String value) =>
      setCustomStringValue("content_type", value);
  void setCurrency(String value) => setCustomStringValue("currency", value);
  void setDate(String value) => setCustomStringValue("date", value);
  void setDescription(String value) =>
      setCustomStringValue("description", value);
  void setDestination(String value) =>
      setCustomStringValue("destination", value);
  void setDuration(num value) => setCustomNumberValue("duration", value);
  void setEndDate(String value) => setCustomStringValue("end_date", value);
  void setItemAddedFrom(String value) =>
      setCustomStringValue("item_added_from", value);
  void setLevel(String value) => setCustomStringValue("level", value);
  void setMaxRatingValue(num value) =>
      setCustomNumberValue("max_rating_value", value);
  void setName(String value) => setCustomStringValue("name", value);
  void setOrderId(String value) => setCustomStringValue("order_id", value);
  void setOrigin(String value) => setCustomStringValue("origin", value);
  void setPayload(Map<String, dynamic> value) =>
      _setCustomDictionaryValue("payload", value);
  void setPrice(num value) => setCustomNumberValue("price", value);
  void setQuantity(num value) => setCustomNumberValue("quantity", value);
  void setRatingValue(num value) => setCustomNumberValue("rating_value", value);
  void setReceiptId(String value) => setCustomStringValue("receipt_id", value);
  void setReferralFrom(String value) =>
      setCustomStringValue("referral_from", value);
  void setRegistrationMethod(String value) =>
      setCustomStringValue("registration_method", value);
  void setResults(String value) => setCustomStringValue("results", value);
  void setScore(String value) => setCustomStringValue("score", value);
  void setSearchTerm(String value) =>
      setCustomStringValue("search_term", value);
  void setSource(String value) => setCustomStringValue("source", value);
  void setSpatialX(num value) => setCustomNumberValue("spatial_x", value);
  void setSpatialY(num value) => setCustomNumberValue("spatial_y", value);
  void setSpatialZ(num value) => setCustomNumberValue("spatial_z", value);
  void setStartDate(String value) => setCustomStringValue("start_date", value);
  void setSuccess(String value) => setCustomStringValue("success", value);
  void setUri(String value) => setCustomStringValue("uri", value);
  void setUserId(String value) => setCustomStringValue("user_id", value);
  void setUserName(String value) => setCustomStringValue("user_name", value);
  void setValidated(String value) => setCustomStringValue("validated", value);

  ///
  /// Ad LTV Event Parameters
  ///
  void setAdCampaignId(String value) =>
      setCustomStringValue("ad_campaign_id", value);
  void setAdCampaignName(String value) =>
      setCustomStringValue("ad_campaign_name", value);
  void setAdDeviceType(String value) =>
      setCustomStringValue("device_type", value);
  void setAdGroupId(String value) => setCustomStringValue("ad_group_id", value);
  void setAdGroupName(String value) =>
      setCustomStringValue("ad_group_name", value);
  void setAdMediationName(String value) =>
      setCustomStringValue("ad_mediation_name", value);
  void setAdNetworkName(String value) =>
      setCustomStringValue("ad_network_name", value);
  void setAdPlacement(String value) => setCustomStringValue("placement", value);
  void setAdSize(String value) => setCustomStringValue("ad_size", value);
  void setAdType(String value) => setCustomStringValue("ad_type", value);

  /// Return all the event info in the form to pass down to the native layer.
  Map<String, dynamic> getData() {
    return {
      "name": _eventName,
      "data": _eventData,
      "iosAppStoreReceiptBase64String": _iosAppStoreReceiptBase64String,
      "androidGooglePlayReceiptData": _androidGooglePlayReceiptData,
      "androidGooglePlayReceiptSignature": _androidGooglePlayReceiptSignature,
    };
  }
}

///
/// Kochava Measurement SDK
///
class KochavaMeasurement {
  /// Internal Singleton Instance
  static final KochavaMeasurement _instance = KochavaMeasurement._();

  /// Singleton Instance.
  static KochavaMeasurement get instance => _instance;

  /// Internal State
  final MethodChannel _channel = const MethodChannel('kochava_measurement');
  KochavaMeasurementInitCallback? _initCompletedCallback;
  String? _registeredAndroidAppGuid;
  String? _registeredIosAppGuid;
  String? _registeredPartnerName;

  /// Private Constructor
  KochavaMeasurement._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  // Internal handler for method calls (callbacks) from the native layer.
  Future<void> _methodCallHandler(MethodCall call) async {
    try {
      switch (call.method) {
        case "initCompletedCallback":
          Map<String, dynamic> response = json.decode(call.arguments);
          KochavaMeasurementInit init = KochavaMeasurementInit(response);
          _initCompletedCallback?.call(init);
          break;
      }
    } catch (e) {
      _log("Error: _methodCallHandler: $e");
    }
  }

  /// Reserved function, only use if directed to by your Client Success Manager.
  void executeAdvancedInstruction(String name, String value) {
    _invokeChannel(
      "executeAdvancedInstruction",
      {
        "name": name,
        "value": value,
      },
    );
  }

  /// Set the log level. This should be set prior to starting the SDK.
  void setLogLevel(KochavaMeasurementLogLevel logLevel) {
    String logLevelString = "info";
    switch (logLevel) {
      case KochavaMeasurementLogLevel.None:
        logLevelString = "none";
        break;
      case KochavaMeasurementLogLevel.Error:
        logLevelString = "error";
        break;
      case KochavaMeasurementLogLevel.Warn:
        logLevelString = "warn";
        break;
      case KochavaMeasurementLogLevel.Info:
        logLevelString = "info";
        break;
      case KochavaMeasurementLogLevel.Debug:
        logLevelString = "debug";
        break;
      case KochavaMeasurementLogLevel.Trace:
        logLevelString = "trace";
        break;
    }
    _invokeChannel("setLogLevel", logLevelString);
  }

  /// Set the sleep state.
  void setSleep(bool sleep) {
    _invokeChannel(
      "setSleep",
      sleep,
    );
  }

  /// Set if app level advertising tracking should be limited.
  void setAppLimitAdTracking(bool appLimitAdTracking) {
    _invokeChannel(
      "setAppLimitAdTracking",
      appLimitAdTracking,
    );
  }

  /// Register a custom device identifier for install attribution.
  void registerCustomDeviceIdentifier(String name, String? value) {
    _invokeChannel(
      "registerCustomDeviceIdentifier",
      {
        "name": name,
        "value": value,
      },
    );
  }

  /// Register a custom value to be included in SDK payloads.
  void registerCustomStringValue(String name, String? value) {
    _invokeChannel(
      "registerCustomStringValue",
      {
        "name": name,
        "value": value,
      },
    );
  }

  /// Register a custom value to be included in SDK payloads.
  void registerCustomBoolValue(String name, bool? value) {
    _invokeChannel(
      "registerCustomBoolValue",
      {
        "name": name,
        "value": value,
      },
    );
  }

  /// Register a custom value to be included in SDK payloads.
  void registerCustomNumberValue(String name, num? value) {
    _invokeChannel(
      "registerCustomNumberValue",
      {
        "name": name,
        "value": value,
      },
    );
  }

  /// Register an Identity Link that allows linking different identities together in the form of key and value pairs.
  void registerIdentityLink(String name, String value) {
    _invokeChannel(
      "registerIdentityLink",
      {
        "name": name,
        "value": value,
      },
    );
  }

  /// (Android Only) Enable the Instant App feature by setting the instant app guid.
  void enableAndroidInstantApps(String instantAppGuid) {
    _invokeChannel(
      "enableAndroidInstantApps",
      instantAppGuid,
    );
  }

  /// (iOS Only) Enable App Clips by setting the Container App Group Identifier for App Clips data migration.
  void enableIosAppClips(String containerAppGroupIdentifier) {
    _invokeChannel(
      "enableIosAppClips",
      containerAppGroupIdentifier,
    );
  }

  /// (iOS Only) Enable App Tracking Transparency.
  void enableIosAtt() {
    _invokeChannel(
      "enableIosAtt",
    );
  }

  /// (iOS Only) Set the amount of time in seconds to wait for App Tracking Transparency Authorization. Default 30 seconds.
  void setIosAttAuthorizationWaitTime(num waitTime) {
    _invokeChannel(
      "setIosAttAuthorizationWaitTime",
      waitTime,
    );
  }

  /// (iOS Only) Set if the SDK should automatically request App Tracking Transparency Authorization on start. Default true.
  void setIosAttAuthorizationAutoRequest(bool autoRequest) {
    _invokeChannel(
      "setIosAttAuthorizationAutoRequest",
      autoRequest,
    );
  }

  /// Register a privacy profile, creating or overwriting an existing pofile.
  void registerPrivacyProfile(String name, List<String> keys) {
    _invokeChannel(
      "registerPrivacyProfile",
      {
        "name": name,
        "keys": keys,
      },
    );
  }

  /// Enable or disable an existing privacy profile.
  void setPrivacyProfileEnabled(String name, bool enabled) {
    _invokeChannel(
      "setPrivacyProfileEnabled",
      {
        "name": name,
        "enabled": enabled,
      },
    );
  }

  /// Set the init completed callback.
  void setInitCompletedListener(
      KochavaMeasurementInitCallback? initCompletedCallback) {
    _initCompletedCallback = initCompletedCallback;
    _invokeChannel(
      "setInitCompletedListener",
      initCompletedCallback != null,
    );
  }

  /// Set if consent has been explicitly opted in or out by the user.
  void setIntelligentConsentGranted(bool granted) {
    _invokeChannel(
      "setIntelligentConsentGranted",
      granted,
    );
  }

  /// Return if the SDK is currently started.
  Future<bool> getStarted() async {
    try {
      return await _channel.invokeMethod(
        'getStarted',
      );
    } catch (e) {
      _log("Error: getStarted: $e");
      return Future.value(false);
    }
  }

  /// Register the Android App GUID. Do this prior to calling Start.
  void registerAndroidAppGuid(String androidAppGuid) {
    _registeredAndroidAppGuid = androidAppGuid;
  }

  /// Register the iOS App GUID. Do this prior to calling Start.
  void registerIosAppGuid(String iosAppGuid) {
    _registeredIosAppGuid = iosAppGuid;
  }

  /// Register your Partner Name. Do this prior to calling Start.
  ///
  /// NOTE: Only use this method if directed to by your Client Success Manager.
  void registerPartnerName(String partnerName) {
    _registeredPartnerName = partnerName;
  }

  /// Start the SDK with the previously registered App GUID or Partner Name.
  void start() {
    // Version data is updated by script. Do not change.
    final Map<String, String> wrapper = {
      "name": "Flutter",
      "version": "3.2.0",
      "build_date": "2024-07-30T16:19:18Z",
    };
    executeAdvancedInstruction("wrapper", json.encode(wrapper));
    _invokeChannel("start", {
      "androidAppGuid": _registeredAndroidAppGuid,
      "iosAppGuid": _registeredIosAppGuid,
      "partnerName": _registeredPartnerName
    });
  }

  /// Shut down the SDK and optionally delete all local SDK data.
  ///
  /// NOTE: Care should be taken when using this method as deleting the SDK data will make it reset back to a first install state.
  void shutdown(bool deleteData) {
    // Listeners
    _initCompletedCallback = null;
    // Registered values
    _registeredAndroidAppGuid = null;
    _registeredIosAppGuid = null;
    _registeredPartnerName = null;
    // Native
    _invokeChannel("shutdown", deleteData);
  }

  /// Return the Kochava Device ID.
  Future<String> retrieveInstallId() async {
    try {
      return await _channel.invokeMethod(
        'retrieveInstallId',
      );
    } catch (e) {
      _log("Error: retrieveInstallId: $e");
      return Future.value("");
    }
  }

  /// Retrieve install attribution data from the server.
  Future<KochavaMeasurementInstallAttribution>
      retrieveInstallAttribution() async {
    try {
      return Future.value(
        KochavaMeasurementInstallAttribution(
          json.decode(
            await _channel.invokeMethod(
              'retrieveInstallAttribution',
            ),
          ),
        ),
      );
    } catch (e) {
      _log("Error: retrieveInstallAttribution: $e");
      return Future.value(KochavaMeasurementInstallAttribution.withDefaults());
    }
  }

  /// Process a launch deeplink using the default 10 second timeout.
  Future<KochavaMeasurementDeeplink> processDeeplink(String path) async {
    try {
      return Future.value(
        KochavaMeasurementDeeplink(
          json.decode(
            await _channel.invokeMethod(
              'processDeeplink',
              path,
            ),
          ),
        ),
      );
    } catch (e) {
      _log("Error: processDeeplink: $e");
      return Future.value(KochavaMeasurementDeeplink.withDefaults());
    }
  }

  /// Process a launch deeplink using a custom timeout in seconds.
  Future<KochavaMeasurementDeeplink> processDeeplinkWithOverrideTimeout(
      String path, num timeout) async {
    try {
      return Future.value(
        KochavaMeasurementDeeplink(
          json.decode(
            await _channel.invokeMethod(
              'processDeeplinkWithOverrideTimeout',
              {
                "path": path,
                "timeout": timeout,
              },
            ),
          ),
        ),
      );
    } catch (e) {
      _log("Error: processDeeplinkWithOverrideTimeout: $e");
      return Future.value(KochavaMeasurementDeeplink.withDefaults());
    }
  }

  /// Register a deeplink wrapper domain for enhanced deeplink ESP integration
  void registerDeeplinkWrapperDomain(String domain) {
    _invokeChannel("registerDeeplinkWrapperDomain", domain);
  }

  /// Registers a default parameter on every event.
  void registerDefaultEventStringParameter(String name, String? value) {
    _invokeChannel(
      "registerDefaultEventStringParameter",
      {
        "name": name,
        "value": value,
      },
    );
  }

  /// Registers a default parameter on every event.
  void registerDefaultEventBoolParameter(String name, bool? value) {
    _invokeChannel(
      "registerDefaultEventBoolParameter",
      {
        "name": name,
        "value": value,
      },
    );
  }

  /// Registers a default parameter on every event.
  void registerDefaultEventNumberParameter(String name, num? value) {
    _invokeChannel(
      "registerDefaultEventNumberParameter",
      {
        "name": name,
        "value": value,
      },
    );
  }

  /// Registers a default user_id value on every event.
  void registerDefaultEventUserId(String? value) {
    _invokeChannel(
      "registerDefaultEventUserId",
      value,
    );
  }

  /// Send an event.
  void sendEvent(String name) {
    _invokeChannel(
      "sendEvent",
      name,
    );
  }

  /// Send an event with string data.
  void sendEventWithString(String name, String data) {
    _invokeChannel(
      "sendEventWithString",
      {
        "name": name,
        "data": data,
      },
    );
  }

  /// Send an event with dictionary data.
  void sendEventWithDictionary(String name, Map<String, dynamic> data) {
    _invokeChannel(
      "sendEventWithDictionary",
      {
        "name": name,
        "data": data,
      },
    );
  }

  /// (Internal) Send an event object (Called via Event.send()).
  void sendEventWithEvent(KochavaMeasurementEvent event) {
    _invokeChannel(
      "sendEventWithEvent",
      event.getData(),
    );
  }

  /// Build and return an event using a Standard Event Type.
  KochavaMeasurementEvent buildEventWithEventType(
    KochavaMeasurementEventType eventType,
  ) {
    return KochavaMeasurementEvent.withType(eventType);
  }

  /// Build and return an event using a custom name.
  KochavaMeasurementEvent buildEventWithEventName(String eventName) {
    return KochavaMeasurementEvent.withName(eventName);
  }

  /// (Internal) Call the native layer method with the given arguments.
  void _invokeChannel(String method, [dynamic args]) {
    try {
      _channel.invokeMethod(method, args);
    } catch (e) {
      _log("Error: " + method + ": $e");
    }
  }

  /// (Internal) Logger
  void _log(String message) {
    print("KVA/Measurement: " + message);
  }
}
