//
//  AppDelegate.m
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"

NSDictionary *APPLICATION_FILE;
NSData *FEED_FILE;
NSString *APPLICATION_SUPPORT_PATH;
BOOL autoRefresh;
BOOL forceDownloading;
BOOL reloadApp;
BOOL cacheIsEnabled;
BOOL roamingIsEnabled;

// INFO : not manually throw exception here => cannot display alert view before shut down the application. More user friendly.

@implementation AppDelegate

- (BOOL) testConnection
{
    // Set the host
    Reachability *checkConnection = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [checkConnection currentReachabilityStatus];
    
    
    BOOL isConnected = false;
    switch (networkStatus) {
        case NotReachable:
            //NSLog(@"Network Status : NotReachable");
            isConnected = false;
            break;
        case ReachableViaWiFi:
            //NSLog(@"Network Status : ReachableViaWiFi");
            isConnected = true;
            break;
        case ReachableViaWWAN:
            //NSLog(@"Network Status : ReachableViaWWAN");
            isConnected = [self testFastConnection];
            break;
        default:
            break;
    }
    
    /*checkConnection = [Reachability reachabilityWithHostName:@"testapp"];
     networkStatus = [checkConnection currentReachabilityStatus];
     if (networkStatus != 0) {
     self.serverIsOk = true;
     }
     NSLog(@"Server responsive : %hhd", self.serverIsOk); */
    
    return isConnected;
}

- (BOOL) testFastConnection
{
    BOOL isFast = false;
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    if ([info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
        isFast = false;
    }
    else {
        isFast = true;
    }
    NSLog(@"Test fast connexion : %hhd", isFast);
    return isFast;
}

- (void) getSettings
{
    // If key exists, get its value else set a default value
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cache"]) {
        cacheIsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"cache"];
    } else {
        cacheIsEnabled = false;
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"roaming"]) {
        roamingIsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"roaming"];
    } else {
        roamingIsEnabled = true;
    }
    // Check if user can be in Roaming mode
    NSString *carrierPlist = @"/var/mobile/Library/Preferences/com.apple.carrier.plist";
    NSString *operatorPlist = @"/var/mobile/Library/Preferences/com.apple.operator.plist";
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    NSString *carrierPlistPath = [fm destinationOfSymbolicLinkAtPath:carrierPlist error:&err];
    NSString *operatorPlistPath = [fm destinationOfSymbolicLinkAtPath:operatorPlist error:&err];
    
    int carrier = [carrierPlistPath rangeOfString:@"Carrier"].location;
    int operator = [operatorPlistPath rangeOfString:@"Carrier"].location;
    carrierPlistPath = [carrierPlistPath substringFromIndex:carrier];
    operatorPlistPath = [operatorPlistPath substringFromIndex:operator];
    
    NSComparisonResult result = [carrierPlistPath compare:operatorPlistPath];
    
    if (result == NSOrderedSame) {
        self.roamingSituation = NO;
    } else {
        self.roamingSituation = YES;
    }
    
    @synchronized(self) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"]) {
            // Check if change
            if (self.refreshInterval != [NSNumber numberWithInt:[[NSUserDefaults standardUserDefaults] integerForKey:@"intervalChoice"]]
                || self.refreshDuration != [[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"]) {
                self.refreshInterval = [NSNumber numberWithInt:[[NSUserDefaults standardUserDefaults] integerForKey:@"intervalChoice"]];
                self.refreshDuration = [[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"];
            }
        } else {
            self.refreshInterval = [NSNumber numberWithInt:1];
            self.refreshDuration = @"jour";
            
            [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.refreshInterval forKey:@"intervalChoice"]];
            [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.refreshDuration forKey:@"durationChoice"]];
        }
    }
}

