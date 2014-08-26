//
//  DisplayViewController.m
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//
#import "AppDelegate.h"
#import "DisplayViewController.h"


@interface DisplayViewController ()

@end

@implementation DisplayViewController {
    AppDelegate *appDel;
    NSString *errorMsg;
    NSMutableDictionary *application;
    NSMutableArray *allPages;
    NSMutableArray *appDependencies;
    NSMutableArray *pageDependencies;
    int iSettingsModif;
    int iNomodif;
    int iConflit;
    int iConfigureApp;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)GoToSettings:(id)sender {
    NSLog(@"SettingsModificationNotification : %d", iSettingsModif);
    NSLog(@"NoModificationNotification : %d", iNomodif);
    NSLog(@"ConflictualSituationNotification : %d", iConflit);
    NSLog(@"ConfigureAppNotification : %d", iConfigureApp);

}

// Pas appelé lors du retour depuis les settings
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    iSettingsModif = 0;
    iNomodif = 0;
    iConflit = 0;
    iConfigureApp = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDone:) name:@"SettingsModificationNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDone:) name:@"NoModificationNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conflictIssue:) name:@"ConflictualSituationNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureAppDone:) name:@"ConfigureAppNotification" object:nil];
    NSLog(@"ADD SettingsModificationNotification : %d", ++iSettingsModif);
    NSLog(@"ADD NoModificationNotification : %d", ++iNomodif);
    NSLog(@"ADD ConflictualSituationNotification : %d", ++iConflit);
    NSLog(@"ADD ConfigureAppNotification : %d", ++iConfigureApp);
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    self.navigationItem.title = nil;
    self.isConflictual = NO;
    self.needReloadApp = NO;
}

- (void)settingsDone:(NSNotification *)notification {
    @synchronized(self) {
        if ([notification.name isEqualToString:@"SettingsModificationNotification"]) {
            self.needReloadApp = YES;
            //[self performSelectorOnMainThread:@selector(viewDidLoad) withObject:self waitUntilDone:YES];
            [self viewDidLoad];
        } else {
            self.needReloadApp = NO;
            self.isConflictual = NO;
            self.navigationItem.title = @"Menu";
        }
    }
}
- (void)conflictIssue:(NSNotification *)notification {
    @synchronized(self){
        self.isConflictual = YES;
        //[self performSelectorOnMainThread:@selector(viewDidLoad) withObject:self waitUntilDone:YES];

        [self viewDidLoad];
    }
}

