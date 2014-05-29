//
//  ThumbsUpPrefController.h
//  ThumbsUpPref
//
//  Created by Zaid Elkurdi on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

@interface ThumbsUpPrefController : PSListController
{
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier;
- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;
- (void)followOnTwitter:(PSSpecifier*)specifier;
- (void)sendEmail:(PSSpecifier*)specifier;
- (void)makeDonation:(PSSpecifier*)specifier;

@end