+ (NSNumber *) getSizeOf:(NSString *)path
{
    // TODO : check dossier images (à soustraire du poids des datas)
    // NSFileSize works only with file
    NSNumber *number;
    unsigned long long ull = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    NSArray *directories = [fm contentsOfDirectoryAtPath:path error:&err];
    for (NSString *file in directories) {
        //NSLog(@"File : %@", file);
        NSDictionary *attributes = [fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@%@",path, file] error:&err];
        ull += [attributes fileSize];
        
        // Check if subdirectories
        if ([[attributes fileType] isEqualToString:NSFileTypeDirectory]) {
            NSArray *subdir = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",path, file] error:&err];
            for (NSString *subFiles in subdir) {
                NSDictionary *attributes = [fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@%@/%@",path, file, subFiles] error:&err];
                ull += [attributes fileSize];
                // Check if sub-subdirectories
                
                if ([[attributes fileType] isEqualToString:NSFileTypeDirectory]) {
                    NSArray *subSubdir = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@",path, file, subFiles] error:&err];
                    for (NSString *subSubFiles in subSubdir) {
                        NSDictionary *attributes = [fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@%@/%@/%@",path, file, subFiles, subSubFiles] error:&err];
                        ull += [attributes fileSize];
                    }
                }
            }
        }
    }
    // 1 ko = 1024 bytes
    ull = ull / 1024;
    number = [NSNumber numberWithUnsignedLongLong:ull];
    return number;
}

- (void) saveFile:(NSString *)url fileName:(NSString *)fileName dirName:(NSString*)dirName
{
    @try {
        if (![url isKindOfClass:[NSNull class]] && ![fileName isKindOfClass:[NSNull class]]) {
            url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            BOOL success = false;
            NSString *path = [NSString stringWithFormat:@"%@%@", APPLICATION_SUPPORT_PATH, fileName];
            
            // Create Template's page directory when dependency is for a page
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error = [[NSError alloc] init];
            
            if (![dirName isKindOfClass:[NSNull class]]) {
                dirName = [dirName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                BOOL isDirectory;
                // Manipulate dirName for creating directories
                NSString *search = @"/";
                NSRange getDir = [dirName rangeOfString:search];
                if (getDir.location != NSNotFound) {
                    // Several directories
                    NSString *firstDir = [dirName substringToIndex:getDir.location];
                    NSString *sndDir = [dirName substringFromIndex:getDir.location];
                    if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@%@", APPLICATION_SUPPORT_PATH, firstDir] isDirectory:&isDirectory] || forceDownloading || autoRefresh) {
                        success = [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@%@", APPLICATION_SUPPORT_PATH, firstDir] withIntermediateDirectories:YES attributes:nil error:&error];
                        if (!success) {
                            NSLog(@"An error occured during the Creation of Template folder : %@", error);
                        }
                    } else if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@%@%@", APPLICATION_SUPPORT_PATH, firstDir, sndDir] isDirectory:&isDirectory] || forceDownloading || autoRefresh) {
                        success = [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@%@%@", APPLICATION_SUPPORT_PATH, firstDir, sndDir] withIntermediateDirectories:YES attributes:nil error:&error];
                        if (!success) {
                            NSLog(@"An error occured during the Creation of Template folder : %@", error);
                        }
                    }
                    path = [NSString stringWithFormat:@"%@%@%@/%@", APPLICATION_SUPPORT_PATH, firstDir, sndDir, fileName];
                } else {
                    // Only one directory
                    path = [NSString stringWithFormat:@"%@%@/%@", APPLICATION_SUPPORT_PATH, dirName, fileName];
                    if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@%@", APPLICATION_SUPPORT_PATH, dirName] isDirectory:&isDirectory] || forceDownloading || autoRefresh) {
                        success = [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@%@", APPLICATION_SUPPORT_PATH, dirName] withIntermediateDirectories:YES attributes:nil error:&error];
                        if (!success) {
                            NSLog(@"An error occured during the Creation of Template folder : %@", error);
                        }
                    }
                }
            }
            // Download file if necessary
            NSURL *location = [NSURL URLWithString:url];
            if (![fileManager fileExistsAtPath:path] || forceDownloading || autoRefresh) {
                if (!cacheIsEnabled) {
                    // Check if user is currently in Roaming Case
                    if (self.roamingSituation) {
                        
                        // Check if user enable Roaming for our app
                        if (roamingIsEnabled) {
                            
                            success = [self testConnection];
                            if (success) {
                                //NSLog(@"[SaveFile] Connection is OK");
                                success =[[NSData dataWithContentsOfURL:location] writeToFile:path options:NSDataWritingAtomic error:&error];
                                if (!success) {
                                    NSLog(@"An error occured during the Saving of the file %@ : %@", fileName, error);
                                    _isDownloadedByNetwork = false;
                                } else {
                                    _isDownloadedByNetwork = true;
                                }
                            }
                        }
                        // User is in Roaming case but disable it => Do not download
                    } else {
                        // User is not in Roaming case => Download
                        success = [self testConnection];
                        if (success) {
                            //NSLog(@"[SaveFile] Connection is OK");
                            success =[[NSData dataWithContentsOfURL:location] writeToFile:path options:NSDataWritingAtomic error:&error];
                            if (!success) {
                                NSLog(@"An error occured during the Saving of the file %@ : %@", fileName, error);
                                _isDownloadedByNetwork = false;
                            } else {
                                _isDownloadedByNetwork = true;
                            }
                        }
                    }
                }
            } else {
                _isDownloadedByFile = true;
            }
        }
    }
    @catch (NSException *e) {
        NSLog(@"An error occured during the Loading of the file %@ : %@, reason : %@", fileName, e.name, e.reason);
        UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(suspend)];
        // Wait while app is going background
        [NSThread sleepForTimeInterval:2.0];
        exit(0);
    }
}

- (void) searchDependencies
{
    if ([APPLICATION_FILE objectForKey:@"Dependencies"] != [NSNull null]) {
        for (NSMutableDictionary *allAppDep in [APPLICATION_FILE objectForKey:@"Dependencies"]) {
            if ([allAppDep objectForKey:@"Url"] != [NSNull null] && [allAppDep objectForKey:@"Name"] != [NSNull null]) {
                [self saveFile:[allAppDep objectForKey:@"Url"] fileName:[allAppDep objectForKey:@"Name"] dirName:[allAppDep objectForKey:@"Path"]];
            }
            else {
                NSLog(@"An error occured during the Search of Application's dependencies. For %@ : one or more parameters are null !", [allAppDep objectForKey:@"Name"]);
            }
        }
    }
    if ([APPLICATION_FILE objectForKey:@"Pages"] != [NSNull null]) {
        for (NSMutableDictionary *allPages in [APPLICATION_FILE objectForKey:@"Pages"]) {
            for (NSMutableDictionary *allPageDep in [allPages objectForKey:@"Dependencies"]) {
                if ([allPageDep objectForKey:@"Url"] != [NSNull null] && [allPageDep objectForKey:@"Name"] != [NSNull null]) {
                    [self saveFile:[allPageDep objectForKey:@"Url"] fileName:[allPageDep objectForKey:@"Name"]dirName:[allPageDep objectForKey:@"Path"]];
                }
                else {
                    NSLog(@"An error occured during the Search of %@'s dependencies : one or more parameters are null !", [allPages objectForKey:@"Name"]);
                }
            }
            if ([allPages objectForKey:@"LogoUrl"] != [NSNull null]) {
                for (NSMutableDictionary *allPageImages in [allPages objectForKey:@"LogoUrl"]) {
                    // Loading images
                    [self saveFile:[allPageImages objectForKey:@"LogoUrl"] fileName:[allPages objectForKey:@"Name"] dirName:@"Images"];
                }
            }
        }
    }
}

- (void) configureApp
{
    @synchronized(self) {
        self.downloadIsFinished = NO;
#pragma Create the Application Support Folder. Not accessible by users
        // NSHomeDirectory returns the application's sandbox directory. Application Support folder will contain all files that we need for the application
        APPLICATION_SUPPORT_PATH = [NSString stringWithFormat:@"%@/Library/Application Support/", NSHomeDirectory()];
        NSLog(@"APPLICATION_SUPPORT_PATH = %@", APPLICATION_SUPPORT_PATH);
        
        // Application Support folder is not always created by default. The following code creates it.
        // Get the Bundle identifier for creating dynamic path for storing all files
        NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
        // FileManager is using for creating the Application Support Folder
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = [[NSError alloc] init];
        NSURL *appliSupportDir = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
        if (appliSupportDir != nil) {
            [appliSupportDir URLByAppendingPathComponent:bundle isDirectory:YES];
        }
        else {
            NSLog(@"An error occured during the Creation of Application Support folder : %@", error);
        }
        
        [self getSettings];
        
        bundle = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
        NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:bundle];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.deviceType = @"Tablet";
        } else {
            self.deviceType = @"Mobile";
        }
        self.OS = @"IOS";
        
#pragma Download & save Json Files
        // Read Json file in network
        @try {
            BOOL success = false;
            // Get Application File
            // Get config file
            //NSString *query = [NSString stringWithFormat:@"?key1=%@&key2=%@", self.OS, self.deviceType];
            //NSString *webApi = [NSString stringWithFormat:@"%@%@%@", [config objectForKey:@"WebAPI"], [config objectForKey:@"ApplicationID"], query];
            
            NSString *webApi = [NSString stringWithFormat:@"%@%@", [config objectForKey:@"WebAPI"], [config objectForKey:@"ApplicationID"]];
            NSURL *url = [NSURL URLWithString:webApi];
            
            NSString *path = [NSString stringWithFormat:@"%@%@.json", APPLICATION_SUPPORT_PATH, [config objectForKey:@"ApplicationID"]];
            if (![fileManager fileExistsAtPath:path] || forceDownloading || autoRefresh) {
                NSLog(@"File does not exist or self.forceDownloading is true");
                // Check Connection if cache is not enabled
                if (!cacheIsEnabled) {
                    
                    // Check if user is currently in Roaming Case
                    if (self.roamingSituation) {
                        
                        // Check if user enable Roaming for our app
                        if (roamingIsEnabled) {
                            
                            // User is in Roaming case & enable it => Download
                            success = [self testConnection];
                            if (success) {
                                self.applicationDatas = [NSData dataWithContentsOfURL:url];
                                success = [[NSData dataWithContentsOfURL:url] writeToFile:path options:NSDataWritingAtomic error:&error];
                                if (success) {
                                    _isDownloadedByNetwork = true;
                                }
                            }
                        }
                        // User is in Roaming case but disable it => Alert & Quit
                    } else {
                        // User is not in Roaming case => Download
                        success = [self testConnection];
                        if (success) {
                            self.applicationDatas = [NSData dataWithContentsOfURL:url];
                            success = [[NSData dataWithContentsOfURL:url] writeToFile:path options:NSDataWritingAtomic error:&error];
                            if (success) {
                                _isDownloadedByNetwork = true;
                            }
                        }
                    }
                    // Trace Download date for refreshing
                    self.downloadDate = [NSDate date];
                    NSLog(@"Download Date = %@", self.downloadDate);
                    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.downloadDate forKey:@"downloadDate"]];
                }
            }
            else {
                NSLog(@"File exists");
                self.applicationDatas = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
                _isDownloadedByFile = true;
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@",path] error:&error];
                self.downloadDate = [attributes fileModificationDate];
                [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.downloadDate forKey:@"downloadDate"]];
            }
            
            if (self.applicationDatas != Nil) {
                APPLICATION_FILE = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:self.applicationDatas options:NSJSONReadingMutableLeaves error:&error];
                if (APPLICATION_FILE != Nil) {
                    [self searchDependencies];
                    /*if ([APPLICATION_FILE objectForKey:@"VersionID"]) {
                        if (!self.VersionID) {
                            self.VersionID = (long)[APPLICATION_FILE objectForKey:@"VersionID"];
                        } else if (self.VersionID != (long)[APPLICATION_FILE objectForKey:@"VersionID"]) {
                            forceDownloading = YES;
                            self.VersionID = (long)[APPLICATION_FILE objectForKey:@"VersionID"];
                        }
                        NSNumber *num = [NSNumber numberWithLong:self.VersionID];
                        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:num forKey:@"VersionID"]];
                    }*/
                }
                else {
                    NSLog(@"An error occured during the Deserialization of Application file : %@", error);
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"An error occured during the Saving of a Json file : %@, reason : %@", exception.name, exception.reason);
            UIApplication *app = [UIApplication sharedApplication];
            [app performSelector:@selector(suspend)];
            // Wait while app is going background
            [NSThread sleepForTimeInterval:2.0];
            exit(0);
        }
        @finally {
            self.downloadIsFinished = YES;
        }
        if (reloadApp || forceDownloading) {
            NSNotification * notif = [NSNotification notificationWithName:@"ConfigureAppNotification" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notif];
        }
    }
}

