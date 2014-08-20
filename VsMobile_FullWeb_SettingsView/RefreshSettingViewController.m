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
    for (int i=1; i < 31; i++) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [self.intervalValues addObject:[number stringValue]];
    }
    self.interval.dataSource = self;
    self.interval.delegate = self;
    
    // Init picker values
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"intervalChoice"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"durationChoice"]) {
        // Use values selected by user
        for (int i=0; i < self.intervalValues.count; i++) {
            if ([[self.intervalValues objectAtIndex:i] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"] stringValue]]) {
                [self.interval selectRow:i inComponent:0 animated:YES];
            }
        }
        for (int i=0; i < self.durationValues.count; i++) {
            if ([[self.durationValues objectAtIndex:i] isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"] stringValue]]) {
                [self.interval selectRow:i inComponent:1 animated:YES];
            }
        }
    // Default values : 1 day
    } else {
        [self.interval selectRow:0 inComponent:0 animated:YES];
        [self.interval selectRow:1 inComponent:1 animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.intervalValues.count;
    } else {
        return self.durationValues.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.intervalValues objectAtIndex:row];
    } else {
        return [self.durationValues objectAtIndex:row];
    }
}

- (int) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.intervalChoice = [self.intervalValues objectAtIndex:row];
    } else {
        self.durationChoice = [self.durationValues objectAtIndex:row];
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
