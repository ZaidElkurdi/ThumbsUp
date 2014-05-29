#import <Headers.h>

/* Global variables */
static BOOL hasRun=FALSE;
static BOOL hasRunSpotify=FALSE;
static BOOL isControlCenter=FALSE;
static BOOL didChangeVolume=FALSE;
static SpringBoard *sb;
static MPUSystemMediaControlsView *mediaView;
static MPUSystemMediaControlsViewController *mediaController;

/* UI Additions*/
static UIButton *upbutton;
static UIButton *downbutton;
static UIButton *collectionButton;
static UIButton *shuffleButton;
static UIButton *repeatButton;
static BookmarkView *bookmarkView;

/* Used with app hooks */
static SPTNowPlayingViewController* currentView;
static SPTNowPlayingModel *currentModel;
static SessionController *currentSession;
static PlayController *currentPlayer;
static NSInteger mediaPlayer; // 1=pandora, 2=spotify

/* Creates plist on first run */
static void createPlist()
{
    NSMutableDictionary *rootObj = [NSMutableDictionary dictionaryWithCapacity:2];
    [rootObj setObject:@"no" forKey:@"like"];
    [rootObj setObject:@"no" forKey:@"isRadio"];
    [rootObj writeToFile:filePath atomically: TRUE];
}

/* Sets plist value to state */
static void setLikeState(BOOL state)
{
    NSString *value = (state == TRUE) ? @"yes" : @"no";

    bool fileExists=[[NSFileManager defaultManager] fileExistsAtPath:filePath];

    if (!fileExists)
        createPlist();

    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    [plistDict setValue:value forKey:@"like"];
    [plistDict writeToFile:filePath atomically: YES];
    [plistDict release];
}


/* Determine if device is on LS */
static BOOL isLockScreen()
{
    return [sb isLocked];
}

/* Determine if music app is playing */
static BOOL isMusicApp()
{
    Class SBMediaController = objc_getClass("SBMediaController");
    NSString* titleStr = [NSString stringWithFormat:@"%@",[[SBMediaController sharedInstance] nowPlayingApplication]];

    if ([titleStr rangeOfString:@"com.apple.Music"].location != NSNotFound)
        return TRUE;

    return FALSE;
}

static BOOL isSpotifyRadio()
{
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    NSString* radioCheck = [plistDict objectForKey:@"isRadio"];

    if ([radioCheck isEqualToString: @"yes"])
        return TRUE;

    return FALSE;
}

/* Checks if spotify is currently playing, for scrubbing */
static BOOL isSpotify()
{
    Class SBMediaController = objc_getClass("SBMediaController");
    NSString* titleStr = [NSString stringWithFormat:@"%@",[[SBMediaController sharedInstance] nowPlayingApplication]];

    if ([titleStr rangeOfString:@"com.spotify.client"].location != NSNotFound)
        return TRUE;

    return FALSE;
}

/* Determine if song is in collection */
static void getCollectionState(UIButton **newCollection, BOOL shouldChange)
{
    double currTime = 117.0;
    NSString *valueString = [NSString stringWithFormat:@"%f", currTime];

    NSArray *objects = [NSArray arrayWithObjects: valueString, nil];
    NSArray *keys = [NSArray arrayWithObjects: @"time", nil];

    if(shouldChange)
        notify_post("me.zaid.spotifytogglecollection");

    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [OBJCIPC sendMessageToAppWithIdentifier:@"com.spotify.client" messageName:@"getCollectionState" dictionary:dict replyHandler:^(NSDictionary *response)
    {
        NSLog(@"Received reply from Spotify: %@", response);
        NSString *valueString = [response objectForKey:@"status"];
        BOOL inCollection = [valueString boolValue];

        SEL imageSelector = @selector(currentImage);
        if([*newCollection respondsToSelector:imageSelector])
        {
            if(inCollection)
            {
                [*newCollection setBackgroundImage:collectionYes forState:UIControlStateNormal];
            }

            else
            {
                [*newCollection setBackgroundImage:collectionNo forState:UIControlStateNormal];
            }
        }
    }];
}

