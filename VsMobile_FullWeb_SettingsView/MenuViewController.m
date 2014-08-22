//
//  MenuViewController.m
//  VsMobile_FullWeb_SettingsView
//
//  Created by admin on 8/8/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//
#import "AppDelegate.h"
#import "MenuViewController.h"


@interface MenuViewController ()

@end

@implementation MenuViewController {
    AppDelegate *appDel;
    NSString *errorMsg;
    NSMutableDictionary *application;
    NSMutableArray *allPages;
    NSMutableArray *appDependencies;
    NSMutableArray *pageDependencies;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDone:) name:@"SettingsIsFinishedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureAppDone:) name:@"ConfigureAppNotification" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)settingsDone:(NSNotification *)notification {
    NSLog(@"Passage dans settingsDone => notif OK");
    self.needReloadApp = YES;
    self.navigationItem.title = @"Reconfiguration in progress";
    [self viewDidLoad];
}

- (void)reloadApp
{
     // Check if menu view is visible
    NSLog(@"[MenuView_reloadApp] Visible view controller = %@", self.navigationController.visibleViewController);
    if ([self.navigationController.visibleViewController isKindOfClass:[MenuViewController class]])
    {
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
    }
}

- (void)configureAppDone:(NSNotification *)notification {
    
    // Check if settings view is visible
    NSLog(@"[Menu_configureApp] Visible view controller = %@", self.navigationController.visibleViewController);
    if ([self.navigationController.visibleViewController isKindOfClass:[MenuViewController class]])
    {
        if (self.needReloadApp) {
            // Sleep is necessary for displaying the alert
            [NSThread sleepForTimeInterval:2.0];
            // Alert user that downloading is finished
            errorMsg = [NSString stringWithFormat:@"The new settings is now supported. The reconfiguration of the Application is done."];
            UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Reconfiguration Successful" message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertNoConnection show];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.navigationItem.title = @"Menu";
        }
        self.img.hidden = YES;
        self.Menu.hidden = NO;
        self.needReloadApp = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.Menu.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = nil;
    
    [self.img setImage:[UIImage imageNamed:@"LaunchImage-700"]];
    
    if (self.needReloadApp) {
        self.img.hidden = NO;
        self.Menu.hidden = YES;
        NSLog(@"[needReloadApp true] Img hidden = %hhd", self.img.hidden);
        NSLog(@"[needReloadApp true] Menu hidden = %hhd", self.Menu.hidden);
        [self performSelectorInBackground:@selector(reloadApp) withObject:self];
    } else {
        self.img.hidden = YES;
        self.Menu.hidden = NO;
        NSLog(@"[needReloadApp false] Img hidden = %hhd", self.img.hidden);
        NSLog(@"[needReloadApp false] Menu hidden = %hhd", self.Menu.hidden);
    }
    
    [self initApp];
}

- (void) initApp
{
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Get Application json file
    @try {
        if (!self.Menu.hidden) {
            if (appDel.isDownloadedByNetwork || appDel.isDownloadedByFile) {
                NSError *error = [[NSError alloc] init];
                application = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:APPLICATION_FILE options:NSJSONReadingMutableLeaves error:&error];
                if (application != nil) {
                    appDependencies = [application objectForKey:@"Dependencies"];
                    allPages = [application objectForKey:@"Pages"];
                    [self configureView];
                }
                else {
                    NSLog(@"An error occured during the Loading of the Application : %@", error);
                    // throw exception
                    NSException *e = [NSException exceptionWithName:error.localizedDescription reason:error.localizedFailureReason userInfo:error.userInfo];
                    @throw e;
                }
            }
            else {
                UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Application fails" message:nil delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil];
                if (appDel.cacheIsEnabled) {
                    alertNoConnection.message = @"Impossible to download content. The cache mode is enabled : it blocks the downloading. Do you want to disable it ?";
                    [alertNoConnection addButtonWithTitle:@"Settings"];
                } else if (!appDel.isDownloadedByNetwork) {
                    alertNoConnection.message = @"Impossible to download content on the server. The network connection is too low or off. The application will shut down. Please try later.";
                } else if (!appDel.isDownloadedByFile) {
                    alertNoConnection.message = @"Impossible to download content file. The application will shut down. Sorry for the inconvenience.";
                    
                }
                
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

- (void)configureView
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
                    
                    [self.Menu loadHTMLString:content baseURL:url];
                }
                else {
                    [self.Menu loadHTMLString:[AppDelegate createHTMLwithContent:@"<center><font color='blue'>There is no content</font></center>" withAppDep:nil withPageDep:nil] baseURL:url];
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
    } else if ([request.URL query] != nil) {
        self.showDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"detailsView"];
        self.showDetails.detailItem = [request.URL query];
        [self.navigationController pushViewController:self.showDetails animated:YES];
        return YES;
    }
    return NO;
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    errorMsg = [NSString stringWithFormat:@"<html><center><font size=+4 color='red'>An error occured :<br>%@</font></center></html>", error.localizedDescription];
    [self.Menu loadHTMLString:[AppDelegate createHTMLwithContent:errorMsg withAppDep:nil withPageDep:nil] baseURL:nil];
}

#pragma mark - Alert View
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.needReloadApp) {
        if ([alertView cancelButtonIndex] == buttonIndex) {
            // Fermer l'application
            //Home button
            UIApplication *app = [UIApplication sharedApplication];
            [app performSelector:@selector(suspend)];
            // Wait while app is going background
            [NSThread sleepForTimeInterval:2.0];
            exit(0);
        } else {
            // Go to settings
            SettingsView *showSettings = [[SettingsView alloc] init];
            showSettings = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsView"];
            [self.navigationController pushViewController:showSettings animated:YES];
        }
    }
}

@end
