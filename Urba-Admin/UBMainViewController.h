//
//  UBMainViewController.h
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/9/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) NSString *communityName;
@property (weak, nonatomic) NSString *communityKey;

@end
