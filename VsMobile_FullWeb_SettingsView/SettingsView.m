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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.SettingsTable.delegate = self;
    // Set RefreshChoice text
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"intervalChoice"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"durationChoice"]) {
        self.refreshValue = [NSString stringWithFormat:@"%ld%@", (long)[[[NSUserDefaults standardUserDefaults] objectForKey:@"intervalChoice"] integerValue], [[[NSUserDefaults standardUserDefaults] objectForKey:@"durationChoice"] stringValue]];
    } else {
        self.refreshValue = @"None";
    }
    self.refreshChoice.text = self.refreshValue;
    
    // Set Datas & Images Sizes
    self.dataSize.text = [[self getSizeOf:APPLICATION_SUPPORT_PATH] stringValue];
    self.imagesSize.text = [[self getSizeOf:[NSString stringWithFormat:@"%@Images", APPLICATION_SUPPORT_PATH]] stringValue];
    
    // Set Cache & Roaming values
    self.enableCache = [NSNumber numberWithBool:self.cacheMode.isOn];
    self.enableRoaming = [NSNumber numberWithBool:self.roamingMode.isOn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSNumber *) getSizeOf:(NSString *)path
{
    // TODO : check dossier images (à soustraire du poids des datas)
    // NSFileSize works only with file
    NSNumber *number;
    unsigned long long ull = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    NSArray *directories = [fm contentsOfDirectoryAtPath:path error:&err];
    for (NSString *file in directories) {
        NSDictionary *attributes = [fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@%@",path, file] error:&err];
        ull += [attributes fileSize];
        
        // Check if subdirectories
        if ([[attributes fileType] isEqualToString:NSFileTypeDirectory]) {
            NSArray *subdir = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",path, file] error:&err];
            for (NSString *subFiles in subdir) {
                NSDictionary *attributes = [fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@%@/%@",path, file, subFiles] error:&err];
                ull += [attributes fileSize];
                // Check if sub-subdirectories
                
                if ([[attributes fileType] isEqualToString:NSFileTypeDirectory]) {
                    NSArray *subSubdir = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@",path, file, subFiles] error:&err];
                    for (NSString *subSubFiles in subSubdir) {
                        NSDictionary *attributes = [fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@%@/%@/%@",path, file, subFiles, subSubFiles] error:&err];
                        ull += [attributes fileSize];
                    }
                }
            }
        }
    }
    number = [NSNumber numberWithUnsignedLongLong:ull];
    return number;
}

- (IBAction)cacheModeValueChanged:(id)sender {
    self.enableCache = [self.enableCache initWithBool:self.cacheMode.isOn];
}

- (IBAction)roamingValueChanged:(id)sender {
    self.enableRoaming = [self.enableRoaming initWithBool:self.roamingMode.isOn];
    
    // TODO : Check iPhone setup for roaming
}

- (IBAction)dataLoadingClick:(id)sender {
    
    // Download all
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    @try {
        [ad setForceDownloading:YES];
        [ad configureApp];
    }
    @catch (NSException *exception) {
        NSString *errorMsg;
        if (ad.cacheIsEnabled) {
            errorMsg = @"Impossible to download content. The cache mode is enabled : it blocks the downloading. Please turn it off.";
        } else if (!ad.isDownloadedByNetwork) {
            errorMsg = @"Impossible to download content on the server. The network connection is too low or off. The application will shut down. Please try later.";
        }
        UIAlertView *alertLoadingFail = [[UIAlertView alloc] initWithTitle:@"Loading fails" message:errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertLoadingFail show];
    }
}

- (IBAction)deleteCacheClick:(id)sender {
    
    @try {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *err;
        for (NSString *file in [fm contentsOfDirectoryAtPath:APPLICATION_SUPPORT_PATH error:&err]) {
            NSLog(@"File = %@", file);
            [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", APPLICATION_SUPPORT_PATH, file] error:&err];
        }
        if (err) {
            // TODO : throw exception
            NSLog(@"An error occured during the Deleting of cache : %@", err);
            NSException *e = [NSException exceptionWithName:err.localizedDescription reason:err.localizedFailureReason userInfo:err.userInfo];
            @throw e;
        }
    }
    @catch (NSException *e) {
        // TODO : alertView pour informer de l'erreur
        self.errorMsg = [NSString stringWithFormat:@"An error occured during the Deleting of cache : %@, reason : %@", e.name, e.reason];
        UIAlertView *alertNoConnection = [[UIAlertView alloc] initWithTitle:@"An Error Occured" message:self.errorMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertNoConnection show];
    }
    @finally {
        // Refresh dataSize & imagesSize
        self.dataSize.text = [[self getSizeOf:APPLICATION_SUPPORT_PATH] stringValue];
        self.imagesSize.text = [[self getSizeOf:[NSString stringWithFormat:@"%@Images", APPLICATION_SUPPORT_PATH]] stringValue];
        NSLog(@"Datasize : %@    ImageSize : %@", self.dataSize.text , self.imagesSize.text);
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
            return 60.0f;
            break;
        case 3:
            return 40.0f;
            break;
        case 4:
            return 60.0f;
            break;
        case 5:
            return 60.0f;
            break;
        default:
            return 20.0f;
            break;
    }

}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
    UILabel *sectionFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, tableView.frame.size.width - 5, 55)];
    sectionFooterLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0];
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
            sectionFooterLabel.frame = CGRectMake(5, 0, tableView.frame.size.width - 5, 38);
            sectionFooterView.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
            return sectionFooterView;
            break;
        case 4:
            sectionFooterLabel.text = @"Activer le roaming autorise l'application à charger les données à l'étranger (sauf si vous avez interdit le roaming sur votre iPhone).";
            return sectionFooterView;
            break;
        case 5:
            sectionFooterLabel.text = [NSString stringWithFormat:@"Attention ! Toutes les données de l'application seront supprimées. \r\r\rVsMobile %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
            return sectionFooterView;
            break;
        default:
            return sectionFooterView;
            break;
    }
}

/*#pragma mark - Alert View
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView cancelButtonIndex] == buttonIndex) {
        // Fermer l'application
        //Home button
        UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(suspend)];
        // Wait while app is going background
        [NSThread sleepForTimeInterval:2.0];
        exit(0);
    }
}*/

@end
