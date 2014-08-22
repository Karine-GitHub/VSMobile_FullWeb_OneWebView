//
//  SettingsView.m
//  VsMobile_FullWeb_SettingsView
//
//  Created by admin on 8/14/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "SettingsView.h"
#import "AppDelegate.h"

@interface SettingsView ()

@end

@implementation SettingsView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

/* Add observer on : 
    - the method configureApp of AppDelegate Class : it is called in background during the loading of datas. Necessary for refreshing datas & images size.
    - when RefreshSettings view will disapear for saving user choice 
*/
- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureApp:) name:@"ConfigureAppNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshApp:) name:@"RefreshAppNotification" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureApp:(NSNotification *)notification {
    
    // Check if settings view is visible
    NSLog(@"[SettingsView_ConfigureApp] Visible view controller = %@", self.navigationController.visibleViewController);
    if ([self.navigationController.visibleViewController isKindOfClass:[SettingsView class]])
    {
        // Alert user that downloading is finished
        self.errorMsg = [NSString stringWithFormat:@"The downloading of files is done."];
        UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"Downloading Successful" message:self.errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertNoConnection show];
        // Set Datas & Images Sizes
        
        self.dataSize.text = [NSString stringWithFormat:@"%.02f ko", [[AppDelegate getSizeOf:APPLICATION_SUPPORT_PATH] floatValue]];
        self.imagesSize.text = [NSString stringWithFormat:@"%.02f ko", [[AppDelegate getSizeOf:[NSString stringWithFormat:@"%@Images", APPLICATION_SUPPORT_PATH]] floatValue]];
    }
}
- (void)refreshApp:(NSNotification *)notification {
    // Set RefreshChoice text when RefreshSettingsView disapear
    NSLog(@"Interval = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"]);
    NSLog(@"Duration = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"]);
    
    char plural = [[[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"] characterAtIndex:[[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"].length -1];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"intervalChoice"] > 1 && plural != 's') {
        NSString *pluriel = [NSString stringWithFormat:@"%@s", [[NSUserDefaults standardUserDefaults] stringForKey:@"durationChoice"]];
        self.refreshValue = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"], pluriel];
    } else {
        self.refreshValue = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"], [[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"]];
    }
    
    NSLog(@"Value = %@", self.refreshValue);
    if (![self.refreshChoice.text isEqualToString:self.refreshValue]) {
        self.reconfigNecessary = YES;
    }
    self.refreshChoice.text = self.refreshValue;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Notify that settings was modified
    if (self.reconfigNecessary) {
        NSNotification * notif = [NSNotification notificationWithName:@"SettingsIsFinishedNotification" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notif];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.SettingsTable.delegate = self;
    
    // Set RefreshChoice text
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"]) {
        self.refreshValue = [NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"], [[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"]];
    } else {
        self.refreshValue = @"1 jour";
    }
    self.refreshChoice.text = self.refreshValue;
    
    // Set Datas & Images Sizes
    self.dataSize.text = [NSString stringWithFormat:@"%.02f ko", [[AppDelegate getSizeOf:APPLICATION_SUPPORT_PATH] floatValue]];
    self.imagesSize.text = [NSString stringWithFormat:@"%.02f ko", [[AppDelegate getSizeOf:[NSString stringWithFormat:@"%@Images", APPLICATION_SUPPORT_PATH]] floatValue]];
    
    // Set Cache & Roaming values
    self.enableCache = [NSNumber numberWithBool:self.cacheMode.isOn];
    self.enableRoaming = [NSNumber numberWithBool:self.roamingMode.isOn];
    
    self.downloadData.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cacheModeValueChanged:(id)sender {
    self.enableCache = [NSNumber numberWithBool:self.cacheMode.isOn];
    self.reconfigNecessary = YES;
}

- (IBAction)roamingValueChanged:(id)sender {
    self.enableRoaming = [NSNumber numberWithBool:self.roamingMode.isOn];
    self.reconfigNecessary = YES;
    // TODO : Check iPhone setup for roaming
}

- (IBAction)dataLoadingClick:(id)sender {
    
    // Download all
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    @try {
        [ad setForceDownloading:YES];
        NSLog(@"Avant runInBackground");

        [ad performSelectorInBackground:@selector(configureApp) withObject:ad];
        NSLog(@"Après runInBackground");

    }
    @catch (NSException *exception) {
        if (ad.cacheIsEnabled) {
            self.errorMsg = @"Impossible to download content. The cache mode is enabled : it blocks the downloading. Please turn it off.";
        } else if (!ad.isDownloadedByNetwork) {
            self.errorMsg = @"Impossible to download content on the server. The network connection is too low or off. Please try later.";
        }
        UIAlertView *alertLoadingFail = [[UIAlertView alloc] initWithTitle:@"Downloading fails" message:self.errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertLoadingFail show];
    }
    @finally {
        self.reconfigNecessary = YES;
    }
}

- (IBAction)deleteCacheClick:(id)sender {

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
            
        }
        else {
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Add choice to NSUserDefaults
    if ([segue.identifier isEqualToString:@"settings"]) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.enableCache forKey:@"cache"]];
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.enableRoaming forKey:@"roaming"]];
    }
}

#pragma mark - Table View
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 2:
            return 70.0f;
            break;
        case 3:
            return 40.0f;
            break;
        case 4:
            return 70.0f;
            break;
        case 5:
            return 80.0f;
            break;
        default:
            return 20.0f;
            break;
    }

}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
    UILabel *sectionFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, tableView.frame.size.width - 5, 60)];
    sectionFooterLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    sectionFooterLabel.textColor = [UIColor grayColor];
    sectionFooterLabel.numberOfLines = 5;
        [sectionFooterView addSubview:sectionFooterLabel];

    switch (section) {
        case 2:
            sectionFooterLabel.text = @"Attention ! Le chargement de toutes les données peut prendre du temps et l'application sera indisponible pendant le chargement.";
            return sectionFooterView;
            break;
        case 3:
            sectionFooterLabel.text = @"Activer le mode cache empêche l'application de télécharger de nouvelles données.";
            sectionFooterLabel.frame = CGRectMake(5, 0, tableView.frame.size.width - 5, 40);
            sectionFooterView.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
            return sectionFooterView;
            break;
        case 4:
            sectionFooterLabel.text = @"Activer le roaming autorise l'application à charger les données à l'étranger (sauf si vous avez interdit le roaming sur votre iPhone).";
            return sectionFooterView;
            break;
        case 5:
            sectionFooterLabel.text = [NSString stringWithFormat:@"Attention ! Toutes les données de l'application seront supprimées. \r\r\rVsMobile %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
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
