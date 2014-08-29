//
//  DisplayViewController.m
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//
#import "AppDelegate.h"
#import "DisplayViewController.h"
#import "CalendarTools.h"

@interface DisplayViewController ()

@end

@implementation DisplayViewController {
    AppDelegate *appDel;
    NSString *errorMsg;
    NSMutableDictionary *application;
    NSMutableArray *allPages;
    NSMutableArray *appDependencies;
    NSMutableArray *pageDependencies;
}

// Pas appelé lors du retour depuis les settings
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDone:) name:@"SettingsModificationNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDone:) name:@"NoModificationNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conflictIssue:) name:@"ConflictualSituationNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureAppDone:) name:@"ConfigureAppNotification" object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    self.navigationItem.title = nil;
    self.isConflictual = NO;
}

- (void)settingsDone:(NSNotification *)notification
{
    @synchronized(self) {
        if ([notification.name isEqualToString:@"SettingsModificationNotification"]) {
            reloadApp = YES;
            [self viewDidLoad];
        } else {
            reloadApp = NO;
            self.isConflictual = NO;
            self.navigationItem.title = self.whereWasI;
            self.img.hidden = YES;
            self.Display.hidden = NO;
        }
    }
}
- (void)conflictIssue:(NSNotification *)notification
{
    @synchronized(self){
        self.isConflictual = YES;
        [self viewDidLoad];
    }
}
- (void)configureAppDone:(NSNotification *)notification
{
    
    // Check if settings view is visible
    @synchronized(self){
        if ([self.navigationController.visibleViewController isKindOfClass:[DisplayViewController class]])
        {
            if (appDel.downloadIsFinished) {
                @try {
                    [NSThread sleepForTimeInterval:3.0];
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    self.navigationItem.title = self.whereWasI;
                    // Alert user that downloading is finished
                    errorMsg = [NSString stringWithFormat:@"The new settings is now supported. The reconfiguration of the Application is done."];
                    self.settingsDone = [[UIAlertView alloc] initWithTitle:@"Reconfiguration Successful" message:errorMsg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [self.settingsDone performSelectorOnMainThread:@selector(show) withObject:self waitUntilDone:YES];
                } @finally {
                    reloadApp = NO;
                    forceDownloading = NO;
                    [self viewDidLoad];
                }
            }
        }
    }
}

- (void)reloadApp
{
    @synchronized(self) {
        // Check if menu view is visible
        
        if (appDel == Nil) {
            appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        }
        reloadApp = YES;;
        [appDel configureApp];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    @synchronized(self){
        [super viewDidLoad];
        
        // Do any additional setup after loading the view, typically from a nib.
        appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.Display.delegate = self;
        
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.title = self.whereWasI;
        
        [self.img setImage:[UIImage imageNamed:@"LaunchImage-700"]];
        
        for (UIView *v in [self.view subviews]) {
            if ([v isKindOfClass:[UIWebView class]]) {
                self.webviewI = [[self.view subviews] indexOfObject:v];
            } else if ([v isKindOfClass:[UIImage class]]) {
                self.imageI = [[self.view subviews] indexOfObject:v];
            }
        }

        [self performSelectorInBackground:@selector(refreshApplicationByNewDownloading) withObject:self];
        
        if (self.isConflictual) {
            self.navigationItem.title = @"Conflictual situation";
            self.img.hidden = NO;
            self.Display.hidden = YES;
        } else if (reloadApp) {
            self.navigationItem.title = @"Reconfiguration in progress";
            self.img.hidden = NO;
            self.Display.hidden = YES;
            [self performSelectorInBackground:@selector(reloadApp) withObject:self];
        } else {
            self.img.hidden = YES;
            self.Display.hidden = NO;
        }
        
    [self initApp];
    }
}

- (void) initApp
{
    // Get Application json file
    @try {
        UIAlertView *alertConflict = [[UIAlertView alloc] initWithTitle:@"Conflictual Situation" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Settings",nil];
        float size = [[AppDelegate getSizeOf:APPLICATION_SUPPORT_PATH] floatValue];
        if (cacheIsEnabled && size == 0.0) {
            self.isConflictual = NO;
            alertConflict.message = @"Impossible to download content. The cache mode is enabled : it blocks the downloading. Do you want to disable it ?";
            [alertConflict show];
        } else if (appDel.roamingSituation && !roamingIsEnabled) {
            self.isConflictual = NO;
            alertConflict.message = @"Impossible to download content. You are currently in Roaming case and the roaming mode is disabled : it blocks the downloading. Do you want to enable it ?";
            [alertConflict show];
            /*} else if (!appDel.serverIsOk) {
             alertNoConnection.message = @"Impossible to download content on the server because it is not reachable. The application will shut down. Sorry for the inconvenience. Please try later.";*/
        } else if (!self.Display.hidden) {
            UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Application fails" message:nil delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil];
            if (appDel.isDownloadedByNetwork || appDel.isDownloadedByFile) {
                if (APPLICATION_FILE != Nil) {
                appDependencies = [APPLICATION_FILE objectForKey:@"Dependencies"];
                allPages = [APPLICATION_FILE objectForKey:@"Pages"];
                    if (self.PageID && ![self.whereWasI isEqualToString:@"Menu"]) {
                        [self configureDetails];
                    } else {
                        [self configureHome];
                    }
                }
            } else if (!appDel.isDownloadedByNetwork) {
                alertNoConnection.message = @"Impossible to download content on the server. The network connection is too low or off. The application will shut down. Please try later.";
                [alertNoConnection show];
            } else if (!appDel.isDownloadedByFile) {
                alertNoConnection.message = @"Impossible to download content file. The application will shut down. Sorry for the inconvenience.";
                [alertNoConnection show];
            }
        } else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            self.navigationItem.title = @"Reconfiguration in progress";
        }
    }
    @catch (NSException *e) {
        errorMsg = [NSString stringWithFormat:@"An error occured during the Loading of the Application : %@, reason : %@", e.name, e.reason];
        UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Application fails" message:errorMsg delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil];
        [alertNoConnection show];
    }
}

- (void)configureHome
{
    // Update the user interface for the Menu item.
    @try {
        for (NSMutableDictionary *page in allPages) {
            if ([[page objectForKey:@"TemplateType"] isEqualToString:@"Menu"]) {
                
                // Get Menu's Dependencies
                if ([page objectForKey:@"Dependencies"] != [NSNull null]) {
                    pageDependencies = [page objectForKey:@"Dependencies"];
                }
                
                NSURL *url = [NSURL fileURLWithPath:APPLICATION_SUPPORT_PATH isDirectory:YES];
                // Load Menu in the WebView
                if ([page objectForKey:@"HtmlContent"] != [NSNull null]) {
                    NSString *content = [AppDelegate createHTMLwithContent:[page objectForKey:@"HtmlContent"] withAppDep:appDependencies withPageDep:pageDependencies];
                    // Save HtmlContent in file
                    BOOL success = false;
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = [[NSError alloc] init];
                    NSString *path = [NSString stringWithFormat:@"%@index.html", APPLICATION_SUPPORT_PATH];
                    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                    success = [fileManager createFileAtPath:path contents:data attributes:nil];
                    if (!success) {
                        NSLog(@"An error occured during the Saving of the html file : %@", error);
                        NSException *e = [NSException exceptionWithName:error.localizedDescription reason:error.localizedFailureReason userInfo:error.userInfo];
                        @throw e;
                    }
                    
                    [self.Display loadHTMLString:content baseURL:url];
                }
                else {
                    [self.Display loadHTMLString:[AppDelegate createHTMLwithContent:@"<center><font color='blue'>There is no content</font></center>" withAppDep:nil withPageDep:nil] baseURL:url];
                }
                self.navigationItem.title = [page objectForKey:@"Title"];
            }
        }
    }
    @catch (NSException *exception) {
        errorMsg = [NSString stringWithFormat:@"An error occured during the Configuration of the view Menu : %@, reason : %@", exception.name, exception.reason];
        UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Application fails" message:errorMsg delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil];
        [alertNoConnection show];
    }
}

- (void) configureDetails
{
    @try {
        for (NSMutableDictionary *page in allPages) {
            
            if ([[page objectForKey:@"Id"] isEqual:self.PageID]) {
                // Get Page's Dependencies
                if ([page objectForKey:@"Dependencies"] != [NSNull null]) {
                    pageDependencies = [page objectForKey:@"Dependencies"];
                }
                NSURL *url = [NSURL fileURLWithPath:APPLICATION_SUPPORT_PATH isDirectory:YES];
                // Load Content in the WebView
                if ([page objectForKey:@"HtmlContent"] != [NSNull null]) {
                    // Create HTML
                    NSString *content = [AppDelegate createHTMLwithContent:[page objectForKey:@"HtmlContent"] withAppDep:appDependencies withPageDep:pageDependencies];
                    // Save html content in file
                    BOOL success = false;
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = [[NSError alloc] init];
                    NSString *path = [NSString stringWithFormat:@"%@details.html", APPLICATION_SUPPORT_PATH];
                    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                    success = [fileManager createFileAtPath:path contents:data attributes:nil];
                    if (!success) {
                        NSLog(@"An error occured during the Saving of the html file : %@", error);
                        NSException *e = [NSException exceptionWithName:error.localizedDescription reason:error.localizedFailureReason userInfo:error.userInfo];
                        @throw e;
                    }
                    // Load HTML
                    [self.Display loadHTMLString:content baseURL:url];
                }
                else {
                    [self.Display loadHTMLString:[AppDelegate createHTMLwithContent:@"<center><font color='blue'>There is no content</font></center>" withAppDep:nil withPageDep:nil] baseURL:url];
                }
                
                // Set Page's title
                self.navigationItem.title = [page objectForKey:@"Title"];
            }
        }
    }
    @catch (NSException *exception) {
        errorMsg = [NSString stringWithFormat:@"An error occured during the Configuration of the view Menu : %@, reason : %@", exception.name, exception.reason];
        UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Application fails" message:errorMsg delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil];
        [alertNoConnection show];
    }
}

#pragma mark - Web View
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.img.hidden = NO;
    self.Display.hidden = YES;
    self.Activity.hidden = NO;
    [self.Activity startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.whereWasI = self.navigationItem.title;
    [self.Activity stopAnimating];
    self.Activity.hidden = YES;
    self.img.hidden = YES;
    self.Display.hidden = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [UIView beginAnimations:@"animationID" context:nil];
	[UIView setAnimationDuration:2.0f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
	[UIView commitAnimations];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    //Absolute string : file:///Users/admin/Library/Application%20Support/iPhone%20Simulator/7.1/Applications/FDE30D9E-6C0D-4F1D-96F7-E7B1174A17A2/Library/Application%20Support/details.html
    //Absolute Url : file:///Users/admin/Library/Application%20Support/iPhone%20Simulator/7.1/Applications/FDE30D9E-6C0D-4F1D-96F7-E7B1174A17A2/Library/Application%20Support/details.html
    //Relative string : file:///Users/admin/Library/Application%20Support/iPhone%20Simulator/7.1/Applications/FDE30D9E-6C0D-4F1D-96F7-E7B1174A17A2/Library/Application%20Support/details.html
    //Relative Path : /Users/admin/Library/Application Support/iPhone Simulator/7.1/Applications/FDE30D9E-6C0D-4F1D-96F7-E7B1174A17A2/Library/Application Support/details.html
    //Path url : /Users/admin/Library/Application Support/iPhone Simulator/7.1/Applications/FDE30D9E-6C0D-4F1D-96F7-E7B1174A17A2/Library/Application Support/details.html
    
    int index = [APPLICATION_SUPPORT_PATH length] - 1;
    NSString *path = [APPLICATION_SUPPORT_PATH substringToIndex:index];

    NSArray *pathComponent = [[request.URL relativePath] pathComponents];

    if ([[request.URL relativePath] isEqualToString:path]) {
        // First loading
        self.lastPath = nil;
        return YES;
    } else if ([[request.URL relativePath] isEqualToString:[NSString stringWithFormat:@"%@index.html", APPLICATION_SUPPORT_PATH]]) {
        self.navigationItem.title = @"Menu";
        self.lastPath = [pathComponent lastObject];
        return YES;
    } else if ([[request.URL relativePath] isEqualToString:[NSString stringWithFormat:@"%@details.html", APPLICATION_SUPPORT_PATH]]) {
        self.lastPath = [pathComponent lastObject];
        return YES;
    } else if ([request.URL query] != nil) {
        self.lastPath = nil;
        self.PageID = [request.URL query];
        [self configureDetails];
        return YES;
    } else if (![request.URL relativePath] && ![request.URL query] && !self.PageID) {
        self.lastPath = nil;
        return YES;
    } else if (![request.URL relativePath] && ![request.URL query] && navigationType == 5 && [self.lastPath isEqualToString:@"index.html"]) {
        self.lastPath = nil;
        [self configureHome];
        return YES;
    }
    
    return NO;
}
- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    errorMsg = [NSString stringWithFormat:@"<html><center><font size=+4 color='red'>An error occured :<br>%@</font></center></html>", error.localizedDescription];
    [self.Display loadHTMLString:[AppDelegate createHTMLwithContent:errorMsg withAppDep:nil withPageDep:nil] baseURL:nil];
}

#pragma mark - Alert View
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView cancelButtonIndex] == buttonIndex) {
        // Fermer l'application
        //Home button
        UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(suspend)];
        // Wait while app is going background
        [NSThread sleepForTimeInterval:2.0];
        exit(0);
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Settings"]) {
        // Go to settings
        self.isConflictual = NO;

        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        SettingsView *showSettings = [[SettingsView alloc] init];
        showSettings = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsView"];
        [self.navigationController pushViewController:showSettings animated:YES];

    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        self.isConflictual = NO;
    }
}

