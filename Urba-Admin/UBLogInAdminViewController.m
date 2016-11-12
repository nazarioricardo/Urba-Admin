//
//  UBLogInAdminViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/8/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBLogInAdminViewController.h"
#import "UBFIRDatabaseManager.h"
#import "UBMainViewController.h"
#import "Community.h"
#import "Constants.h"
#import "ActivityView.h"

@import Firebase;

@interface UBLogInAdminViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) NSString *communityName;
@property (weak, nonatomic) Community *currentCommunity;

@end

@implementation UBLogInAdminViewController

- (IBAction)donePressed:(id)sender {    
    [self logIn];
}

-(void)logIn {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];

    [[FIRAuth auth] signInWithEmail:@"jpnazario5@hotmail.com" password:@"iamjuan" completion:^(FIRUser *user, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error.description);
            [spinner removeSpinner];
        } else {
            
            FIRDatabaseReference *ref = [[FIRDatabase database] reference];
            ref = [ref child:@"community-admins"];
            [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                
                if ([snapshot hasChild:user.uid]) {
                    
                    NSLog(@"Admin log in was successful");
                    
                    [UBFIRDatabaseManager getAllValuesFromNode:@"communities"
                                                     orderedBy:@"admin-id"
                                                    filteredBy:[UBFIRDatabaseManager getCurrentUser]
                                            withSuccessHandler:^(NSArray *results) {
                                                
                                                NSDictionary<NSString *, NSString *> *dict = results[0];
                                                
                                                _communityName = dict[@"name"];
                                                
                                                
                                                NSLog(@"Results: %@", dict);
                                                [self performSegueWithIdentifier:logInSegue sender:self];
                                            }
                                                orErrorHandler:^(NSError *error) {
                                                    
                                                    NSLog(@"Error: %@", error.description);
                                                }];

                } else {
                    
                    NSLog(@"Attempted to log in without proper admin credentials");
                    [[FIRAuth auth] signOut:nil];
                    [spinner removeSpinner];
                }
            }];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    UINavigationController *nav = [segue destinationViewController];
    UBMainViewController *umvc = (UBMainViewController *)[nav topViewController];
    
    // Pass the selected object to the new view controller.
    [umvc setCurrentCommunity:_currentCommunity];
    [umvc setCommunityName:_communityName];
}

@end
