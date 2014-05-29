//
//  BookmarkView.m
//  
//
//  Created by Zaid Elkurdi on 1/24/14.
//
//

#import "BookmarkView.h"

@implementation BookmarkView

- (id)initWithFrame:(CGRect)frame withPlayer:(int)player
{
    self = [super initWithFrame:frame];
    if (self)
    {
        /* background initialization */
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithPatternImage:[self blurredSnapshot]];

        /* label initialization */
        CGPoint labelFrameOrigin = CGPointMake(frame.origin.x, frame.origin.y/2);
        CGSize labelFrameSize = CGSizeMake(frame.size.width, 20);
    	CGRect labelFrame = CGRectMake(frame.origin.x-85, (labelFrameOrigin.y/2)-20, labelFrameSize.width, labelFrameSize.height);
    	_label = [[UILabel alloc] initWithFrame:labelFrame];
        NSString *text = player==1 ? @"Song Bookmarked" : @"Song Starred";
    	_label.text = text;
        _label.textColor = [UIColor whiteColor];
        _label.lineBreakMode = NSLineBreakByClipping;
        _label.textAlignment = UITextAlignmentCenter;
    	[self addSubview: _label];

        CGPoint indicatorFrameOrigin = CGPointMake(frame.origin.x, frame.origin.y+10);
        CGSize indicatorFrameSize = CGSizeMake(frame.size.width, 40);
        CGRect indicatorFrame = CGRectMake(frame.origin.x-100, indicatorFrameOrigin.y-20, indicatorFrameSize.width, indicatorFrameSize.height);
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.transform = CGAffineTransformMakeScale(2, 2);
        _indicator.frame = indicatorFrame;
        _indicator.center = CGPointMake(frame.origin.x-15, frame.origin.y-(frame.size.height/2)-20);
        [self addSubview: _indicator];

        self.hidden = TRUE;

    }

    return self;
}

- (void)dealloc
{
    [_indicator release];
    _indicator=nil;

    [_label release];
    _label=nil;

    //[super dealloc];
}

-(UIImage *)blurredSnapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);

    [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];

    // Get the snapshot
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];

    UIGraphicsEndImageContext();

    return blurredSnapshotImage;
}

- (void)hide
{

    [UIView animateWithDuration:0.5 delay:2.0 options:0 animations:^{
         self.alpha = 0.0f;
         _label.alpha = 0.0f;
         _indicator.alpha = 0.0f;
     } 

     completion:^(BOOL finished) {
        self.hidden = YES;
     }];
    [_indicator stopAnimating];
}
- (void)showProgress
{
    [_indicator startAnimating];
}
- (void)start
{
    self.alpha = 0.0f;
    self.hidden = FALSE;
    _indicator.hidden = FALSE;

    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
         self.alpha = 1.0f;
         _label.alpha = 1.0f;
         _indicator.alpha = 1.0f;
     }

    completion:^(BOOL finished) {

     }];

    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(showProgress) object:nil];
    [thread start];
}

@end
