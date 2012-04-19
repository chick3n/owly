//
//  SettingsViewController.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-07.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
- (void)initializeSettingsData;
@end

@implementation SettingsViewController
@synthesize tableView               = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        _data = [[NSMutableArray alloc] init];
        _settings = [[MTSettings alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"MTDEF_SETTINGSTITLE", nil);
    
    [self initializeSettingsData];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_dark_background.png"]];
    
    NSURLRequest* urlreq = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://maps.google.com/maps?saddr=21+Gospel+Oak+Dr,+Ottawa,+ON+K2J+5G6,+Canada&daddr=99+Bank+St,+Ottawa,+ON+K1P+6G3,+Canada&hl=en&sll=44.465151,-73.981934&sspn=5.339076,6.888428&geocode=FZb7sgId5mR8-ylV9fZaO_3NTDEWIljP6Ku67w%3BFbcNtQId--d8-ynjW5xWVATOTDFAq7FOJf8pJQ&oq=99+bank+st&dirflg=r&ttype=arr&date=04%2F18%2F12&time=11:25pm&noexp=0&noal=0&sort=def&mra=ls&t=m&z=12&start=0"]];
    [_webView loadRequest:urlreq];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view addGestureRecognizer:_panGesture];
    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view removeGestureRecognizer:_panGesture];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
            (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

#pragma mark - SETTINGS SETUP

- (void)initializeSettingsData
{    
    //group account
    NSMutableArray* groupAccount = [[NSMutableArray alloc] init];
#if 0    
    [groupAccount addObject:[SettingsType settingsTypeForGroup:SGACCOUNTINFO Type:STTEXTBOX Title:NSLocalizedString(@"MTDEF_ACCOUNTNAME", nil) SubTitle:nil Data:[NSArray arrayWithObject:[_settings accountNameForArary]] Selected:0 ModificationCaller:@selector(updateAccountName:) Delegate:self]];
    [groupAccount addObject:[SettingsType settingsTypeForGroup:SGACCOUNTINFO Type:STPASSWORD Title:NSLocalizedString(@"MTDEF_ACCOUNTPASSWORD", nil)SubTitle:nil Data:[NSArray arrayWithObject:[_settings passwordForArray]] Selected:0 ModificationCaller:@selector(updatePassword:) Delegate:self]];
#endif
    [_data addObject:groupAccount];
    
    //application settings
    NSMutableArray* groupApplication = [[NSMutableArray alloc] init];
#if 0 //using proper language (localization now)
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STLIST Title:NSLocalizedString(@"MTDEF_LANGUAGE", nil) SubTitle:nil Data:kMTDLanguage Selected:_language ModificationCaller:@selector(updateLanguage:) Delegate:self]];
#endif
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STLIST Title:NSLocalizedString(@"MTDEF_CITY", nil) SubTitle:[_settings cityString] Data:kMTDCity Selected:[_settings cityPreference] ModificationCaller:@selector(updateCity:) Delegate:self]];
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STCHECKBOX Title:NSLocalizedString(@"MTDEF_HELPERCARDS", nil) SubTitle:nil Data:nil Selected:![_settings helperCards] ModificationCaller:@selector(updateAllHelperPages:) Delegate:self]];
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STLIST Title:NSLocalizedString(@"MTDEF_FIRSTLAUNCHSCREEN", nil) SubTitle:[_settings startupScreenString] Data:kMTDStartScreen(_language) Selected:[_settings startupScreen] ModificationCaller:@selector(updateStartupScreen:) Delegate:self]];
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STLIST Title:NSLocalizedString(@"MTDEF_ALERTSCHOICE", nil) SubTitle:[_settings notificationAlertTimeString] Data:kMTDAlerts Selected:[_settings notificationAlertTime] ModificationCaller:@selector(updateNotificationAlertTime:) Delegate:self]];
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STCHOICE Title:NSLocalizedString(@"MTDEF_UPDATEALERT", nil) SubTitle:nil Data:nil Selected:[_settings notificationUpdateTime] ModificationCaller:@selector(updateNotificationUpdateTimes:) Delegate:self]];
    
    [_data addObject:groupApplication];
    
    //data management access
    NSMutableArray* groupManagement = [[NSMutableArray alloc] init];
    [groupManagement addObject:[SettingsType settingsTypeForGroup:SGDATA Type:STOTHER Title:NSLocalizedString(@"MTDEF_MANAGENOTIFICATIONS", nil) SubTitle:nil Data:nil Selected:0 ModificationCaller:nil Delegate:self]];
    
    [_data addObject:groupManagement];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_data == nil) ? 0 : _data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* settings = [_data objectAtIndex:section];
    return (settings == nil || settings.count == 0) ? 0 : settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.textColor = [UIColor colorWithRed:89./255. green:89./255. blue:89./255. alpha:1.0];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        
        cell.detailTextLabel.textColor = [UIColor colorWithRed:140./255. green:140./255. blue:140./255. alpha:1.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveitcaNeue" size:14.0];
        
        cell.backgroundColor = [UIColor colorWithRed:245./255. green:247./255. blue:248./255. alpha:1.0];
    }
    
    NSArray* settings = [_data objectAtIndex:indexPath.section];
    if(settings == nil)
        return cell;
    
    SettingsType* setting = [settings objectAtIndex:indexPath.row];
    
    cell.textLabel.text = setting.title;
    if(setting.subTitle != nil)
        cell.detailTextLabel.text = setting.subTitle;
    else cell.detailTextLabel.text = @"";
    
    //reset
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (setting.type) {
        case STLIST:
        case STOTHER:
            //[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cardcell_arrow.png"]]];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            break;
        case STCHECKBOX:
            if(setting.selected == 0)
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            else
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            break;
        case STTEXTBOX:
        case STPASSWORD:
        case STCHOICE:
            [cell setAccessoryView:[setting accessoryView]];
            break;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
    UILabel* headerLabel;
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 4, 320, 32)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    headerLabel.textColor = [UIColor colorWithRed:154./255. green:154./255. blue:154./255. alpha:1.0];
    headerLabel.shadowColor = [UIColor whiteColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1.0);
    headerLabel.textAlignment = UITextAlignmentLeft;
    
    if(section == SGDATA && [[_data objectAtIndex:section] count] > 0)
        headerLabel.text = NSLocalizedString(@"MTDEF_MANAGEDATAHEADER", nil);
    else if(section == SGACCOUNTINFO && [[_data objectAtIndex:section] count] > 0)
        headerLabel.text = NSLocalizedString(@"MTDEF_ACCOUNTINFOHEADER", nil);
    else if(section == SGAPPLICATION && [[_data objectAtIndex:section] count] > 0)
        headerLabel.text = NSLocalizedString(@"MTDEF_APPSETTINGSHEADER", nil);
    
    [headerView addSubview:headerLabel];
    return headerView;
}

