//
//  AppDelegate.h
//  VsMobile_FullWeb_SettingsView
//
//  Created by admin on 8/8/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "MenuViewController.h"
#import "SettingsView.h"

// GLOBAL VARIABLES json files
extern NSDictionary *APPLICATION_FILE;
extern NSData *FEED_FILE;
// END GLOBAL VARIABLES

extern NSString *APPLICATION_SUPPORT_PATH;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSData *applicationDatas;

// Settings
@property BOOL cacheIsEnabled;
@property BOOL roamingIsEnabled;
@property BOOL roamingSituation;
@property NSInteger *refreshInterval;
@property NSString *refreshDuration;
@property BOOL forceDownloading;
@property BOOL reloadApp;

// Used for checking if downloading is OK (differentiation for setting an appropriate error message)
@property BOOL serverIsOk;
@property BOOL isDownloadedByNetwork;
@property BOOL isDownloadedByFile;

// Used for WebApi : query
@property (strong, nonatomic) NSString *const OS;
@property (strong, nonatomic) NSString *deviceType;

- (void) configureApp;
- (BOOL) testConnection;
- (BOOL) testFastConnection;
- (void) registerDefaultsFromSettingsBundle;
+ (NSNumber *) getSizeOf:(NSString *)path;
+ (NSMutableString *) addFiles:(NSArray *)dependencies;
+ (NSString *)createHTMLwithContent:(NSString *)htmlContent withAppDep:(NSArray *)appDep withPageDep:(NSArray *)pageDep;

@end
