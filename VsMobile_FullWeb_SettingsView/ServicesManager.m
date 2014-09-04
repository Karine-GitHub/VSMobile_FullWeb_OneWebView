//
//  ServicesManager.m
//  VsMobile_FullWeb_OneWebview
//
//  Created by admin on 9/3/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "ServicesManager.h"
#import "AppDelegate.h"

@interface ServicesManager ()

@end

@implementation ServicesManager

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
    self.appMenu = [[NSMutableArray alloc] init];
    if (APPLICATION_FILE != Nil) {
        self.nbMenuItem = 0;
        for (NSMutableDictionary *page in [APPLICATION_FILE objectForKey:@"Pages"]) {
            if (![[page objectForKey:@"TemplateType"] isEqualToString:@"Menu"]) {
                self.appMenu[self.nbMenuItem] = page;
                self.nbMenuItem++;
                NSIndexPath *indexPathTable = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[indexPathTable] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        NSLog(@"Dico : %d, Nb d'item dans le menu : %d", self.appMenu.count, self.nbMenuItem);
        self.navigationItem.title = @"Mes services";
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        for (UIView *view in cell.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                
            }
        }
    }
    
    //[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:self.refreshDuration forKey:@"durationChoice"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickCheckBox:(id)sender {
    if (!self.isChecked) {
        [sender setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateNormal];
        self.isChecked = YES;
    }
    
    else if (self.isChecked) {
        [sender setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
        self.isChecked = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.appMenu.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImage *lock = [UIImage imageNamed:@"20-gear2.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:lock];
    imgView.frame = CGRectMake(cell.frame.size.width - 90, 20 * indexPath.row/2, 26, 28);
    [cell addSubview:imgView];
    
    UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [checkBox setFrame:CGRectMake(cell.frame.size.width - 40, 20 * indexPath.row/2, 25, 25)];
    [checkBox setTag:indexPath.row];
    //[checkBox setBackgroundColor: UIColor.grayColor];
    //[checkBox setTintColor:UIColor.clearColor];
    checkBox.opaque = NO;
    [checkBox setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateNormal];
    [checkBox addTarget:self action:@selector(clickCheckBox:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:checkBox];
    
    NSArray *arr = cell.subviews;
    
    self.itemMenu = self.appMenu[indexPath.row];
    
    if ([[self.itemMenu  objectForKey:@"Title"] isKindOfClass:[NSNull class]]) {
        cell.textLabel.text = @"No Name property";
    } else {
        cell.textLabel.text = [[self.itemMenu  objectForKey:@"Title"] description];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    UILabel *sectionHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, tableView.frame.size.width - 5, 30)];
    sectionHeaderLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    sectionHeaderLabel.textColor = [UIColor grayColor];
    sectionHeaderLabel.numberOfLines = 2;
    sectionHeaderLabel.text = @"Choisissez les services à afficher et à synchroniser";
    [sectionHeaderView addSubview:sectionHeaderLabel];
    
    return sectionHeaderView;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
