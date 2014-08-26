//
//  SettingsView.h
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsView : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *SettingsTable;
@property (strong, nonatomic) IBOutlet UINavigationItem *Navigate;

@property (strong, nonatomic) IBOutlet UILabel *refreshChoice;
@property (strong,nonatomic) NSString *refreshValue;

@property (weak, nonatomic) IBOutlet UISwitch *cacheMode;

@property (weak, nonatomic) IBOutlet UISwitch *roamingMode;

@property (weak, nonatomic) IBOutlet UILabel *dataSize;
@property (strong,nonatomic) NSString *dataSizeValue;

@property (weak, nonatomic) IBOutlet UILabel *imagesSize;
@property (strong,nonatomic) NSString *imagesSizeValue;

@property (weak, nonatomic) IBOutlet UIButton *downloadData;
@property (weak, nonatomic) IBOutlet UIButton *deleteCache;

@property (strong, nonatomic) NSString *errorMsg;
@property BOOL reconfigNecessary;

@end
