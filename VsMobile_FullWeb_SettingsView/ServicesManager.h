//
//  ServicesManager.h
//  VsMobile_FullWeb_OneWebview
//
//  Created by admin on 9/3/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServicesManager : UITableViewController

@property (strong,nonatomic) NSMutableArray *appMenu;
@property (strong,nonatomic) NSDictionary *itemMenu;
@property int nbMenuItem;

@property BOOL isChecked;
- (void)clickCheckBox:(id)sender;

@end
