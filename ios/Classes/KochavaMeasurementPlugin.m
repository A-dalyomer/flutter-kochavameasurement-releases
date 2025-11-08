//
//  KochavaMeasurement (Flutter)
//
//  Copyright (c) 2020 - 2024 Kochava, Inc. All rights reserved.
//

#pragma mark - Import

#import "KochavaMeasurementPlugin.h"

#pragma mark - Util

// Interface for the kochavaMeasurementUtil
@interface KochavaMeasurementUtil : NSObject

@end

// Common utility functions used by all of the wrappers.
// Any changes to the methods in here must be propagated to the other wrappers.
@implementation KochavaMeasurementUtil

// Log a message to the console.
+ (void)log:(nonnull NSString *)message {
    NSLog(@"KVA/Measurement: %@", message);
}

// Attempts to read an NSDictionary and returns nil if not one.
+ (nullable NSDictionary *)readNSDictionary:(nullable id)valueId {
    return [[NSDictionary class] performSelector:@selector(kva_from:) withObject:valueId];
}

// Attempts to read an NSArray and returns nil if not one.
+ (nullable NSArray *)readNSArray:(nullable id)valueId {
    return [[NSArray class] performSelector:@selector(kva_from:) withObject:valueId];
}

// Attempts to read an NSNumber and returns nil if not one.
+ (nullable NSNumber *)readNSNumber:(nullable id)valueId {
    return [[NSNumber class] performSelector:@selector(kva_from:) withObject:valueId];
}

// Attempts to read an NSString and returns nil if not one.
+ (nullable NSString *)readNSString:(nullable id)valueId {
    return [NSString kva_from:valueId];
}

// Attempts to read an NSObject and returns nil if not one.
+ (nullable NSObject *)readNSObject:(nullable id)valueId {
    return [valueId isKindOfClass:NSNull.self] ? nil : valueId;
}

// Converts an NSNumber to a double with fallback to a default value.
+ (double)convertNumberToDouble:(nullable NSNumber *)number defaultValue:(double)defaultValue {
    if(number != nil) {
        return [number doubleValue];
    }
    return defaultValue;
}

// Converts an NSNumber to a bool with fallback to a default value.
+ (BOOL)convertNumberToBool:(nullable NSNumber *)number defaultValue:(BOOL)defaultValue {
    if(number != nil) {
        return [number boolValue];
    }
    return defaultValue;
}

// Converts the deeplink result into an NSDictionary.
+ (nonnull NSDictionary *)convertDeeplinkToDictionary:(nonnull KVADeeplink *)deeplink {
    NSObject *object = [deeplink kva_toContext:KVAContext.host];
    return [object isKindOfClass:NSDictionary.class] ? (NSDictionary *)object : @{};
}

// Converts the install attribution result into an NSDictionary.
+ (nonnull NSDictionary *)convertInstallAttributionToDictionary:(nonnull KVAMeasurement_Attribution_Result *)installAttribution {
    if (KVAMeasurement.shared.startedBool) {
        NSObject *object = [installAttribution kva_toContext:KVAContext.host];
        return [object isKindOfClass:NSDictionary.class] ? (NSDictionary *)object : @{};
    } else {
        return @{
                @"retrieved": @(NO),
                @"raw": @{},
                @"attributed": @(NO),
                @"firstInstall": @(NO),
        };
    }
}

// Converts the config result into an NSDictionary.
+ (nonnull NSDictionary *)convertConfigToDictionary:(nonnull KVANetworking_Config *)config {
    return @{
            @"consentGdprApplies": @(config.consentGDPRAppliesBool),
    };
}

// Serialize an NSDictionary into a json serialized NSString.
+ (nullable NSString *)serializeJsonObject:(nullable NSDictionary *)dictionary {
    return [NSString kva_stringFromJSONObject:dictionary prettyPrintBool:NO];
}

// Parse a json serialized NSString into an NSArray.
+ (nullable NSArray *)parseJsonArray:(nullable NSString *)string {
    NSObject *object = [string kva_serializedJSONObjectWithPrintErrorsBool:YES];
    return ([object isKindOfClass:NSArray.class] ? (NSArray *) object : nil);
}

