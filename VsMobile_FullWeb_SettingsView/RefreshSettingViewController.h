//
//  RefreshSettingViewController.h
//  VsMobile_FullWeb_SettingsView
//
//  Created by admin on 8/14/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RefreshSettingViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *interval;

@property (strong, nonatomic) NSMutableArray *intervalValues;
@property (strong, nonatomic) NSArray *durationValues;

@property (strong,nonatomic) NSString *intervalChoice;
@property (strong,nonatomic) NSString *durationChoice;

@end
