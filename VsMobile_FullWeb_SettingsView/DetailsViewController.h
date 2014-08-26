//
//  DetailsViewController.h
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayViewController.h"

@class MenuViewController;

@interface DetailsViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *Details;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) NSString *errorMsg;

@end