// Parse a json serialized NSString into an NSDictionary.
+ (nullable NSDictionary *)parseJsonObject:(nullable NSString *)string {
    NSObject *object = [string kva_serializedJSONObjectWithPrintErrorsBool:YES];
    return [object isKindOfClass:NSDictionary.class] ? (NSDictionary *) object : nil;
}

// Parse a NSString into a NSURL and logs a warning on failure.
+ (nullable NSURL *)parseNSURL:(nullable NSString *)string {
    NSURL *url = [NSURL URLWithString:string];
    if (url == nil && string.length > 0) {
        [KochavaMeasurementUtil log:@"Warn: parseNSURL invalid input, not a valid URL"];
    }
    return url;
}

// Builds and sends an event given an event info dictionary.
+ (void)buildAndSendEvent:(nullable NSDictionary *)eventInfo {
    if(eventInfo == nil) {
        return;
    }
    NSString *name = [KochavaMeasurementUtil readNSString:eventInfo[@"name"]];
    NSDictionary *data = [KochavaMeasurementUtil readNSDictionary:eventInfo[@"data"]];
    NSString *iosAppStoreReceiptBase64String = [KochavaMeasurementUtil readNSString:eventInfo[@"iosAppStoreReceiptBase64String"]];
    if (name.length > 0) {
        KVAEvent *event = [[KVAEvent alloc] initCustomWithEventName:name];
        if (data != nil) {
            event.infoDictionary = data;
        }
        if (iosAppStoreReceiptBase64String.length > 0) {
            event.appStoreReceiptBase64EncodedString = iosAppStoreReceiptBase64String;
        }
        [event send];
    } else {
        [KochavaMeasurementUtil log:@"Warn: sendEventWithEvent invalid input"];
    }
}

@end

#pragma mark - Methods

@implementation KochavaMeasurementPlugin

// Set the logging parameters before any other access to the SDK.
+ (void) initialize {
    KVALog.shared.osLogEnabledBool = false;
    KVALog.shared.printLinesIndividuallyBool = true;
}

// Register plugin with Flutter.
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"kochava_measurement" binaryMessenger:[registrar messenger]];
    KochavaMeasurementPlugin *instance = [[KochavaMeasurementPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

// Initialize the plugin with the method channel to communicate with Dart.
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
    }
    return self;
}

