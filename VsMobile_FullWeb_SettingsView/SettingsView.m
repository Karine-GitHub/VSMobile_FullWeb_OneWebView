//
//  SettingsView.m
//  VsMobile_FullWeb_OneWebView
//
//  Created by admin on 8/26/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "SettingsView.h"
#import "AppDelegate.h"

@interface SettingsView ()

@end

@implementation SettingsView {
    AppDelegate *appDel;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"refresh"]) {
        self.goToRefresh = YES;
    }
}

/* Add observer on :
 - the method configureApp of AppDelegate Class : it is called in background during the loading of datas. Necessary for refreshing datas & images size.
 - when RefreshSettings view will disapear for saving user choice
 */
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureApp:) name:@"ConfigureAppNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshApp:) name:@"RefreshAppNotification" object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    // Refresh Cache Mode & Roaming Mode (not always refresh because not necessary passed in ViewDidLoad)
    @synchronized(self){
        cacheIsEnabled = self.cacheMode.isOn;
        roamingIsEnabled = self.roamingMode.isOn;
    }
    // Register settings
    NSNumber *cache = [NSNumber numberWithBool:self.cacheMode.isOn];
    NSNumber *roaming = [NSNumber numberWithBool:self.roamingMode.isOn];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:cache forKey:@"cache"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:roaming forKey:@"roaming"]];
    
    // Notify that settings was modified
    // Si les settings sont bloquants : cas Cache Mode + cache = Oko, RoamingSituation + RoamingDisable => Event Conflictual Situation
    // sinon Event Settings is Finished
    if (!self.goToRefresh) {
        self.size = [[AppDelegate getSizeOf:APPLICATION_SUPPORT_PATH] floatValue];
        if (self.cacheMode.isOn && self.size == 0.0) {
            NSNotification * notif = [NSNotification notificationWithName:@"ConflictualSituationNotification" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notif];
        } else if (appDel.roamingSituation && !self.roamingMode.isOn){
            NSNotification * notif = [NSNotification notificationWithName:@"ConflictualSituationNotification" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notif];
        } else if (self.reconfigNecessary) {
            NSNotification * notif = [NSNotification notificationWithName:@"SettingsModificationNotification" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notif];
        } else {
            NSNotification * notif = [NSNotification notificationWithName:@"NoModificationNotification" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notif];
        }
    }
}