#if 0
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    UILabel* headerLabel;
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 32)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    headerLabel.textColor = [UIColor colorWithRed:154./255. green:154./255. blue:154./255. alpha:1.0];
    headerLabel.shadowColor = [UIColor whiteColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1.0);
    headerLabel.textAlignment = UITextAlignmentLeft;
    headerLabel.lineBreakMode = UILineBreakModeWordWrap;
    headerLabel.numberOfLines = 0;
    
    if(section == SGDATA)
        headerLabel.text = NSLocalizedString(@"MTDEF_MANAGEDATAFOOTER", nil);
    else if(section == SGACCOUNTINFO)
        headerLabel.text = NSLocalizedString(@"MTDEF_ACCOUNTINFOFOOTER", nil);
    else if(section == SGAPPLICATION)
        headerLabel.text = NSLocalizedString(@"MTDEF_APPSETTINGSFOOTER", nil);
    
    CGSize footerSize = [headerLabel.text sizeWithFont:headerLabel.font constrainedToSize:CGSizeMake(320, 480)];
    CGRect footerFrame = headerLabel.frame;
    footerFrame.size.height = footerSize.height;
    headerLabel.frame = footerFrame;
    footerFrame.origin.x = 0;
    headerView.frame = footerFrame;
    
    [headerView addSubview:headerLabel];
    return headerView;
}
#endif

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == SGDATA && [[_data objectAtIndex:section] count] > 0)
        return 32;
    else if(section == SGACCOUNTINFO && [[_data objectAtIndex:section] count] > 0)
        return 32;
    else if(section == SGAPPLICATION && [[_data objectAtIndex:section] count] > 0)
        return 32;
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* section = [_data objectAtIndex:indexPath.section];
    SettingsType* setting = [section objectAtIndex:indexPath.row];
    
    if(setting.type == STLIST)
    {
        SettingsListViewController* lvc = [[SettingsListViewController alloc] initWithNibName:@"SettingsListViewController" bundle:nil];
        lvc.setting = setting;
        lvc.panGesture = _panGesture;
        
        [self.navigationController pushViewController:lvc animated:YES];
        lvc = nil;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if(setting.type == STOTHER)
    {
        SettingsManageNotificationsViewController* nvc = [[SettingsManageNotificationsViewController alloc] initWithNibName:@"SettingsManageNotificationsViewController" bundle:nil];
        nvc.transpo = _transpo;
        nvc.language = _language;
        nvc.panGesture = _panGesture;
        nvc.navPanGesture = _navPanGesture;
        
        [self.navigationController pushViewController:nvc animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if(setting.type == STCHECKBOX)
    {
        setting.selected = !setting.selected;
        [setting selectedSettingHasChanged];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Settings Type Delegate

- (void)settingsTypeHasChanged:(id)setting
{
    if(setting == nil)
        return;
    
    if([setting class] != [SettingsType class])
        return;
    
    SettingsType* settingType = (SettingsType*)setting;
    
    if([_settings respondsToSelector:settingType.modificationCaller])
    {
        NSInvocation* inv = [NSInvocation invocationWithMethodSignature:[_settings methodSignatureForSelector:settingType.modificationCaller]];
        
        if(inv == nil)
            return;
        
        [inv setSelector:settingType.modificationCaller];
        [inv setTarget:_settings];
        
        if(settingType.type == STTEXTBOX || settingType.type == STPASSWORD)
        {
            if(settingType.data == nil)
                return;
            if(settingType.data.count <= 0)
                return;
            NSString* value = [settingType.data objectAtIndex:0];
            [inv setArgument:&value atIndex:2];
        }
        else
        {            
            int value = settingType.selected;
            [inv setArgument:&value atIndex:2];
        }
        
        [inv invoke];
        
        if(settingType.modificationCaller == @selector(updateLanguage:))
        {
            if(_language != settingType.selected)
            {
                _transpo.Language = settingType.selected;
                [_transpo updateUpdateNotificationsOnLanguageChange];
                [[NSNotificationCenter defaultCenter] postNotificationName:(NSString*)kFullAppRefresh object:self];
            }
        }
        else if(settingType.modificationCaller == @selector(updateCity:))
        {
            if([MTSettings cityPreference] != settingType.selected)
            {
                [_transpo removeAllUpdateNotifications];
                [[NSNotificationCenter defaultCenter] postNotificationName:(NSString*)kFullAppRefresh object:self];
            }
        }
        else if(settingType.modificationCaller == @selector(updateNotificationUpdateTimes:))
        {
            if(!settingType.selected)
            {
                [_transpo removeAllUpdateNotifications];
            }
        }
    }
    
    
}

@end
