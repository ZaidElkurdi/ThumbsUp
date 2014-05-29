#import "objcipc.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "substrate.h"
#import <UIKit/UIKit.h>

@interface MetaViewController : NSObject
@end

@interface SpotifyAppDelegate : NSObject <UIApplicationDelegate>
{
    MetaViewController *_mainViewController;
}
@end

@interface NowPlayingViewController : NSObject
@property(retain, nonatomic) UISlider *progressSlider; // @synthesize progressSlider;
@end

@interface SessionController : NSObject
@end

@interface PlayController : NSObject
@property(readonly, nonatomic) int trackLength;
@property(nonatomic) int trackPosition;
@property(nonatomic) double position;
- (void)skipToNextTrack;
- (void)takePosition:(UISlider*)slider;
- (BOOL)isPlayingRadioContext;
@end


@interface SPTNowPlayingModel : NSObject
{
	BOOL _inCollection;
}
- (void)scrubToPosition:(double)arg1;
- (id)isInCollection;
@property(readonly, nonatomic) BOOL inCollection;
@end


@interface SPTNowPlayingTrackPosition : NSObject
- (void)scrubToPosition:(double)arg1;
@property(readonly, nonatomic) BOOL disallowSeeking;
@end

/* View related */

@interface SPTNowPlayingViewController :NSObject
- (void)radioThumbDownButtonTouchedUpInside:(id)arg1;
- (void)radioThumbUpButtonTouchedUpInside:(id)arg1;
- (void)collectionButtonTouchedUpInside:(id)arg1;
@end

@interface SPTNowPlayingCollectionButton : NSObject
@end

@interface SPTNowPlayingRadioThumbButton : NSObject
@end

@interface SPTNowPlayingView : NSObject
@property(readonly, nonatomic) SPTNowPlayingRadioThumbButton *radioThumbDownButton;
@property(readonly, nonatomic) SPTNowPlayingRadioThumbButton *radioThumbUpButton;
@property(readonly, nonatomic) SPTNowPlayingCollectionButton *collectionButton;
@end

static inline __attribute__((constructor)) void initSeek()
{
	@autoreleasepool
	{
		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"spotifySeek" handler:^NSDictionary *(NSDictionary *dict)
		{
			SpotifyAppDelegate *appDelegate = (SpotifyAppDelegate *)[[UIApplication sharedApplication] delegate];
			MetaViewController *metaView = MSHookIvar<MetaViewController*>(appDelegate, "_mainViewController");
			NowPlayingViewController *currentView = MSHookIvar<NowPlayingViewController*>(metaView, "_nowPlaying");
			SPTNowPlayingModel *currentModel = MSHookIvar<SPTNowPlayingModel*>(currentView, "_model");
			SPTNowPlayingTrackPosition *currentTrack = MSHookIvar<SPTNowPlayingTrackPosition*>(currentModel, "_trackPosition");

			double value = [[dict objectForKey:@"time"] doubleValue];
			[currentTrack scrubToPosition:value];
			return nil;
		}];

		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"getCollectionState" handler:^NSDictionary *(NSDictionary *dict)
		{
			SpotifyAppDelegate *appDelegate = (SpotifyAppDelegate *)[[UIApplication sharedApplication] delegate];
			MetaViewController *metaView = MSHookIvar<MetaViewController*>(appDelegate, "_mainViewController");
			NowPlayingViewController *currentView = MSHookIvar<NowPlayingViewController*>(metaView, "_nowPlaying");
			SPTNowPlayingModel *currentModel = MSHookIvar<SPTNowPlayingModel*>(currentView, "_model");

			NSString *valueString = [NSString stringWithFormat:@"%d", [currentModel isInCollection]];
			NSArray *objects = [NSArray arrayWithObjects: valueString, nil];
			NSArray *keys = [NSArray arrayWithObjects: @"status", nil];

			NSDictionary *returnDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
			return returnDict;
		}];

		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"getShuffleState" handler:^NSDictionary *(NSDictionary *dict)
		{
			SpotifyAppDelegate *appDelegate = (SpotifyAppDelegate *)[[UIApplication sharedApplication] delegate];
			MetaViewController *metaView = MSHookIvar<MetaViewController*>(appDelegate, "_mainViewController");
			NowPlayingViewController *currentView = MSHookIvar<NowPlayingViewController*>(metaView, "_nowPlaying");
			SessionController *currentSession = MSHookIvar<SessionController*>(currentView, "_sessionController");
    		PlayController *currentPlayer = MSHookIvar<PlayController*>(currentSession, "_playController"); 

			NSString *valueString = [NSString stringWithFormat:@"%d", [currentPlayer shuffle]];
			NSArray *objects = [NSArray arrayWithObjects: valueString, nil];
			NSArray *keys = [NSArray arrayWithObjects: @"status", nil];

			NSDictionary *returnDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
			return returnDict;
		}];

	}
}