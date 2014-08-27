//
//  DisplayViewController.h
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsView.h"

@interface DisplayViewController : UIViewController <UIAlertViewDelegate, UITextViewDelegate, UISplitViewControllerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *Display;
@property (weak, nonatomic) IBOutlet UIButton *Settings;
@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *Activity;

@property id PageID;

@property (strong, nonatomic) NSArray *subviews;
@property int webviewI;
@property int imageI;
typedef enum directionEnum {showImage, showWebview}Direction;

@property (strong, nonatomic) UIAlertView *settingsDone;

@property (strong,nonatomic) NSString *whereWasI;

@property BOOL needReloadApp;
@property BOOL isConflictual;

@end