/* Determine if shuffle is on or off */
static void getShuffleState(UIButton **newShuffle, BOOL shouldChange)
{

    if(isMusicApp())
    {
        Class SBMediaController = objc_getClass("SBMediaController");

        if(shouldChange)
            [[SBMediaController sharedInstance] toggleShuffle];

        int shuffleMode = [[SBMediaController sharedInstance] shuffleMode];

        BOOL isShuffled = (shuffleMode==2) ? TRUE : FALSE;

        if(isControlCenter&&!isLockScreen())
        {
            if(isShuffled)
                [*newShuffle setBackgroundImage:shuffleYes forState:UIControlStateNormal];

            else
                [*newShuffle setBackgroundImage:shuffleNoCC forState:UIControlStateNormal];

            [upbutton setAlpha:1.0];
        }

        else
        {

            if(isShuffled)
            {
                NSLog(@"Setting to yes!");
                [*newShuffle setBackgroundImage:shuffleYes forState:UIControlStateNormal];
            }

            else
                [*newShuffle setBackgroundImage:shuffleNo forState:UIControlStateNormal];

            [upbutton setAlpha:1.0];
        }
        
    }

    else if(isSpotify() && !isSpotifyRadio())
    {
        double currTime = 1.0;
        NSString *valueString = [NSString stringWithFormat:@"%f", currTime];

        NSArray *objects = [NSArray arrayWithObjects: valueString, nil];
        NSArray *keys = [NSArray arrayWithObjects: @"time", nil];

        if(shouldChange)
            notify_post("me.zaid.spotifytoggleshuffle");

        NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [OBJCIPC sendMessageToAppWithIdentifier:@"com.spotify.client" messageName:@"getShuffleState" dictionary:dict replyHandler:^(NSDictionary *response)
        {
            NSLog(@"Received reply from Spotify: %@", response);
            NSString *valueString = [response objectForKey:@"status"];
            BOOL shuffleEnabled = [valueString boolValue];

            SEL imageSelector = @selector(currentImage);
            if([*newShuffle respondsToSelector:imageSelector])
            {
                if(isControlCenter&&!isLockScreen())
                {
                    UIImage *shuffleButton = (shuffleEnabled == 1) ? shuffleYes : shuffleNoCC;
                    [*newShuffle setBackgroundImage:shuffleButton forState:UIControlStateNormal];
                    [shuffleButton setAlpha:0.7];
                }

                else
                {
                    UIImage *shuffleButton = (shuffleEnabled == 1) ? shuffleYes : shuffleNo;
                    [*newShuffle setBackgroundImage:shuffleButton forState:UIControlStateNormal];
                    [shuffleButton setAlpha:1.0];
                }
            }
        }];
    }
}

/* Determine if song has been liked */
//static void getLikeState(UIButton **newUp, UIButton **newDown, UIButton **newCollection)
static void setButtonImages(UIButton **newUp, UIButton **newDown)
{
	SEL imageSelector = @selector(currentImage);

    if ([*newDown respondsToSelector:imageSelector] && !isMusicApp())
	{
        NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
        NSString* likecheck = [plistDict objectForKey:@"like"];
        isControlCenter = mediaView.frame.size.height < 150;

        /* Song is liked and Spotify/Pandora is playing */
		if ([likecheck isEqualToString: @"yes"])
		{
            if(isControlCenter&&!isLockScreen())
            {   
                [*newUp setBackgroundImage:upyes forState:UIControlStateNormal];
                [*newDown setBackgroundImage:downnocc forState:UIControlStateNormal];
                [downbutton setAlpha:0.7];
                [upbutton setAlpha:1.0];
            }

            else
            {
                [*newUp setBackgroundImage:upyes forState:UIControlStateNormal];
                [*newDown setBackgroundImage:downno forState:UIControlStateNormal];
                [upbutton setAlpha:1.0];
                [downbutton setAlpha:1.0];
            }

		}

        /* Song isn't like and Spotify/Pandora is playing */
		else
		{
            if(isControlCenter&&!isLockScreen())
            {
                [*newUp setBackgroundImage:upnocc forState:UIControlStateNormal];
                [*newDown setBackgroundImage:downnocc forState:UIControlStateNormal];
                [upbutton setAlpha:0.7];
                [downbutton setAlpha:0.7];
            }

            else
            {
                [*newUp setBackgroundImage:upno forState:UIControlStateNormal];
                [*newDown setBackgroundImage:downno forState:UIControlStateNormal];
                [upbutton setAlpha:1.0];
                [downbutton setAlpha:1.0];
            }

		}
    }
}

