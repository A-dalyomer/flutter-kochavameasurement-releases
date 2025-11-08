//
//  KochavaMeasurement (Flutter)
//
//  Copyright (c) 2020 - 2024 Kochava, Inc. All rights reserved.
//

#pragma mark - Import

#import <Flutter/Flutter.h>
#import <KochavaNetworking/KochavaNetworking.h>
#import <KochavaMeasurement/KochavaMeasurement.h>

#pragma mark - Interface
@interface KochavaMeasurementPlugin : NSObject<FlutterPlugin>

#pragma mark - Methods

// Method channel property for native to dart communication.
@property (strong, nonatomic) FlutterMethodChannel *channel;

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;

@end
