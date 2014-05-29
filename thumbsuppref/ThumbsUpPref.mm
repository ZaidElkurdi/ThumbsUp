//
//  ThumbsUpPrefController.m
//  ThumbsUpPref
//
//  Created by Zaid Elkurdi on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ThumbsUpPrefController.h"
#import <Preferences/PSSpecifier.h>

#define kSetting_Example_Name @"NameOfAnExampleSetting"
#define kSetting_Example_Value @"ValueOfAnExampleSetting"

#define kSetting_TemplateVersion_Name @"TemplateVersionExample"
#define kSetting_TemplateVersion_Value @"1.0"

#define kSetting_Text_Name @"TextExample"
#define kSetting_Text_Value @"Go Red Sox!"

#define kUrl_emailDev @"mailto:zaid.elkurdi@gmail.com?subject=ThumbsUp%202"
#define kUrl_FollowOnTwitter @"https://twitter.com/zaid_elkurdi"
#define kUrl_MakeDonation @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=U5BMSCLPFWL7E"


#define kPrefs_Path @"/var/mobile/Library/Preferences"
#define kPrefs_KeyName_Key @"key"
#define kPrefs_KeyName_Defaults @"defaults"

@implementation ThumbsUpPrefController

- (id)getValueForSpecifier:(PSSpecifier*)specifier
{
	id value = nil;
	
	NSDictionary *specifierProperties = [specifier properties];
	NSString *specifierKey = [specifierProperties objectForKey:kPrefs_KeyName_Key];
	
	// get 'value' with code only
	if ([specifierKey isEqual:kSetting_TemplateVersion_Name])
	{
		value = kSetting_TemplateVersion_Value;
	}
	else if ([specifierKey isEqual:kSetting_Example_Name])
	{
		value = kSetting_Example_Value;
	}
	// ...or get 'value' from 'defaults' plist or (optionally as a default value) with code
	else
	{
		// get 'value' from 'defaults' plist (if 'defaults' key and file exists)
		NSMutableString *plistPath = [[[NSMutableString alloc] initWithString:[specifierProperties objectForKey:kPrefs_KeyName_Defaults]] autorelease];
		if (plistPath)
		{
			NSDictionary *dict = (NSDictionary*)[self initDictionaryWithFile:&plistPath asMutable:NO];
			
			id objectValue = [dict objectForKey:specifierKey];
			
			if (objectValue)
			{
				value = [NSString stringWithFormat:@"%@", objectValue];
				NSLog(@"read key '%@' with value '%@' from plist '%@'", specifierKey, value, plistPath);
			}
			else
			{
				NSLog(@"key '%@' not found in plist '%@'", specifierKey, plistPath);
			}
			
			[dict release];
		}
		
		// get default 'value' from code
		if (!value)
		{
			if ([specifierKey isEqual:kSetting_Text_Name])
			{
				value = kSetting_Text_Value;
			}
			else if ([specifierKey isEqual:kSetting_Example_Name])
			{
				value = kSetting_Example_Value;
			}
		}
	}
	
	return value;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;
{
	NSDictionary *specifierProperties = [specifier properties];
	NSString *specifierKey = [specifierProperties objectForKey:kPrefs_KeyName_Key];
	
	// use 'value' with code only
	if ([specifierKey isEqual:kSetting_Example_Name])
	{
		// do something here with 'value'...
	}
	// ...or save 'value' to 'defaults' plist and (optionally) with code
	else
	{
		// save 'value' to 'defaults' plist (if 'defaults' key exists)
		NSMutableString *plistPath = [[[NSMutableString alloc] initWithString:[specifierProperties objectForKey:kPrefs_KeyName_Defaults]] autorelease];
		if (plistPath)
		{
			NSMutableDictionary *dict = (NSMutableDictionary*)[self initDictionaryWithFile:&plistPath asMutable:YES];
			[dict setObject:value forKey:specifierKey];
			[dict writeToFile:plistPath atomically:YES];
			[dict release];
            
			NSLog(@"saved key '%@' with value '%@' to plist '%@'", specifierKey, value, plistPath);
		}
		
		// use 'value' with code
		if ([specifierKey isEqual:kSetting_Example_Name])
		{
			// do something here with 'value'...
		}
	}
}

    
- (void)followOnTwitter:(PSSpecifier*)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_FollowOnTwitter]];
}

- (void)sendEmail:(PSSpecifier*)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_emailDev]];
}


- (void)makeDonation:(PSSpecifier *)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_MakeDonation]];
}

- (id)specifiers
{
	if (_specifiers == nil)
		_specifiers = [[self loadSpecifiersFromPlistName:@"ThumbsUpPref" target:self] retain];
	
	return _specifiers;
}

- (id)init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

@end