+ (NSMutableString *) addFiles:(NSArray *)dependencies
{
    NSMutableString *files;
    NSString *fileName;
    
    if (![dependencies isKindOfClass:[NSNull class]]) {
        for (NSMutableDictionary *appDep in dependencies) {
            if ([appDep objectForKey:@"Name"] != [NSNull null]) {
                if ([appDep objectForKey:@"Path"] == [NSNull null]) {
                    fileName = [NSString stringWithFormat:@"%@", [appDep objectForKey:@"Name"]];
                } else {
                    fileName = [NSString stringWithFormat:@"%@/%@", [appDep objectForKey:@"Path"], [appDep objectForKey:@"Name"]];
                }
                if ([[appDep objectForKey:@"Type"] isEqualToString:@"script"]) {
                    NSString *add = [NSString stringWithFormat:@"<script src='%@' type='text/javascript'></script>", fileName];
                    if (files) {
                        files = [NSMutableString stringWithFormat:@"%@%@", files, add];
                    } else {
                        files = (NSMutableString *)[NSString stringWithString:add];
                    }
                }
                if ([[appDep objectForKey:@"Type"] isEqualToString:@"style"]) {
                    NSString *add = [NSString stringWithFormat:@"<link type='text/css' rel='stylesheet' href='%@'></link>", fileName];
                    if (files) {
                        files = [NSMutableString stringWithFormat:@"%@%@", files, add];
                    } else {
                        files = (NSMutableString *)[NSString stringWithString:add];
                    }
                }
            }
        }
    }
    return files;
}

+ (NSString *)createHTMLwithContent:(NSString *)htmlContent withAppDep:(NSArray *)appDep withPageDep:(NSArray *)pageDep
{
    NSString *html;
    if (htmlContent) {
        NSMutableString *add;
        if (appDep && pageDep) {
            add = [NSMutableString stringWithFormat:@"%@%@", [AppDelegate addFiles:appDep], [AppDelegate addFiles:pageDep]];
        }
        else {
            add = [NSMutableString stringWithString:@""];
        }
        html = [NSString stringWithFormat:@"<!DOCTYPE>"
                "<html>"
                "<head>"
                "%@"
                "</head>"
                "<body>"
                "<div id='Main' style='padding:10px;'>"
                "%@"
                "</body>"
                "</head>"
                "</html>"
                , add, htmlContent];
        
    }
    
    return html;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }*/
    
    [self configureApp];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
