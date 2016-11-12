//
//  UBMainViewController.h
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/9/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Community.h"

@interface UBMainViewController : UIViewController

@property (weak, nonatomic) NSString *communityName;
@property (strong, nonatomic) Community *currentCommunity;

@end
