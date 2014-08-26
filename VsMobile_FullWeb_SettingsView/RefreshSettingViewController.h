//
//  RefreshSettingViewController.h
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RefreshSettingViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *refresh;

@property (strong, nonatomic) NSMutableArray *intervalValues;
@property (strong, nonatomic) NSMutableArray *durationValues;

@property (strong,nonatomic) NSString *intervalChoice;
@property (strong,nonatomic) NSString *durationChoice;

@end
