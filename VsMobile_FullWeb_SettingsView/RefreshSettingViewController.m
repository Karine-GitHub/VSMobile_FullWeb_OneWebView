//
//  RefreshSettingViewController.m
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
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

- (void) viewWillDisappear:(BOOL)animated
{
    // Save user choice
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.intervalChoice forKey:@"intervalChoice"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.durationChoice forKey:@"durationChoice"]];
    // Notify that  choice is done
    NSNotification * notif = [NSNotification notificationWithName:@"RefreshAppNotification" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:notif];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.durationValues = [[NSMutableArray alloc] initWithObjects:@"heure", @"jour", nil];
    
    self.intervalValues = [[NSMutableArray alloc] init];
    for (int i=1; i < 31; i++) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [self.intervalValues addObject:[number stringValue]];
    }
    self.refresh.dataSource = self;
    self.refresh.delegate = self;
    
    // Init picker values
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"]) {
        // Use values selected by user
        self.intervalChoice = [[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"];
        char plural = [[[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"] characterAtIndex:[[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"].length -1];
        if (plural == 's') {
            self.durationChoice = [[[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"s"]];
        } else {
            self.durationChoice = [[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"];
        }

        int iDuration = [self.durationValues indexOfObject:self.durationChoice];
        
        [self.refresh selectRow:[self.intervalChoice integerValue]-1 inComponent:0 animated:YES];
        [self.refresh selectRow:iDuration inComponent:1 animated:YES];
        
        // Default values : 1 day
    } else {
        [self.refresh selectRow:0 inComponent:0 animated:YES];
        self.intervalChoice = [self.intervalValues objectAtIndex:0];
        [self.refresh selectRow:1 inComponent:1 animated:YES];
        self.durationChoice = [self.durationValues objectAtIndex:1];
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
    if ([self.intervalChoice integerValue] > 1) {
        [self.durationValues replaceObjectAtIndex:0 withObject:@"heures"];
        [self.durationValues replaceObjectAtIndex:1 withObject:@"jours"];
    } else {
        [self.durationValues replaceObjectAtIndex:0 withObject:@"heure"];
        [self.durationValues replaceObjectAtIndex:1 withObject:@"jour"];
    }
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
    if ([[self.intervalValues objectAtIndex:row] integerValue] > 1) {
        [self.durationValues replaceObjectAtIndex:0 withObject:@"heures"];
        [self.durationValues replaceObjectAtIndex:1 withObject:@"jours"];
    } else {
        [self.durationValues replaceObjectAtIndex:0 withObject:@"heure"];
        [self.durationValues replaceObjectAtIndex:1 withObject:@"jour"];
    }
    [pickerView reloadComponent:1];

}

@end