/* Checks if current music player is Spotify or Pandora */
static BOOL isCompatible()
{
    Class SBMediaController = objc_getClass("SBMediaController");
    NSString* titleStr = [NSString stringWithFormat:@"%@",[[SBMediaController sharedInstance] nowPlayingApplication]];

    if ([titleStr rangeOfString:@"com.pandora"].location != NSNotFound)
    {
		mediaPlayer=1;
        return YES;
    }

	if ([titleStr rangeOfString:@"com.spotify.client"].location != NSNotFound)
	{
        if(isSpotifyRadio())
        {
            mediaPlayer=2;
            return YES;
        }
	}

    if ([titleStr rangeOfString:@"com.apple.Music"].location != NSNotFound)
    {
        mediaPlayer=1;
        return YES;
    }

	return NO;

}

%hook _MPUSystemMediaControlsView
- (void)layoutSubviews
{
    if(isSpotify())
    {
        MPUChronologicalProgressView *chronProg = MSHookIvar<MPUChronologicalProgressView*>(self, "_timeInformationView");
        chronProg.scrubbingEnabled = TRUE;
    }

    %orig;
}
%end

%hook MPUChronologicalProgressView
- (void)detailScrubControllerDidEndScrubbing:(id)arg1
{
    %orig(arg1);
    if(isSpotify())
    {
        double currTime = MSHookIvar<double>(self, "_currentTime");
        NSString *valueString = [NSString stringWithFormat:@"%f", currTime];

        NSArray *objects = [NSArray arrayWithObjects: valueString, nil];
        NSArray *keys = [NSArray arrayWithObjects: @"time", nil];

        NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [OBJCIPC sendMessageToAppWithIdentifier:@"com.spotify.client" messageName:@"spotifySeek" dictionary:dict replyHandler:^(NSDictionary *response){}];
    }
}
%end

%hook _MPUSystemMediaControlsView
- (id)initWithFrame:(CGRect)arg1
{
    CGRect newArg = CGRectMake(arg1.origin.x, arg1.origin.y-25, arg1.size.width, arg1.size.height);
    return %orig(newArg);
}
%end

