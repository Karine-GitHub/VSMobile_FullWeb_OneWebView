//
//  DetailsViewController.m
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailsViewController.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController {
    MenuViewController *Menu;
    NSMutableDictionary *application;
    NSMutableArray *allPages;
    NSMutableArray *appDependencies;
    NSMutableArray *pageDependencies;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self viewDidLoad];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.Details.delegate = self;
    self.navigationItem.hidesBackButton = YES;
    // Get Application's Dependencies
    @try {
        if (APPLICATION_FILE == Nil) {
            // Throw exception
            NSException *e = [NSException exceptionWithName:@"Loading Fails" reason:@"NSDictionnary APPLICATION_FILE is nil" userInfo:nil];
            @throw e;
        }
        else {
            if ([APPLICATION_FILE objectForKey:@"Dependencies"] != [NSNull null]) {
                appDependencies = [APPLICATION_FILE objectForKey:@"Dependencies"];
            }
            if ([APPLICATION_FILE objectForKey:@"Pages"] != [NSNull null]) {
                allPages = [APPLICATION_FILE objectForKey:@"Pages"];
            }
            self.navigationItem.backBarButtonItem.title = [APPLICATION_FILE objectForKey:@"Name"];
            [self configureView];
        }
    }
    @catch  (NSException *e) {
        _errorMsg = [NSString stringWithFormat:@"An error occured during the Loading of the Application : %@, reason : %@", e.name, e.reason];
        UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Application fails" message:_errorMsg delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil];
        [alertNoConnection show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        @try {
            for (NSMutableDictionary *details in allPages) {
                if ([[details objectForKey:@"Id"] isEqual:self.detailItem]) {
                    // Get Page's Dependencies
                    if ([details objectForKey:@"Dependencies"] != [NSNull null]) {
                        pageDependencies = [details objectForKey:@"Dependencies"];
                    }
                    NSURL *url = [NSURL fileURLWithPath:APPLICATION_SUPPORT_PATH isDirectory:YES];
                    // Load Content in the WebView
                    if ([details objectForKey:@"HtmlContent"] != [NSNull null]) {
                        // Create HTML
                        NSString *content = [AppDelegate createHTMLwithContent:[details objectForKey:@"HtmlContent"] withAppDep:appDependencies withPageDep:pageDependencies];
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
                        [self.Details loadHTMLString:content baseURL:url];
                    }
                    else {
                        [self.Details loadHTMLString:[AppDelegate createHTMLwithContent:@"<center><font color='blue'>There is no content</font></center>" withAppDep:nil withPageDep:nil] baseURL:url];
                    }
                    
                    // Set Page's title
                    if ([APPLICATION_FILE objectForKey:@"Title"] == [NSNull null]) {
                        self.navigationItem.title = @"No Name property";
                    }
                    else {
                        self.navigationItem.title = [details objectForKey:@"Title"];
                    }
                }
            }
        }
        @catch  (NSException *e) {
            _errorMsg = [NSString stringWithFormat:@"An error occured during the Configuration of the view '%@' : %@, reason : %@", self.detailItem, e.name, e.reason];
            UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Application fails" message:_errorMsg delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil];
            [alertNoConnection show];
        }
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
    int index = [APPLICATION_SUPPORT_PATH length] - 1;
    NSString *path = [APPLICATION_SUPPORT_PATH substringToIndex:index];

    if ([[request.URL relativePath] isEqualToString:path]) {
        return YES;
    } else if ([[request.URL relativePath] isEqualToString:[NSString stringWithFormat:@"%@details.html", APPLICATION_SUPPORT_PATH]]) {
        return YES;
    } else if ([[request.URL relativePath] isEqualToString:[NSString stringWithFormat:@"%@index.html", APPLICATION_SUPPORT_PATH]]) {
        Menu = [self.storyboard instantiateViewControllerWithIdentifier:@"menuView"];
        [self.navigationController pushViewController:Menu animated:YES];
        return YES;
    }
    return NO;
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _errorMsg = [NSString stringWithFormat:@"<html><center><font size=+4 color='red'>An error occured :<br>%@</font></center></html>", error.localizedDescription];
    [self.Details loadHTMLString:[AppDelegate createHTMLwithContent:_errorMsg withAppDep:nil withPageDep:nil] baseURL:nil];
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
    }
}

@end
