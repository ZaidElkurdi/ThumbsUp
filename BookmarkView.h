//
//  BookmarkView.h
//  
//
//  Created by Zaid Elkurdi on 1/24/14.
//
//

#ifndef _BookmarkView_h
#define _BookmarkView_h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageEffects.h"

@class UIButton, UIImage, UIImageView, UILabel;

@interface BookmarkView : UIView
{
    UILabel *_label;
    UIActivityIndicatorView *_indicator;
}

- (void)hide;
- (void)start;
- (void)showProgress;
- (void)dealloc;
- (id)initWithFrame:(CGRect)frame withPlayer:(int)player;
-(UIImage *)blurredSnapshot;

@end



#endif