%hook MPUSystemMediaControlsViewController
- (void)viewWillAppear:(_Bool)arg1
{
    mediaController = self;
    mediaView = MSHookIvar<MPUSystemMediaControlsView*>(self, "_mediaControlsView");
    MPUTransportControlsView *buttonsView = MSHookIvar<MPUTransportControlsView*>(mediaView, "_transportControlsView");


	if (mediaView)
    {
        /* Check if Pandora or Spotify is playing*/
        BOOL CConLS = isLockScreen() && isControlCenter;
        if(isCompatible() && !CConLS)
		{
            CGRect frame = [[UIScreen mainScreen] bounds];
            NSInteger width = frame.size.width;
            NSInteger height = frame.size.height;

            //bool isiPhone5 = CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136));

            NSInteger xorigin = buttonsView.frame.origin.x+buttonsView.frame.size.width;
            NSInteger xbegin = buttonsView.frame.origin.x-40;
            NSInteger yorigin = buttonsView.frame.origin.y+buttonsView.frame.size.height;

			if (!hasRun)
			{
                upbutton = [[UIButton alloc] initWithFrame:(CGRectMake(xorigin, yorigin-40, 40, 40))];
                downbutton = [[UIButton alloc] initWithFrame:(CGRectMake(xbegin, yorigin-40, 40, 40))];
                hasRun=TRUE; /* Buttons have been initalized */
            }

            if(!hasRunSpotify)
            {
                collectionButton = [[UIButton alloc] initWithFrame:(CGRectMake(xorigin, yorigin+18, 25, 25))];
                hasRunSpotify=TRUE; /* Collection button has been initalized */
            }

            else if(hasRun)
            {
                upbutton.hidden = NO;
                downbutton.hidden = NO;

                if(hasRunSpotify)
                    collectionButton.hidden = NO;
            }

            if(isMusicApp())
            {
                [upbutton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                [downbutton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];

                [upbutton addTarget:self action:@selector(shuffleTapped:)forControlEvents:UIControlEventTouchUpInside];
                [downbutton addTarget:self action:@selector(repeatTapped:)forControlEvents: UIControlEventTouchUpInside];
            }

            else if(isCompatible())
            {
                [upbutton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                [downbutton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];

                [upbutton addTarget:self action:@selector(upvote:)forControlEvents:UIControlEventTouchUpInside];
                [downbutton addTarget:self action:@selector(downvote:)forControlEvents: UIControlEventTouchUpInside];
            }

            else if(isSpotifyRadio())
            {
                [collectionButton addTarget:self action:@selector(collectionTapped:)forControlEvents: UIControlEventTouchUpInside];
            }

            upbutton.showsTouchWhenHighlighted = TRUE;
            downbutton.showsTouchWhenHighlighted = TRUE;
            collectionButton.showsTouchWhenHighlighted = TRUE;

            /*Add detector for long press (bookmark function) */
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            [upbutton addGestureRecognizer:longPress];
            [longPress release];

            /* Add buttons/views to media view */
            [mediaView addSubview:downbutton];
            [mediaView addSubview:upbutton];
            [mediaView addSubview:collectionButton];

            mediaController.view.clipsToBounds = FALSE;
            mediaView.clipsToBounds = FALSE;

            /* Set initial state of buttons */
            if(!isMusicApp())
                setButtonImages(&upbutton, &downbutton);

            if(isSpotifyRadio())
                getCollectionState(&collectionButton, FALSE);

            if(isSpotify() && !isSpotifyRadio())
                getShuffleState(&upbutton, FALSE);

            else if(isMusicApp())
            {
                getShuffleState(&upbutton, FALSE);
                downbutton.hidden = TRUE;
            }

            //getLikeState(&upbutton, &downbutton);
        }
    }

    %orig(arg1);
}

- (void)dealloc
{
    if(hasRun)
    {
        upbutton.hidden = YES;
        downbutton.hidden = YES;
    }

    if(hasRunSpotify)
        collectionButton.hidden = YES;

    %orig;
}

/***************************
New Functions
***************************/

%new(v@:@@)
-(void)upvote:(id)sender
{
	if(mediaPlayer==1)
	{
		notify_post("me.zaid.pandoravoteup");
	}
	if(mediaPlayer==2)
	{
		notify_post("me.zaid.spotifyvoteup");
	}

    if(isControlCenter)
    {
        [upbutton setBackgroundImage:upyes forState:UIControlStateNormal];
        [downbutton setBackgroundImage:downnocc forState:UIControlStateNormal];
    }
    else
    {
        [upbutton setBackgroundImage:upyes forState:UIControlStateNormal];
        [downbutton setBackgroundImage:downno forState:UIControlStateNormal];
    }

	setLikeState(TRUE);
}

%new(v@:@@)
-(void)collectionTapped:(id)sender
{
    getCollectionState(&collectionButton, TRUE);
}

%new(v@:@@)
-(void)shuffleTapped:(UIButton**)newShuffle
{
    if(isMusicApp())
        getShuffleState(&upbutton, TRUE);

    else
        getShuffleState(&upbutton, TRUE);
}

%new(v@:@@)
-(void)downvote:(id)sender
{
    if(mediaPlayer==1)
	{
		notify_post("me.zaid.pandoravotedown");
	}
	if(mediaPlayer==2)
	{
		notify_post("me.zaid.spotifyvotedown");
	}

    setLikeState(FALSE);

    if(isControlCenter)
    {
        [upbutton setBackgroundImage:upnocc forState:UIControlStateNormal];
        [downbutton setBackgroundImage:downyes forState:UIControlStateNormal];
    }
    else
    {
        [upbutton setBackgroundImage:upno forState:UIControlStateNormal];
        [downbutton setBackgroundImage:downyes forState:UIControlStateNormal];
    }
	
}

%new(v@:@@)
-(void)skip:(id)sender
{
    Class SBMediaController = objc_getClass("SBMediaController");
	[[SBMediaController sharedInstance] changeTrack:1];
    [[SBMediaController sharedInstance] play];
}

%new(v@:@@)
- (void)longPress:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
            if(mediaPlayer==1)
                notify_post("me.zaid.pandorabookmarksong");
            if(mediaPlayer==2)
                notify_post("me.zaid.spotifystarsong");

            CGRect frame = [[UIScreen mainScreen] bounds];

            NSInteger xpoint = frame.size.width/2;
            NSInteger ypoint = ((frame.size.height)/2)-100;

            CGRect bookmarkFrame = CGRectMake(xpoint-75, ypoint, 150, 150);
            bookmarkView = [[BookmarkView alloc] initWithFrame:bookmarkFrame withPlayer:mediaPlayer];
            [mediaController.view addSubview:bookmarkView];
            [bookmarkView start];
            [bookmarkView hide];
    }
}
%end

