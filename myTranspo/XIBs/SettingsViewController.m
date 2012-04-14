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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - SETTINGS SETUP

- (void)initializeSettingsData
{    
    //group account
    NSMutableArray* groupAccount = [[NSMutableArray alloc] init];
    [groupAccount addObject:[SettingsType settingsTypeForGroup:SGACCOUNTINFO Type:STTEXTBOX Title:NSLocalizedString(@"MTDEF_ACCOUNTNAME", nil) SubTitle:nil Data:[NSArray arrayWithObject:[_settings accountNameForArary]] Selected:0 ModificationCaller:@selector(updateAccountName:) Delegate:self]];
    [groupAccount addObject:[SettingsType settingsTypeForGroup:SGACCOUNTINFO Type:STPASSWORD Title:NSLocalizedString(@"MTDEF_ACCOUNTPASSWORD", nil)SubTitle:nil Data:[NSArray arrayWithObject:[_settings passwordForArray]] Selected:0 ModificationCaller:@selector(updatePassword:) Delegate:self]];
    
    [_data addObject:groupAccount];
    
    //application settings
    NSMutableArray* groupApplication = [[NSMutableArray alloc] init];
#if 0 //using proper language (localization now)
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STLIST Title:NSLocalizedString(@"MTDEF_LANGUAGE", nil) SubTitle:nil Data:kMTDLanguage Selected:_language ModificationCaller:@selector(updateLanguage:) Delegate:self]];
#endif
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STLIST Title:NSLocalizedString(@"MTDEF_CITY", nil) SubTitle:nil Data:kMTDCity Selected:[_settings cityPreference] ModificationCaller:@selector(updateCity:) Delegate:self]];
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STCHECKBOX Title:NSLocalizedString(@"MTDEF_HELPERCARDS", nil) SubTitle:nil Data:nil Selected:![_settings helperCards] ModificationCaller:@selector(updateAllHelperPages:) Delegate:self]];
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STLIST Title:NSLocalizedString(@"MTDEF_FIRSTLAUNCHSCREEN", nil) SubTitle:nil Data:kMTDStartScreen(_language) Selected:[_settings startupScreen] ModificationCaller:@selector(updateStartupScreen:) Delegate:self]];
    [groupApplication addObject:[SettingsType settingsTypeForGroup:SGAPPLICATION Type:STLIST Title:NSLocalizedString(@"MTDEF_ALERTSCHOICE", nil) SubTitle:nil Data:kMTDAlerts Selected:[_settings notificationAlertTime] ModificationCaller:@selector(updateNotificationAlertTime:) Delegate:self]];
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
    return (settings == nil) ? 0 : settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray* settings = [_data objectAtIndex:indexPath.section];
    if(settings == nil)
        return cell;
    
    SettingsType* setting = [settings objectAtIndex:indexPath.row];
    
    cell.textLabel.text = setting.title;
    
    //reset
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (setting.type) {
        case STLIST:
        case STOTHER:
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == SGDATA)
        return NSLocalizedString(@"MTDEF_MANAGEDATAHEADER", nil);
    else if(section == SGACCOUNTINFO)
        return NSLocalizedString(@"MTDEF_ACCOUNTINFOHEADER", nil);
    else if(section == SGAPPLICATION)
        return NSLocalizedString(@"MTDEF_APPSETTINGSHEADER", nil);
    
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == SGDATA)
        return NSLocalizedString(@"MTDEF_MANAGEDATAFOOTER", nil);
    else if(section == SGACCOUNTINFO)
        return NSLocalizedString(@"MTDEF_ACCOUNTINFOFOOTER", nil);
    else if(section == SGAPPLICATION)
        return NSLocalizedString(@"MTDEF_APPSETTINGSFOOTER", nil);
    
    return @"";
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
