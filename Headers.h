//
//  Headers.h
//  
//
//  Created by Zaid Elkurdi on 1/24/14.
//
//

#ifndef _Headers_h
#define _Headers_h
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <MediaPlayer/MediaPlayer.h>
#import <notify.h>
#import <BookmarkView.h>                
#import "objcipc.h"
//#import <Frameworks/AppSupport/CPDistributedMessagingCenter.h>

#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/ThumbsUpResources.bundle"

NSBundle *bundle = [[[NSBundle alloc] initWithPath:kBundlePath] autorelease];

NSString *UNimagePath = [bundle pathForResource:@"voteupno" ofType:@"png"];
NSString *DNimagePath = [bundle pathForResource:@"votedownno" ofType:@"png"];
NSString *UYimagePath = [bundle pathForResource:@"voteupyes" ofType:@"png"];
NSString *DYimagePath = [bundle pathForResource:@"votedownyes" ofType:@"png"];
NSString *UNCCagePath = [bundle pathForResource:@"voteupnocc" ofType:@"png"];
NSString *DNCCimagePath = [bundle pathForResource:@"votedownnocc" ofType:@"png"];
NSString *CNO = [bundle pathForResource:@"collectionNo" ofType:@"png"];
NSString *CYES = [bundle pathForResource:@"collectionYes" ofType:@"png"];
NSString *SNO = [bundle pathForResource:@"shuffleNo" ofType:@"png"];
NSString *SNOCC = [bundle pathForResource:@"shuffleNoCC" ofType:@"png"];
NSString *SYES = [bundle pathForResource:@"shuffleYes" ofType:@"png"];


UIImage* upno = [UIImage imageWithContentsOfFile:UNimagePath];
UIImage* downno = [UIImage imageWithContentsOfFile:DNimagePath];
UIImage* upyes = [UIImage imageWithContentsOfFile:UYimagePath];
UIImage* downyes = [UIImage imageWithContentsOfFile:DYimagePath];
UIImage* upnocc = [UIImage imageWithContentsOfFile:UNCCagePath];
UIImage* downnocc = [UIImage imageWithContentsOfFile:DNCCimagePath];
UIImage* collectionNo = [UIImage imageWithContentsOfFile:CNO];
UIImage* collectionYes = [UIImage imageWithContentsOfFile:CYES];
UIImage* shuffleNo = [UIImage imageWithContentsOfFile:SNO];
UIImage* shuffleNoCC = [UIImage imageWithContentsOfFile:SNOCC];
UIImage* shuffleYes = [UIImage imageWithContentsOfFile:SYES];


NSString *filePath = @"/var/mobile/Library/Preferences/Zaid.ThumbsUpPref.plist";

NSString *preferencePath = @"/var/mobile/Library/Preferences/Zaid.ThumbsUpPref.plist";

@interface SBMediaController : NSObject
{
}
- (BOOL)isPlaying;
+ (id)sharedInstance;
- (id)nowPlayingApplication;
- (_Bool)play;
- (_Bool)changeTrack:(int)arg1;
- (double)trackElapsedTime;
@end

@interface SPTrack : NSObject
@property(nonatomic) BOOL isStarredForCurrentUser;
@property(readonly, nonatomic) BOOL isAd;
@end

@interface PMTrack : NSObject
@end

@interface MPUTransportControlsView : UIView
- (id)_rightButton;
@end

@interface CPDistributedMessagingCenter : NSObject
@end

@interface SPFeatureManager : NSObject

@property(retain, nonatomic) NSArray *enabledFeaturesClasses; // @synthesize enabledFeaturesClasses=_enabledFeaturesClasses;
@property(retain, nonatomic) NSMutableDictionary *features;
@end

@interface SPTNowPlayingViewController :NSObject
- (void)radioThumbDownButtonTouchedUpInside:(id)arg1;
- (void)radioThumbUpButtonTouchedUpInside:(id)arg1;
- (void)collectionButtonTouchedUpInside:(id)arg1;
@end

@interface MPAVController : NSObject
@property(nonatomic) double currentTime;
@end

