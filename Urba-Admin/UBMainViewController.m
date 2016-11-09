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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"communities"
                                     orderedBy:@"admin-id"
                                    filteredBy:[UBFIRDatabaseManager getCurrentUser]
                            withSuccessHandler:^(NSArray *results) {
                                
                                NSLog(@"Results: %@", results);
                                
                            }
                                orErrorHandler:^(NSError *error) {
                                    
                                    NSLog(@"Error: %@", error.description);
                                }];
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
