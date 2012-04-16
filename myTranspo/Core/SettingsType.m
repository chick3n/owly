//
//  SettingsType.m
//  myTranspo
//
//  Created by Vincent Mancini on 12-04-07.
//  Copyright (c) 2012 Vice Interactive. All rights reserved.
//

#import "SettingsType.h"

@interface SettingsType ()
{
    UIControl*          _accessoryView;
}

- (id)initForGroup:(SettingGroup)group 
              Type:(SettingTypes)type 
             Title:(NSString*)title 
          SubTitle:(NSString*)subTitle 
              Data:(NSArray*)data 
          Selected:(NSInteger)selected 
ModificationCaller:(SEL)modificationCaller 
          Delegate:(id<SettingsTypeDelegate>)delegate;
- (void)setAccessoryView;
- (void)accessoryViewChanged:(id)sender;
@end

@implementation SettingsType
@synthesize group               = _group;
@synthesize type                = _type;
@synthesize title               = _title;
@synthesize subTitle            = _subTitle;
@synthesize data                = _data;
@synthesize selected            = _selected;
@synthesize delegate            = _delegate;
@synthesize modificationCaller  = _modificationCaller;
@synthesize dataCaller          = _dataCaller;

+ (id)settingsTypeForGroup:(SettingGroup)group 
                      Type:(SettingTypes)type 
                     Title:(NSString*)title 
                  SubTitle:(NSString*)subTitle 
                      Data:(NSArray*)data 
                  Selected:(NSInteger)selected 
        ModificationCaller:(SEL)modificationCaller 
                  Delegate:(id<SettingsTypeDelegate>)delegate
{
    return [[SettingsType alloc] initForGroup:group Type:type Title:title SubTitle:subTitle Data:data Selected:selected ModificationCaller:modificationCaller Delegate:delegate];
}

- (id)initForGroup:(SettingGroup)group 
              Type:(SettingTypes)type 
             Title:(NSString*)title 
          SubTitle:(NSString*)subTitle 
              Data:(NSArray*)data 
          Selected:(NSInteger)selected 
ModificationCaller:(SEL)modificationCaller 
          Delegate:(id<SettingsTypeDelegate>)delegate
{
    self = [super init];
    if(self)
    {
        _group = group;
        _type = type;
        _title = title;
        _subTitle = subTitle;
        _data = data;
        _selected = selected;
        _modificationCaller = modificationCaller;
        _delegate = delegate;
        
        [self setAccessoryView];
    }
    return self;
}

- (UIControl*)accessoryView
{
    return _accessoryView;
}

- (void)setAccessoryView
{
    if(_type == STCHOICE)
    {
        _accessoryView = [[UISwitch alloc] init];
        [_accessoryView addTarget:self action:@selector(accessoryViewChanged:) forControlEvents:UIControlEventValueChanged];
        ((UISwitch*)_accessoryView).on = _selected;
    }
    else if(_type == STTEXTBOX || _type == STPASSWORD)
    {
        _accessoryView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 130, 20)];
        ((UITextField*)_accessoryView).clearButtonMode = UITextFieldViewModeWhileEditing;
        ((UITextField*)_accessoryView).autocapitalizationType = UITextAutocapitalizationTypeNone;
        ((UITextField*)_accessoryView).spellCheckingType = UITextSpellCheckingTypeNo;
        ((UITextField*)_accessoryView).textColor = [UIColor colorWithRed:140./255. green:140./255. blue:140./255. alpha:1.0];
        ((UITextField*)_accessoryView).font = [UIFont fontWithName:@"HelveitcaNeue" size:16.];
        if(_type == STPASSWORD)
            ((UITextField*)_accessoryView).secureTextEntry = YES;
        [_accessoryView addTarget:self action:@selector(accessoryViewChanged:) forControlEvents:UIControlEventEditingChanged];
        
        if(_data != nil)
        {
            if(_data.count > 0)
            {
                NSString* text = [_data objectAtIndex:0];
                if(text != nil)
                    ((UITextField*)_accessoryView).text = text;
            }
        }
    }
}

- (void)selectedSettingHasChanged
{
    if([_delegate conformsToProtocol:@protocol(SettingsTypeDelegate)])
        [_delegate settingsTypeHasChanged:self];
}

- (void)accessoryViewChanged:(id)sender
{
    if(_type == STCHOICE)
    {
        UISwitch* clickedAccessoryView = (UISwitch*)sender;
        _selected = clickedAccessoryView.on;
        [self selectedSettingHasChanged];
    }
    else if(_type == STTEXTBOX || _type == STPASSWORD)
    {
        UITextField* clickedTextField = (UITextField*)sender;
        _data = nil;
        _data = [NSArray arrayWithObject:clickedTextField.text];
        [self selectedSettingHasChanged];
    }
}

@end