@interface MPUChronologicalProgressView : UIView
{
	_Bool _scrubbingEnabled;
	double _currentTime;
}
@property(nonatomic) _Bool scrubbingEnabled;
@end
@protocol PMTrack
@end

@interface NowPlayingController : NSObject
- (void)bookmarkSong;
- (void)bookmarkArtist;
- (void)ratePositive;
- (void)rateNegative;
@end

@interface SPTNowPlayingCollectionButton : NSObject
@end

@interface SPTNowPlayingModel : NSObject
- (BOOL)isPlayingFromRadio;
@end

@interface SPTTableViewCell : NSObject
@property(nonatomic) BOOL interactive; // @synthesize interactive=_interactive;
@property(nonatomic) BOOL disabled;
@end
@interface SPTPlayerRestrictions : NSObject
@property(nonatomic) BOOL disallowMuting; // @synthesize disallowMuting=_disallowMuting;
@property(nonatomic) BOOL disallowSeeking; // @synthesize disallowSeeking=_disallowSeeking;
@property(nonatomic) BOOL disallowShuffling; // @synthesize disallowShuffling=_disallowShuffling;
@property(nonatomic) BOOL disallowRepeatingTrack; // @synthesize disallowRepeatingTrack=_disallowRepeatingTrack;
@property(nonatomic) BOOL disallowRepeatingContext; // @synthesize disallowRepeatingContext=_disallowRepeatingContext;
@property(nonatomic) BOOL disallowResuming; // @synthesize disallowResuming=_disallowResuming;
@property(nonatomic) BOOL disallowPausing; // @synthesize disallowPausing=_disallowPausing;
@property(nonatomic) BOOL disallowSkippingTo; // @synthesize disallowSkippingTo=_disallowSkippingTo;
@property(nonatomic) BOOL disallowSkippingToNextTrack; // @synthesize disallowSkippingToNextTrack=_disallowSkippingToNextTrack;
@property(nonatomic) BOOL disallowSkippingToPreviousTrack; // @synthesize disallowSkippingToPreviousTrack=_disallowSkippingToPreviousTrack;
@property(nonatomic) BOOL disallowPeekingAtNextTrack; // @synthesize disallowPeekingAtNextTrack=_disallowPeekingAtNextTrack;
@property(nonatomic) BOOL disallowPeekingAtPreviousTrack;
@end

@interface SPTPlayerState : NSObject
{
	SPTPlayerRestrictions *_restrictions;
}
@end

@interface SBLockScreenView : NSObject
- (double)_mediaControlsHeight;
- (double)_mediaControlsY;
@end

@interface SpringBoard : UIApplication
- (_Bool)isLocked;
@end

@interface PlayController : NSObject
- (_Bool)isLocked;
@property(readonly, nonatomic) SPTrack *currentTrack;
@end

@interface SPTNowPlayingRadioThumbButton : NSObject
@end

@interface SPTNowPlayingView : NSObject
@property(readonly, nonatomic) SPTNowPlayingRadioThumbButton *radioThumbDownButton;
@property(readonly, nonatomic) SPTNowPlayingRadioThumbButton *radioThumbUpButton;
@property(readonly, nonatomic) SPTNowPlayingCollectionButton *collectionButton;
@end

@interface SPTProductStateMonitorController : NSObject
@end

@interface NowPlayingViewController : NSObject
- (void)trackActionsControllerToggledStar:(id)arg1;
- (void)viewWillAppear:(_Bool)arg1;
@property(readonly, nonatomic) SPTrack *currentTrack;
@property(retain, nonatomic) UISlider *progressSlider; // @synthesize progressSlider;
@end

@interface MPUSystemMediaControlsViewController : UIViewController
@end

@interface SessionController : NSObject
- (void)addToStarred:(id)arg1;
@end

@interface MPUSystemMediaControlsView : UIView
@end

@interface SBApplication : NSObject
@end

@interface NowPlayingRadioPanelVC : NSObject
- (void)thumbDownTrack:(id)arg1;
- (void)thumbUpTrack:(id)arg1;
@property(nonatomic) BOOL thumbedUpCurrentTrack;
@end

#endif