/*******************
SpringBoard Hook
*******************/
%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1
{
    sb = self;
    %orig(arg1);
}
%end
/*******************
SBControlCenterViewController Hook
*******************/

%hook SBControlCenterViewController
- (void)controlCenterWillPresent
{
    isControlCenter = TRUE;
    %orig;
}
- (void)controlCenterDidDismiss
{
    isControlCenter = FALSE;
    %orig;
}
%end

/*******************
SBMediaController Hook
*******************/

%hook SBMediaController
- (void)_nowPlayingInfoChanged
{
	if(isCompatible())
	{
		if(hasRun)
		{
            downbutton.hidden = FALSE;
            upbutton.hidden = FALSE;
            setButtonImages(&upbutton, &downbutton);

            if(isSpotifyRadio())
            {
                collectionButton.hidden = FALSE;
                getCollectionState(&collectionButton, FALSE);
            }

            if(isSpotify() && !isSpotifyRadio())
            {
                getShuffleState(&upbutton, FALSE);
            }
		}
	}

    else
    {
        downbutton.hidden = TRUE;
        upbutton.hidden = TRUE;
    }

    if(!isSpotifyRadio)
        collectionButton.hidden = TRUE;

    %orig;
}

%end

/***********************
Pandora Hooks 
***********************/

%hook NowPlayingController
- (void)ratePositive
{
    notify_post("me.zaid.pandoraAppvoteup");
    %orig;
}

- (void)radioActiveTrackDidChange
{
    notify_post("me.zaid.pandoratrackskip");
    %orig;
}

%end


/************************** 
Spotify Hooks
**************************/
%hook MetaViewController
- (id)initWithWindow:(id)arg1
{
    currentView = MSHookIvar<SPTNowPlayingViewController*>(self, "_nowPlaying");
    return %orig(arg1);
}
%end