- (void)configureAppDone:(NSNotification *)notification {
    
    // Check if settings view is visible
    @synchronized(self){
        if (appDel.reloadApp || appDel.forceDownloading) {
                @try {
                    [NSThread sleepForTimeInterval:2.0];
                    // Alert user that downloading is finished
                    errorMsg = [NSString stringWithFormat:@"The new settings is now supported. The reconfiguration of the Application is done."];
                    self.settingsDone = [[UIAlertView alloc] initWithTitle:@"Reconfiguration Successful" message:errorMsg delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [self.settingsDone show];
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    self.navigationItem.title = @"Menu";
                    //}
                } @catch (NSException *exception) {
                    errorMsg = @"Reconfig fails";
                    self.settingsDone = [[UIAlertView alloc] initWithTitle:@"Reconfiguration fails" message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    //[self.settingsDone show];
                } @finally {
                    self.needReloadApp = NO;
                    //[self performSelectorInBackground:@selector(viewDidLoad) withObject:self];
                    //[self performSelectorOnMainThread:@selector(viewDidLoad) withObject:self waitUntilDone:YES];
                    [self viewDidLoad];
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
        @try {
            [appDel setReloadApp:YES];
            [appDel configureApp];
        }
        @catch (NSException *exception) {
            if (appDel.cacheIsEnabled) {
                errorMsg = @"Impossible to download content. The cache mode is enabled : it blocks the downloading. Please turn it off.";
            } else if (!appDel.isDownloadedByNetwork) {
                errorMsg = @"Impossible to download content on the server. The network connection is too low or off. Please try later.";
            }
            UIAlertView *alertLoadingFail = [[UIAlertView alloc] initWithTitle:@"Downloading fails" message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertLoadingFail show];
        }
        @finally {
            [appDel setReloadApp:NO];
        }
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
    
    [self.img setImage:[UIImage imageNamed:@"LaunchImage-700"]];
    
    if (self.isConflictual) {
        self.navigationItem.title = @"Conflictual situation";
        self.img.hidden = NO;
        self.Display.hidden = YES;
    } else if (self.needReloadApp) {
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
        UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Application fails" message:nil delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil];
        float size = [[AppDelegate getSizeOf:APPLICATION_SUPPORT_PATH] floatValue];
        if (appDel.cacheIsEnabled && size == 0.0) {
            //NSLog(@"Cache enabled");
            self.isConflictual = NO;
            alertNoConnection.title = @"Conflictual Situation";
            alertNoConnection.message = @"Impossible to download content. The cache mode is enabled : it blocks the downloading. Do you want to disable it ?";
            [alertNoConnection addButtonWithTitle:@"Settings"];
            [alertNoConnection show];
        } else if (appDel.roamingSituation && !appDel.roamingIsEnabled) {
            //NSLog(@"appDel.roamingSituation && !appDel.roamingIsEnabled");
            self.isConflictual = NO;
            alertNoConnection.title = @"Conflictual Situation";
            alertNoConnection.message = @"Impossible to download content. You are currently in Roaming case and the roaming mode is disabled : it blocks the downloading. Do you want to enable it ?";
            [alertNoConnection addButtonWithTitle:@"Settings"];
            [alertNoConnection show];
            /*} else if (!appDel.serverIsOk) {
             alertNoConnection.message = @"Impossible to download content on the server because it is not reachable. The application will shut down. Sorry for the inconvenience. Please try later.";*/
        } else if (!self.Display.hidden) {
            //NSLog(@"Menu visible");
            if (appDel.isDownloadedByNetwork || appDel.isDownloadedByFile) {
                if (APPLICATION_FILE != Nil) {
                appDependencies = [APPLICATION_FILE objectForKey:@"Dependencies"];
                allPages = [APPLICATION_FILE objectForKey:@"Pages"];
                    if (self.PageID) {
                        [self configureDetails];
                    } else {
                        [self configureHome];
                    }
                }
            } else if (!appDel.isDownloadedByNetwork) {
                //NSLog(@"Not downloaded by network");
                alertNoConnection.message = @"Impossible to download content on the server. The network connection is too low or off. The application will shut down. Please try later.";
                [alertNoConnection show];
            } else if (!appDel.isDownloadedByFile) {
                //NSLog(@"Not downloaded by file");
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    //NSLog(@"Path modifié = %@", path);
    //NSLog(@"Query = %@", [request.URL query]);
    
    if ([[request.URL relativePath] isEqualToString:path]) {
        // First loading
        return YES;
    } else if ([[request.URL relativePath] isEqualToString:[NSString stringWithFormat:@"%@index.html", APPLICATION_SUPPORT_PATH]]) {
        return YES;
    } else if ([[request.URL relativePath] isEqualToString:[NSString stringWithFormat:@"%@details.html", APPLICATION_SUPPORT_PATH]]) {
        return YES;
    } else if ([request.URL query] != nil) {
        self.PageID = [request.URL query];
        return NO;
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

        // Switch cache mode not responsive in all cases
        //[self.navigationController performSelectorInBackground:@selector(pushViewController:animated:) withObject:showSettings];
        //[self.navigationController performSelectorOnMainThread:@selector(pushViewController:animated:) withObject:showSettings waitUntilDone:YES];

    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        // This alertView need to reload the init
        self.isConflictual = NO;
        //[self performSelectorOnMainThread:@selector(viewDidLoad) withObject:self waitUntilDone:YES];

        [self initApp];
    }
    
}

@end
