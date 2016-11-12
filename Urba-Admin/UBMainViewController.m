//
//  UBMainViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/9/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBMainViewController.h"
#import "UBFIRDatabaseManager.h"
#import "Constants.h"
#import "ActivityView.h"

@interface UBMainViewController ()

@end

@implementation UBMainViewController

- (void)getCommunity {
    
//    [UBFIRDatabaseManager getAllValuesFromNode:@"communities"
//                                     orderedBy:@"admin-id"
//                                    filteredBy:[UBFIRDatabaseManager getCurrentUser]
//                            withSuccessHandler:^(NSArray *results) {
//                                
//                                NSDictionary<NSString *, NSString *> *dict = results[0];
//                                
//                                _communityName = dict[@"name"];
//                                
//                                NSLog(@"Results: %@", _communityName);
//                            }
//                                orErrorHandler:^(NSError *error) {
//                                    
//                                    NSLog(@"Error: %@", error.description);
//                                }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self getCommunity];
    NSLog(@"Community name %@", _currentCommunity.communityName);
    self.navigationItem.title = _currentCommunity.communityName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
