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
    self.durationValues = [[NSArray alloc] initWithObjects:@"heure", @"jour", nil];
    
    self.intervalValues = [[NSMutableArray alloc] init];
    for (int i=1; i < 31; ++i) {
        [self.intervalValues addObject:[NSDecimalNumber numberWithInt:i]];
    }
    self.interval.dataSource = self;
    self.interval.delegate = self;
    self.duration.dataSource = self;
    self.duration.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"PickerView : %@", pickerView.restorationIdentifier);
    if ([pickerView.restorationIdentifier isEqualToString:self.interval.restorationIdentifier]) {
        return self.durationValues.count;
    } else if ([pickerView.restorationIdentifier isEqualToString:self.duration.restorationIdentifier]) {
        return self.durationValues.count;
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView.restorationIdentifier isEqualToString:self.interval.restorationIdentifier]) {
        return self.intervalValues[row];
    } else if ([pickerView.restorationIdentifier isEqualToString:self.duration.restorationIdentifier]) {
        return self.durationValues[row];
    } else {
        return nil;
    }
}

- (int) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.interval]) {
        self.intervalChoice = self.intervalValues[row];
    } else if ([pickerView isEqual:self.duration]) {
        self.durationChoice = self.durationValues[row];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Choice : %@%@", self.intervalChoice, self.durationChoice);
    // Add choice in NSUserDefaults
    if (self.intervalChoice && self.durationChoice) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.intervalChoice forKey:@"intervalChoice"]];
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.durationChoice forKey:@"durationChoice"]];
    }
}

@end