%hook SPTNowPlayingViewController
- (void)nowPlayingModel:(SPTNowPlayingModel*)model didChangeTrackWithAnimation:(int)arg2 newTrack:(BOOL)arg3 interactively:(BOOL)arg4
{
    if(arg3==true)
    {
        notify_post("me.zaid.pandoratrackskip");
    }

    if([model isPlayingFromRadio]==FALSE)
    {
        notify_post("me.zaid.spotifynotradio");
    }
    else
    {
        notify_post("me.zaid.spotifyisradio");
    }    

    SPTrack *currentTrack = currentPlayer.currentTrack;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if(currentTrack.isAd)
    {
        float oldVolume = [MPMusicPlayerController applicationMusicPlayer].volume;
        [prefs setObject:[NSNumber numberWithFloat:oldVolume] forKey:@"oldVolume"];

        float volume = 0.0; 
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:volume];

        didChangeVolume=TRUE;
    }

    else if(didChangeVolume)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        float volume = [[prefs objectForKey:@"oldVolume"] floatValue];

        [[MPMusicPlayerController applicationMusicPlayer] setVolume:volume];

        didChangeVolume=FALSE;
    }

    %orig(model,arg2,arg3,arg4);
}

- (void)viewDidAppear:(BOOL)arg1
{
	currentModel = MSHookIvar<SPTNowPlayingModel*>(self, "_model");
    currentSession = MSHookIvar<SessionController*>(self, "_sessionController");
    currentPlayer = MSHookIvar<PlayController*>(currentSession, "_playController"); 
    currentView = self;

    if([currentModel isPlayingFromRadio]==FALSE)
    {
        notify_post("me.zaid.spotifynotradio");
    }
    else
    {
        notify_post("me.zaid.spotifyisradio");
    }

	%orig(arg1);
}
%end

%hook NowPlayingRadioPanelVC
- (void)thumbUpTrack:(id)arg1
{
	notify_post("me.zaid.pandoraAppvoteup");
	%orig(arg1);
}

- (void)currentTrackChanged
{
    NSLog(@"Track changing");

    if([currentModel isPlayingFromRadio]==FALSE)
    {
        notify_post("me.zaid.spotifynotradio");
    }
    else
    {
        notify_post("me.zaid.spotifyisradio");
    }

	notify_post("me.zaid.pandoratrackskip");

	%orig;
}

%end

%hook SPTNowPlayingModel
- (BOOL)radioThumbUpTrack:(id *)arg1 completion:(id*)arg2
{
    notify_post("me.zaid.pandoraAppvoteup");
    return %orig(arg1,arg2);
}
%end
/****************************
Spotify Notifications
****************************/

/* Tap Collection Button */
void handle_spotifytogglecollection()
{
    if(currentView != NULL)
    {
        SPTNowPlayingView *actualView = MSHookIvar<SPTNowPlayingView*>(currentView, "_nowPlayingView"); 
        SPTNowPlayingCollectionButton *collButton = actualView.collectionButton;
       [currentView collectionButtonTouchedUpInside:collButton];
    }
}

/* Tap Shuffle Button */
void handle_spotifytoggleshuffle()
{
    if(currentPlayer != NULL)
    {
       [currentPlayer toggleShuffle];
    }
}

/* Thumb Up Radio */
void handle_spotifyvoteup()
{
    if(currentView != NULL)
    {
        SPTNowPlayingView *actualView = MSHookIvar<SPTNowPlayingView*>(currentView, "_nowPlayingView"); 
        SPTNowPlayingRadioThumbButton *upThumb = actualView.radioThumbUpButton;
	   [currentView radioThumbUpButtonTouchedUpInside:upThumb];
    }
}