/*
        case shareItemTag : {
            NSDictionary *dico = [self.Display.request allHTTPHeaderFields];
            NSData *data = [self.Display.request HTTPBody];
            UIImage *shareImage = [UIImage imageNamed:@""];
            NSString *shareMessage = @"";
            NSURL *shareUrl = [self.Display.request URL];
            NSArray *shareArray = [NSArray arrayWithObjects:shareMessage, shareImage, shareUrl, nil];
            self.shareActivity = [[UIActivityViewController alloc] initWithActivityItems:shareArray applicationActivities:nil];
            self.shareActivity.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:self.shareActivity animated:YES completion:nil];
        }
            break;
        case geolocItemTag :
            NSLog(@"bla");
            break;
        case contactsItemTag :
            NSLog(@"bla");
            break;
        case calendarItemTag : {
            [CalendarTools requestAccess:^(BOOL granted, NSError *error) {
                if (granted) {
                    NSDate *myDate = [NSDate dateWithTimeIntervalSinceNow:86400]; // 1 jour
                    BOOL result = [CalendarTools addEventAt:myDate withTitle:@"My new RDV" inLocation:@"Luxembourg"];
                    if (result) {
                        NSLog(@"RDV Ajouté");
                    } else {
                        NSLog(@"RDV pas ajouté");
                    }
                } else {
                    // Permission denied
                }
                }];
        }
            break;
        default:
            break;
    }
} */

