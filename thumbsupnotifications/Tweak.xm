#import <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>

/////////
void handle_pandoravoteup() {
	NSLog(@"CALLING VOTE UP!");
	id NowPlayingController = [objc_getClass("NowPlayingController") sharedInstance];
	[NowPlayingController ratePositive];
}

static __attribute__((constructor)) void PandoraVoteUpInitialize() {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandoravoteup, CFSTR("me.zaid.pandoravoteup"), NULL, 0);
}
/////////
void handle_pandoravotedown() {
	id NowPlayingController = [objc_getClass("NowPlayingController") sharedInstance];
	[NowPlayingController rateNegative];
}

static __attribute__((constructor)) void PandoraVoteDownInitialize() {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandoravotedown, CFSTR("me.zaid.pandoravotedown"), NULL, 0);
}
/////
void handle_pandorabookmarkartist() {
	id NowPlayingController = [objc_getClass("NowPlayingController") sharedInstance];
	[NowPlayingController bookmarkArtist];
}

static __attribute__((constructor)) void PandoraBookmarkArtistInitialize() {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandorabookmarkartist, CFSTR("me.zaid.pandorabookmarkartist"), NULL, 0);
}
////////
void handle_pandorabookmarksong() {
	id NowPlayingController = [objc_getClass("NowPlayingController") sharedInstance];
	[NowPlayingController bookmarkSong];
    }
static __attribute__((constructor)) void PandoraBookmarkSongInitialize() {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandorabookmarksong, CFSTR("me.zaid.pandorabookmarksong"), NULL, 0);
}
/////////
static __attribute__((constructor)) void PandoraDarwinRegister()
{ 
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandoravoteup, CFSTR("me.zaid.pandoravoteup"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandoravotedown, CFSTR("me.zaid.pandoravotedown"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandorabookmarkartist, CFSTR("me.zaid.pandorabookmarkartist"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandorabookmarksong, CFSTR("me.zaid.pandorabookmarksong"), NULL, 0);
}