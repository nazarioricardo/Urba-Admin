//
//  ActivityView.m
//  Urba
//
//  Created by Ricardo Nazario on 10/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "ActivityView.h"

@implementation ActivityView

+ (ActivityView *)loadSpinnerIntoView:(UIView *)superView {
    
    // Create a new view with the same frame size as the superView
    ActivityView *spinnerView = [[ActivityView alloc] initWithFrame:superView.bounds];
    
    if (!spinnerView) {
        return nil;
    }
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Set the resizing mask to avoid stretchy pants
    indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    indicator.center = superView.center;
    
    [spinnerView addSubview:indicator];
    [indicator startAnimating];
    
    // Just to show we've done something, let's make the background black
    spinnerView.backgroundColor = [UIColor blackColor];
    spinnerView.alpha = .50;
    
    // Add the spinner view to the superView. Boom.
    [superView addSubview:spinnerView];
    
    return  spinnerView;
}

-(void)removeSpinner {
    [super removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