- (void)configureApp:(NSNotification *)notification {
    
    // Check if settings view is visible
    if ([self.navigationController.visibleViewController isKindOfClass:[SettingsView class]])
    {
        self.reconfigNecessary = NO;
        [NSThread sleepForTimeInterval:3.0];
        // Set Datas & Images Sizes
        self.dataSize.text = [NSString stringWithFormat:@"%.02f ko", [[AppDelegate getSizeOf:APPLICATION_SUPPORT_PATH] floatValue]];
        self.imagesSize.text = [NSString stringWithFormat:@"%.02f ko", [[AppDelegate getSizeOf:[NSString stringWithFormat:@"%@Images", APPLICATION_SUPPORT_PATH]] floatValue]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];        
        // Alert user that downloading is finished
        self.errorMsg = [NSString stringWithFormat:@"The downloading of files is done."];
        UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Downloading Successful" message:self.errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertNoConnection performSelectorOnMainThread:@selector(show) withObject:self waitUntilDone:YES];
    }
}
- (void)refreshApp:(NSNotification *)notification {
    // Set RefreshChoice text when RefreshSettingsView disapear
    
    char plural = [[[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"] characterAtIndex:[[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"].length -1];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"intervalChoice"] > 1 && plural != 's') {
        NSString *pluriel = [NSString stringWithFormat:@"%@s", [[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"]];
        self.refreshValue = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"], pluriel];
    } else {
        self.refreshValue = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"], [[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"]];
    }
    
    if (![self.refreshChoice.text isEqualToString:self.refreshValue]) {
        self.reconfigNecessary = YES;
    }
    self.refreshChoice.text = self.refreshValue;
    
    self.goToRefresh = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.reconfigNecessary = NO;
    
    self.SettingsTable.delegate = self;
    
    // Set RefreshChoice text
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"]) {
        char plural = [[[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"] characterAtIndex:[[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"].length -1];
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"intervalChoice"] > 1 && plural != 's') {
            NSString *pluriel = [NSString stringWithFormat:@"%@s", [[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"]];
            self.refreshValue = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"], pluriel];
        } else {
            self.refreshValue = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"], [[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"]];
        }
    } else {
        self.refreshValue = @"1 jour";
    }
    self.refreshChoice.text = self.refreshValue;
    
    // Set Datas & Images Sizes
    self.size = [[AppDelegate getSizeOf:APPLICATION_SUPPORT_PATH] floatValue];
    self.dataSize.text = [NSString stringWithFormat:@"%.02f ko", self.size];
    self.imagesSize.text = [NSString stringWithFormat:@"%.02f ko", [[AppDelegate getSizeOf:[NSString stringWithFormat:@"%@Images", APPLICATION_SUPPORT_PATH]] floatValue]];
    
    // Set Mode Cache
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cache"]) {
        [self.cacheMode setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"cache"] animated:YES];
    } else {
        [self.cacheMode setOn:NO];
    }
    
    // Set Roaming Mode
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"roaming"]) {
        [self.roamingMode setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"roaming"] animated:YES];
    } else {
        [self.roamingMode setOn:YES];
    }
    @synchronized(self) {
        cacheIsEnabled = self.cacheMode.isOn;
        roamingIsEnabled = self.roamingMode.isOn;
    }
    
    // If conflictual situation, block in Settings view
    if ((self.cacheMode.isOn && self.size == 0.0) || (appDel.roamingSituation && !self.roamingMode.isOn)) {
        self.navigationItem.hidesBackButton = YES;
    } else {
        self.navigationItem.hidesBackButton = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cacheModeValueChanged:(id)sender {
    @synchronized(self){
        cacheIsEnabled = self.cacheMode.isOn;
        self.reconfigNecessary = YES;
        if (self.cacheMode.isOn && self.size == 0.0) {
            self.navigationItem.hidesBackButton = YES;
        } else {
            self.navigationItem.hidesBackButton = NO;
        }
    }
}

- (IBAction)roamingValueChanged:(id)sender {
    @synchronized(self){
        roamingIsEnabled = self.roamingMode.isOn;
        self.reconfigNecessary = YES;
        if (appDel.roamingSituation && !self.roamingMode.isOn) {
            self.navigationItem.hidesBackButton = YES;
        } else {
            self.navigationItem.hidesBackButton = NO;
        }
    }
}

#pragma mark - Table View
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView cellForRowAtIndexPath:indexPath] isEqual:self.downloadDataCell])
    {
        @synchronized(self){
            if (self.cacheMode.isOn) {
                UIAlertView *alertConflict = [[UIAlertView alloc] initWithTitle:@"Conflictual Situation" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
                alertConflict.message = @"Impossible to download content. The cache mode is enabled : it blocks the downloading. Disable it for performing this action.";
                [alertConflict show];
            } else {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                self.reconfigNecessary = YES;
                // Download all
                @try {
                    forceDownloading = YES;
                    [appDel performSelectorInBackground:@selector(configureApp) withObject:appDel];
                }
                @finally {
                    self.reconfigNecessary = YES;
                }
            }
        }
    } else if ([[tableView cellForRowAtIndexPath:indexPath] isEqual:self.deleteCacheCell]) {
        @synchronized(self){
            @try {
                NSFileManager *fm = [NSFileManager defaultManager];
                
                if ([fm contentsOfDirectoryAtPath:APPLICATION_SUPPORT_PATH error:nil].count > 0) {
                    NSError *err = nil;
                    for (NSString *file in [fm contentsOfDirectoryAtPath:APPLICATION_SUPPORT_PATH error:&err]) {
                        [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", APPLICATION_SUPPORT_PATH, file] error:&err];
                    }
                    if (err) {
                        // TODO : throw exception
                        NSLog(@"An error occured during the Deleting of cache : %@", err);
                        NSException *e = [NSException exceptionWithName:err.localizedDescription reason:err.localizedFailureReason userInfo:err.userInfo];
                        @throw e;
                    }
                    self.errorMsg = [NSString stringWithFormat:@"The deleting of files is done."];
                    UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Deleting Successful" message:self.errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertNoConnection show];
                    
                } else {
                    self.errorMsg = [NSString stringWithFormat:@"The cache is already cleaned."];
                    UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Deleting Not Necessary" message:self.errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertNoConnection show];
                }
            }
            @catch (NSException *e) {
                // TODO : alertView pour informer de l'erreur
                self.errorMsg = [NSString stringWithFormat:@"An error occured during the Deleting of cache : %@, reason : %@", e.name, e.reason];
                UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"An Error Occured" message:self.errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertNoConnection show];
            }
            @finally {
                self.reconfigNecessary = YES;
                // Refresh dataSize & imagesSize
                self.dataSize.text = [NSString stringWithFormat:@"%.02f ko", [[AppDelegate getSizeOf:APPLICATION_SUPPORT_PATH] floatValue]];
                self.imagesSize.text = [NSString stringWithFormat:@"%.02f ko", [[AppDelegate getSizeOf:[NSString stringWithFormat:@"%@Images", APPLICATION_SUPPORT_PATH]] floatValue]];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 1 :
            return 10.0f;
        case 2:
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                return 20.0f;
            } else {
                return 50.0f;
            }
            break;
        case 3:
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                return 20.0f;
            } else {
                return 25.0f;
            }
            break;
        case 4:
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                return 20.0f;
            } else {
                return 50.0f;
            }
            break;
        case 5:
            return 80.0f;
            break;
        default:
            return 20.0f;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        switch (section) {
            case 2:
                return 10.0f;
                break;
            case 3:
                return 25.0f;
                break;
            case 4:
                return 25.0f;
                break;
            case 5:
                return 50.0f;
                break;
            default:
                return 30.0f;
                break;
        }
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
    UILabel *sectionFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, tableView.frame.size.width - 5, 60)];
    sectionFooterLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    sectionFooterLabel.textColor = [UIColor grayColor];
    [sectionFooterView addSubview:sectionFooterLabel];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sectionFooterLabel.numberOfLines = 2;
        sectionFooterView.frame = CGRectMake(0, 0, tableView.frame.size.width, 30);
        sectionFooterLabel.frame = CGRectMake(5, 0, tableView.frame.size.width - 5, 30);
    } else {
        sectionFooterLabel.numberOfLines = 5;
    }
    
    
    switch (section) {
        case 2:
            sectionFooterLabel.text = @"Attention ! Le chargement de toutes les données peut prendre du temps et l'application sera indisponible pendant le chargement.";
            return sectionFooterView;
            break;
        case 3:
            sectionFooterLabel.text = @"Activer le mode cache empêche l'application de télécharger de nouvelles données.";
            if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
                sectionFooterLabel.frame = CGRectMake(5, 0, tableView.frame.size.width - 5, 40);
                sectionFooterView.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
            }
            return sectionFooterView;
            break;
        case 4:
            sectionFooterLabel.text = @"Activer le roaming autorise l'application à charger les données à l'étranger (sauf si vous avez interdit le roaming sur votre iPhone).";
            return sectionFooterView;
            break;
        case 5:
            sectionFooterLabel.text = [NSString stringWithFormat:@"Attention ! Toutes les données de l'application seront supprimées. \r\r\rVsMobile %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
            sectionFooterLabel.numberOfLines = 5;
                sectionFooterLabel.frame = CGRectMake(5, 0, tableView.frame.size.width - 5, 80);
                sectionFooterView.frame = CGRectMake(0, 0, tableView.frame.size.width, 80);
            return sectionFooterView;
            break;
        default:
            return sectionFooterView;
            break;
    }
}

@end
