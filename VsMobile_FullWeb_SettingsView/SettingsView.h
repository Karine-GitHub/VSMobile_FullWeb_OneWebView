//
//  SettingsView.h
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsView : UITableViewController <UIAlertViewDelegate, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *SettingsTable;

@property (strong, nonatomic) IBOutlet UILabel *refreshChoice;
@property (strong,nonatomic) NSString *refreshValue;

@property (weak, nonatomic) IBOutlet UISwitch *cacheMode;

@property (weak, nonatomic) IBOutlet UISwitch *roamingMode;

@property (weak, nonatomic) IBOutlet UILabel *dataSize;
@property (strong,nonatomic) NSString *dataSizeValue;
@property float size;

@property (weak, nonatomic) IBOutlet UILabel *imagesSize;
@property (strong,nonatomic) NSString *imagesSizeValue;

@property (strong, nonatomic) IBOutlet UITableViewCell *downloadDataCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *deleteCacheCell;

@property (strong, nonatomic) NSString *errorMsg;
@property BOOL reconfigNecessary;
@property BOOL goToRefresh;

@end
