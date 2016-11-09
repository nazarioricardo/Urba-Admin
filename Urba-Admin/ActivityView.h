//
//  ActivityView.h
//  Urba
//
//  Created by Ricardo Nazario on 10/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityView : UIView

+ (ActivityView *)loadSpinnerIntoView:(UIView *)superView;

- (void)removeSpinner;

@end
