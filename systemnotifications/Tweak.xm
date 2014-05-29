#import <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>
/////////
void handle_pandoraAppvoteup() {
NSString *filePath = @"/var/mobile/Library/Preferences/Zaid.ThumbsUpPref.plist";
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    [plistDict setValue:@"yes" forKey:@"like"];
    [plistDict writeToFile:filePath atomically: YES];
    [plistDict release];
}

static __attribute__((constructor)) void PandoraAppVoteUpInitialize() {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandoraAppvoteup, CFSTR("me.zaid.pandoraAppvoteup"), NULL, 0);
}
/////////

void handle_pandoratrackskip()
{
	NSString *filePath = @"/var/mobile/Library/Preferences/Zaid.ThumbsUpPref.plist";
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    [plistDict setValue:@"no" forKey:@"like"];
    [plistDict writeToFile:filePath atomically: YES];
    [plistDict release];
}

static __attribute__((constructor)) void PandoraTrackSkipInitialize() {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_pandoratrackskip, CFSTR("me.zaid.pandoratrackskip"), NULL, 0);
}
/////////
void handle_spotifyNotRadio() {
NSString *filePath = @"/var/mobile/Library/Preferences/Zaid.ThumbsUpPref.plist";
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    [plistDict setValue:@"no" forKey:@"isRadio"];
    [plistDict writeToFile:filePath atomically: YES];
    [plistDict release];
}

static __attribute__((constructor)) void spotifyNotRadioInitialize() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_spotifyNotRadio, CFSTR("me.zaid.spotifynotradio"), NULL, 0);
}
/////////
void handle_spotifyisRadio() {
NSString *filePath = @"/var/mobile/Library/Preferences/Zaid.ThumbsUpPref.plist";
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    [plistDict setValue:@"yes" forKey:@"isRadio"];
    [plistDict writeToFile:filePath atomically: YES];
    [plistDict release];
}

static __attribute__((constructor)) void spotifyIsRadioInitialize() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)handle_spotifyisRadio, CFSTR("me.zaid.spotifyisradio"), NULL, 0);
}
/////////
