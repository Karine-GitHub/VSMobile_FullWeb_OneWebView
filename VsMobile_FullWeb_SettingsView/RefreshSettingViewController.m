//
//  RefreshSettingViewController.m
//  VsMobile_FullWeb_SettingsView
//
//  Created by admin on 8/14/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "RefreshSettingViewController.h"

@interface RefreshSettingViewController ()

@end

@implementation RefreshSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableArray *intervalValues = [[NSMutableArray alloc] init];
    NSArray *durationValues = [[NSArray alloc] initWithObjects:@"heure", @"jour", nil];
    for (int i=0; i < 31; ++i) {
        [intervalValues addObject:[NSDecimalNumber numberWithInt:i]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