// Handle a method call from the Dart layer.
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {

    // void executeAdvancedInstruction(string name, string value)
    if ([@"executeAdvancedInstruction" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSString *value = [KochavaMeasurementUtil readNSString:valueDictionary[@"value"]];
        
        [KVAMeasurement.shared.networking executeAdvancedInstructionWithUniversalIdentifier:name parameter:value prerequisiteTaskIdentifierArray:nil];
        result(@"success");

    // void setLogLevel(LogLevel logLevel)
    } else if ([@"setLogLevel" isEqualToString:call.method]) {
        NSString *logLevel = [KochavaMeasurementUtil readNSString:call.arguments];
        
        KVALog.shared.level = [KVALog_Level from:logLevel];
        result(@"success");

    // void setSleep(bool sleep)
    } else if ([@"setSleep" isEqualToString:call.method]) {
        BOOL sleep = [KochavaMeasurementUtil convertNumberToBool:[KochavaMeasurementUtil readNSNumber:call.arguments] defaultValue:false];
        
        KVAMeasurement.shared.sleepBool = sleep;
        result(@"success");

    // void setAppLimitAdTracking(bool appLimitAdTracking)
    } else if ([@"setAppLimitAdTracking" isEqualToString:call.method]) {
        BOOL appLimitAdTracking = [KochavaMeasurementUtil convertNumberToBool:[KochavaMeasurementUtil readNSNumber:call.arguments] defaultValue:false];
        KVAMeasurement.shared.appLimitAdTracking.boolean = appLimitAdTracking;
        result(@"success");

    // void registerCustomDeviceIdentifier(string name, string value)
    } else if ([@"registerCustomDeviceIdentifier" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSString *value = [KochavaMeasurementUtil readNSString:valueDictionary[@"value"]];
        
        [KVACustomIdentifier registerWithName:name identifier:value];
        result(@"success");

    // void registerCustomStringValue(string, string value)
    } else if ([@"registerCustomStringValue" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSString *value = [KochavaMeasurementUtil readNSString:valueDictionary[@"value"]];
        
        [KVACustomValue registerWithName:name value:value];
        result(@"success");

    // void registerCustomBoolValue(string, bool value)
    } else if ([@"registerCustomBoolValue" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSNumber *value = [KochavaMeasurementUtil readNSNumber:valueDictionary[@"value"]];
        
        [KVACustomValue registerWithName:name value:value];
        result(@"success");

    // void registerCustomNumberValue(string, number value)
    } else if ([@"registerCustomNumberValue" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSNumber *value = [KochavaMeasurementUtil readNSNumber:valueDictionary[@"value"]];
        
        [KVACustomValue registerWithName:name value:value];
        result(@"success");

    // void registerIdentityLink(string name, string value)
    } else if ([@"registerIdentityLink" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSString *value = [KochavaMeasurementUtil readNSString:valueDictionary[@"value"]];

        [KVAIdentityLink registerWithName:name identifier:value];
        result(@"success");

    // void enableAndroidInstantApps(string instantAppGuid)
    } else if ([@"enableAndroidInstantApps" isEqualToString:call.method]) {
        [KochavaMeasurementUtil log:@"enableAndroidInstantApps API is not available on this platform."];
        result(@"success");

    // void enableIosAppClips(string identifier)
    } else if ([@"enableIosAppClips" isEqualToString:call.method]) {
        NSString *identifier = [KochavaMeasurementUtil readNSString:call.arguments];
        
        KVAAppGroups.shared.generalAppGroupIdentifier = identifier;
        result(@"success");

    // void enableIosAtt()
    } else if ([@"enableIosAtt" isEqualToString:call.method]) {
        KVAMeasurement.shared.appTrackingTransparency.enabledBool = true;
        result(@"success");

    // void setIosAttAuthorizationWaitTime(double waitTime)
    } else if ([@"setIosAttAuthorizationWaitTime" isEqualToString:call.method]) {
        double waitTime = [KochavaMeasurementUtil convertNumberToDouble:[KochavaMeasurementUtil readNSNumber:call.arguments] defaultValue:30.0];
        
        KVAMeasurement.shared.appTrackingTransparency.authorizationStatusWaitTimeInterval = waitTime;
        result(@"success");

    // void setIosAttAuthorizationAutoRequest(bool autoRequest)
    } else if ([@"setIosAttAuthorizationAutoRequest" isEqualToString:call.method]) {
        BOOL autoRequest = [KochavaMeasurementUtil convertNumberToBool:[KochavaMeasurementUtil readNSNumber:call.arguments] defaultValue:true];
        
        KVAMeasurement.shared.appTrackingTransparency.autoRequestTrackingAuthorizationBool = autoRequest;
        result(@"success");

    // void registerPrivacyProfile(string name, string[] keys)
    } else if ([@"registerPrivacyProfile" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSArray *keys = [KochavaMeasurementUtil readNSArray:valueDictionary[@"keys"]];

        [KVAPrivacyProfile registerWithName:name datapointKeyArray:keys];
        result(@"success");

    // void setPrivacyProfileEnabled(string name, bool enabled)
    } else if ([@"setPrivacyProfileEnabled" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        BOOL enabled = [KochavaMeasurementUtil convertNumberToBool:[KochavaMeasurementUtil readNSNumber:valueDictionary[@"enabled"]] defaultValue:false];

        [KVAMeasurement.shared.privacy setEnabledBoolForProfileName:name enabledBool:enabled];
        result(@"success");

    // void setInitCompletedListener(bool setListener)
    } else if ([@"setInitCompletedListener" isEqualToString:call.method]) {
        BOOL setListener = [KochavaMeasurementUtil convertNumberToBool:[KochavaMeasurementUtil readNSNumber:call.arguments] defaultValue:true];

        if(setListener) {
            KVAMeasurement.shared.config.closure_didComplete = ^(KVANetworking_Config * _Nonnull config)
            {
                NSDictionary *configDictionary = [KochavaMeasurementUtil convertConfigToDictionary:config];
                NSString *configString = [KochavaMeasurementUtil serializeJsonObject:configDictionary] ?: @"{}";
                [self.channel invokeMethod:@"initCompletedCallback" arguments:configString];
            };
        } else {
            KVAMeasurement.shared.config.closure_didComplete = nil;
        }
        result(@"success");

    // void setIntelligentConsentGranted(bool granted)
    } else if ([@"setIntelligentConsentGranted" isEqualToString:call.method]) {
        NSNumber *granted = [KochavaMeasurementUtil readNSNumber:call.arguments];

        KVAMeasurement.shared.privacy.intelligentConsent.grantedBoolNumber = granted;
        result(@"success");

    // bool getStarted()
    } else if ([@"getStarted" isEqualToString:call.method]) {
        result(@(KVAMeasurement.shared.startedBool));

    // void start(string androidAppGuid, string iosAppGuid, string partnerName)
    } else if ([@"start" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *iosAppGuid = [KochavaMeasurementUtil readNSString:valueDictionary[@"iosAppGuid"]];
        NSString *partnerName = [KochavaMeasurementUtil readNSString:valueDictionary[@"partnerName"]];

        if(iosAppGuid.length > 0) {
            [KVAMeasurement.shared startWithAppGUIDString:iosAppGuid];
        } else if(partnerName.length > 0) {
            [KVAMeasurement.shared startWithPartnerNameString:partnerName];
        } else {
            // Allow the native to log the error of no app guid.
            [KVAMeasurement.shared startWithAppGUIDString:nil];
        }

        result(@"success");

    // void shutdown(bool deleteData)
    } else if ([@"shutdown" isEqualToString:call.method]) {
        BOOL deleteData = [KochavaMeasurementUtil convertNumberToBool:[KochavaMeasurementUtil readNSNumber:call.arguments] defaultValue:false];

        [KochavaMeasurement_Product.shared shutdownWithDeleteLocalDataBool:deleteData];
        result(@"success");

    // string retrieveInstallId()
    } else if ([@"retrieveInstallId" isEqualToString:call.method]) {
        if(KVAMeasurement.shared.startedBool) {
            result(KVAMeasurement.shared.installIdentifier.string ?: @"");
        } else {
            result(@"");
        }

    // InstallAttribution retrieveInstallAttribution()
    } else if ([@"retrieveInstallAttribution" isEqualToString:call.method]) {
        [KVAMeasurement.shared.attribution retrieveResultWithClosure_didComplete:^(KVAMeasurement_Attribution_Result * attribution) {
            NSDictionary *attributionDictionary = [KochavaMeasurementUtil convertInstallAttributionToDictionary:attribution];
            NSString *attributionString = [KochavaMeasurementUtil serializeJsonObject:attributionDictionary] ?: @"";
            result(attributionString);
        }];

    // void processDeeplink(string path, Callback<Deeplink> callback)
    } else if ([@"processDeeplink" isEqualToString:call.method]) {
        NSURL *path = [KochavaMeasurementUtil parseNSURL:call.arguments ?: @""];
        
        [KVADeeplink processWithURL:path closure_didComplete:^(KVADeeplink *_Nonnull deeplink) {
            NSDictionary *deeplinkDictionary = [KochavaMeasurementUtil convertDeeplinkToDictionary:deeplink];
            NSString *deeplinkString = [KochavaMeasurementUtil serializeJsonObject:deeplinkDictionary] ?: @"";
            result(deeplinkString);
        }];

    // void processDeeplinkWithOverrideTimeout(string path, double timeout, Callback<Deeplink> callback)
    } else if ([@"processDeeplinkWithOverrideTimeout" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSURL *path = [KochavaMeasurementUtil parseNSURL:[KochavaMeasurementUtil readNSString:valueDictionary[@"path"]]];
        double timeout = [KochavaMeasurementUtil convertNumberToDouble:[KochavaMeasurementUtil readNSNumber:valueDictionary[@"timeout"]] defaultValue:10.0];
        
        [KVADeeplink processWithURL:path timeoutTimeInterval:timeout closure_didComplete:^(KVADeeplink *_Nonnull deeplink) {
            NSDictionary *deeplinkDictionary = [KochavaMeasurementUtil convertDeeplinkToDictionary:deeplink];
            NSString *deeplinkString = [KochavaMeasurementUtil serializeJsonObject:deeplinkDictionary] ?: @"";
            result(deeplinkString);
        }];

    // void registerDeeplinkWrapperDomain(string)
    }else if ([@"registerDeeplinkWrapperDomain" isEqualToString:call.method]) {
        NSString *domain = [KochavaMeasurementUtil readNSString:call.arguments];

        [KVADeeplink_Wrapper registerWithDomain:domain];

    // void registerDefaultEventStringParameter(string, string value)
    } else if ([@"registerDefaultEventStringParameter" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSString *value = [KochavaMeasurementUtil readNSString:valueDictionary[@"value"]];
        
        [KVAEvent_DefaultParameter registerWithName:name value:value];
        result(@"success");

    // void registerDefaultEventBoolParameter(string, bool value)
    } else if ([@"registerDefaultEventBoolParameter" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSNumber *value = [KochavaMeasurementUtil readNSNumber:valueDictionary[@"value"]];
        
        [KVAEvent_DefaultParameter registerWithName:name value:value];
        result(@"success");

    // void registerDefaultEventNumberParameter(string, number value)
    } else if ([@"registerDefaultEventNumberParameter" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSNumber *value = [KochavaMeasurementUtil readNSNumber:valueDictionary[@"value"]];
        
        [KVAEvent_DefaultParameter registerWithName:name value:value];
        result(@"success");

    // void registerDefaultEventUserId(string value)
    } else if ([@"registerDefaultEventUserId" isEqualToString:call.method]) {
        NSString *value = [KochavaMeasurementUtil readNSString:call.arguments];

        [KVAEvent_DefaultParameter registerWithUserIdString:value];
        result(@"success");

    // void sendEvent(string name)
    } else if ([@"sendEvent" isEqualToString:call.method]) {
        NSString *name = [KochavaMeasurementUtil readNSString:call.arguments];
        
        if (name.length > 0) {
            [KVAEvent sendCustomWithEventName:name];
        } else {
            [KochavaMeasurementUtil log:@"Warn: sendEvent invalid input"];
        }
        result(@"success");

    // void sendEventWithString(string name, string data)
    } else if ([@"sendEventWithString" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSString *data = [KochavaMeasurementUtil readNSString:valueDictionary[@"data"]];
        
        if (name.length > 0) {
            [KVAEvent sendCustomWithEventName:name infoString:data];
        } else {
            [KochavaMeasurementUtil log:@"Warn: sendEventWithString invalid input"];
        }
        result(@"success");

    // void sendEventWithDictionary(string name, object data)
    } else if ([@"sendEventWithDictionary" isEqualToString:call.method]) {
        NSDictionary *valueDictionary = [KochavaMeasurementUtil readNSDictionary:call.arguments] ?: @{};
        NSString *name = [KochavaMeasurementUtil readNSString:valueDictionary[@"name"]];
        NSDictionary *data = [KochavaMeasurementUtil readNSDictionary:valueDictionary[@"data"]];
        
        if (name.length > 0) {
            [KVAEvent sendCustomWithEventName:name infoDictionary:data];
        } else {
            [KochavaMeasurementUtil log:@"Warn: sendEventWithString invalid input"];
        }
        result(@"success");

    // void sendEventWithEvent(Event event)
    } else if ([@"sendEventWithEvent" isEqualToString:call.method]) {
        NSDictionary *eventInfo = [KochavaMeasurementUtil readNSDictionary:call.arguments];
        [KochavaMeasurementUtil buildAndSendEvent:eventInfo];
        result(@"success");

    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end

