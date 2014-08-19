//
//  MenuViewController.h
//  VsMobile_FullWeb_SettingsView
//
//  Created by admin on 8/8/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsView.h"
#import "DetailsViewController.h"

@interface MenuViewController : UIViewController <UIAlertViewDelegate, UITextViewDelegate, UISplitViewControllerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *Menu;
@property (weak, nonatomic) IBOutlet UIButton *Settings;

@property (nonatomic,retain) DetailsViewController *showDetails;
@property (nonatomic, retain) SettingsView *showSettings;

@end