/* Thumb Down Radio */
void handle_spotifyvotedown()
{
    if(currentView != NULL)
    {
        SPTNowPlayingView *actualView = MSHookIvar<SPTNowPlayingView*>(currentView, "_nowPlayingView"); 
        SPTNowPlayingRadioThumbButton *downThumb = actualView.radioThumbDownButton;
       [currentView radioThumbDownButtonTouchedUpInside:downThumb];
    }
}

/* Star current Song */
void handle_spotifystarsong()
{
    if(currentSession != NULL)
    { 
        PlayController  *playController = MSHookIvar<PlayController*>(currentSession, "_playController"); 
        SPTrack *currentTrack = playController.currentTrack;
        currentTrack.isStarredForCurrentUser=TRUE;
    }
}

/* System Notifications */
void handle_pandoraAppvoteup()
{
    NSString *filePath = @"/var/mobile/Library/Preferences/Zaid.ThumbsUpPref.plist";
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    [plistDict setValue:@"yes" forKey:@"like"];
    [plistDict writeToFile:filePath atomically: YES];
    [plistDict release];
}


void handle_pandoratrackskip()
{
    NSString *filePath = @"/var/mobile/Library/Preferences/Zaid.ThumbsUpPref.plist";
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    [plistDict setValue:@"no" forKey:@"like"];
    [plistDict writeToFile:filePath atomically: YES];
    [plistDict release];
}


void handle_spotifyNotRadio() 
{
    NSString *filePath = @"/var/mobile/Library/Preferences/Zaid.ThumbsUpPref.plist";
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    [plistDict setValue:@"no" forKey:@"isRadio"];
    [plistDict writeToFile:filePath atomically: YES];
    [plistDict release];
}

void handle_spotifyisRadio()
{
    NSString *filePath = @"/var/mobile/Library/Preferences/Zaid.ThumbsUpPref.plist";
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    [plistDict setValue:@"yes" forKey:@"isRadio"];
    [plistDict writeToFile:filePath atomically: YES];
    [plistDict release];
}

// /* Pandora Notifications */
void handle_pandoravoteup()
{
    id NowPlayingController = [objc_getClass("NowPlayingController") sharedInstance];
    [NowPlayingController ratePositive];
}

void handle_pandoravotedown()
{
    id NowPlayingController = [objc_getClass("NowPlayingController") sharedInstance];
    [NowPlayingController rateNegative];
}

void handle_pandorabookmarkartist()
{
    id NowPlayingController = [objc_getClass("NowPlayingController") sharedInstance];
    [NowPlayingController bookmarkArtist];
}


void handle_pandorabookmarksong()
{
    id NowPlayingController = [objc_getClass("NowPlayingController") sharedInstance];
    [NowPlayingController bookmarkSong];
}

static __attribute__((constructor)) void SpotifyDarwinRegister()
{ 
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandoravoteup, CFSTR("me.zaid.pandoravoteup"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandoravotedown, CFSTR("me.zaid.pandoravotedown"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandorabookmarkartist, CFSTR("me.zaid.pandorabookmarkartist"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandorabookmarksong, CFSTR("me.zaid.pandorabookmarksong"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandoraAppvoteup, CFSTR("me.zaid.pandoraAppvoteup"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandoratrackskip, CFSTR("me.zaid.pandoratrackskip"), NULL, 0);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_spotifyNotRadio, CFSTR("me.zaid.spotifynotradio"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_spotifyisRadio, CFSTR("me.zaid.spotifyisradio"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_spotifyvoteup, CFSTR("me.zaid.spotifyvoteup"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_spotifyvotedown, CFSTR("me.zaid.spotifyvotedown"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_spotifyvotedown, CFSTR("me.zaid.spotifyvotedown"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_spotifystarsong, CFSTR("me.zaid.spotifystarsong"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_spotifytogglecollection, CFSTR("me.zaid.spotifytogglecollection"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_spotifytoggleshuffle, CFSTR("me.zaid.spotifytoggleshuffle"), NULL, 0);
}   