// Do not change the date if just the refresh variable has changed
- (void) refreshApplicationByNewDownloading
{
    @synchronized(self){
        if (appDel == Nil) {
            appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        }
        int interval;
        if ([appDel.refreshDuration isEqualToString:@"heure"]) {
            interval= [appDel.refreshInterval doubleValue] * 60 * 60;
        } else if ([appDel.refreshDuration isEqualToString:@"jour"]) {
            interval = [appDel.refreshInterval integerValue] * 60 * 60 * 24;
        }
        
        if (self.backgroundTimer.timeInterval != interval) {
            self.backgroundTimer = [NSTimer timerWithTimeInterval:[appDel.refreshInterval integerValue] * 60 target:self selector:@selector(forceDownloadingApplication:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.backgroundTimer forMode:NSRunLoopCommonModes];
        }
    }
}

- (void) forceDownloadingApplication:(NSTimer *)timer
{
    @synchronized(self){
        if (appDel == Nil) {
            appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        }
        NSTimeInterval currentInterval = [[NSDate date] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"downloadDate"]];
        NSLog(@"Current interval = %f, Choosen Interval = %f", currentInterval, timer.timeInterval);
        
        if (!cacheIsEnabled) {
            if (currentInterval >= timer.timeInterval) {
                // Download all
                [appDel performSelectorInBackground:@selector(configureApp) withObject:appDel];
            }
        }
    }
}

@end
