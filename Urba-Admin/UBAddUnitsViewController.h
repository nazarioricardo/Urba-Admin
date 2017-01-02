//
//  UBAddUnitsViewController.h
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBAddUnitsViewController : UIViewController

@property (weak, nonatomic) NSString *superUnitId;
@property (weak, nonatomic) NSString *superUnitName;
@property (strong, nonatomic) NSDictionary *communityDict;

@end
