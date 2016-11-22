//
//  UBVerifyUserViewController.h
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/22/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBMainViewController.h"

@interface UBVerifyUserViewController : UIViewController

@property (weak, nonatomic) NSString *userName;
@property (weak, nonatomic) NSString *userId;
@property (weak, nonatomic) NSString *address;
@property (weak, nonatomic) NSString *requestId;
@property (weak, nonatomic) NSString *unitId;
@property (nonatomic) NSUInteger indexToRemove;
@property (weak, nonatomic) UBMainViewController *mainvc;

@end
