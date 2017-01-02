//
//  UBSettingsViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBSettingsViewController.h"
#import "UBLogInAdminViewController.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *secEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *currentUserEmail;
@property (strong, nonatomic) NSString *currentUserId;
@property (strong, nonatomic) NSString *communityName;
@property (strong, nonatomic) NSString *communityId;

@end

@implementation UBSettingsViewController

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];    
}

- (IBAction)addPressed:(id)sender {
    
    [self createSecurityUser];
}

- (IBAction)signOutPressed:(id)sender {
    
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Sign out error: %@", signOutError);
        return;
    }
    
    // After sign out, go to log in screen
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UBLogInAdminViewController *livc = [storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
    [self presentViewController:livc animated:YES completion:nil];
    
    
}

- (IBAction)deletePressed:(id)sender {
    [self deleteCommunity];
}

-(void)createSecurityUser {
 
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [[FIRAuth auth] createUserWithEmail:_secEmailTextField.text
                               password:_passwordTextField.text
                             completion:^(FIRUser *user, NSError *error) {
                                 
                                 if (error) {
                                     NSLog(@"Error: %@", error.description);
                                     [spinner removeSpinner];
                                 } else {
                                     
                                     NSLog(@"Current user email: %@", _currentUserEmail);
                                     _ref = [[FIRDatabase database] reference];
                                     _ref = [[_ref child:@"security"] child:user.uid];
                                     [[_ref child:@"email"] setValue:user.email];
                                     [[_ref child:@"admin-email"] setValue:_currentUserEmail];
                                     [[_ref child:@"admin-id"] setValue:_currentUserId];
                                     [[_ref child:@"community-name"] setValue:_communityName];
                                     [[_ref child:@"community-id"] setValue:_communityId];
                                     
                                     [spinner removeSpinner];
                                 }
                             }];
}

-(void)deleteCommunity {
    
    __block NSString *commId;
    __block NSString *adminId;
    
    _ref = [[FIRDatabase database] reference];
    
    // Get community ID
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    FIRDatabaseQuery *commQuery = [[[_ref child:@"communities"] queryOrderedByChild:@"admin-id"] queryEqualToValue:currentUser.uid];
    
    [commQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        for (FIRDataSnapshot *community in snapshot.children) {
            
            commId = community.key;
            NSLog(@"Deleting COMM %@", commId);
            [[[_ref child:@"communities"] child:commId] removeValue];
            adminId = [snapshot.value valueForKeyPath:@"admin-id"];
        }
        
        // Remove all units
        FIRDatabaseQuery *unitQuery = [[[_ref child:@"units"] queryOrderedByChild:@"community-id"] queryEqualToValue:commId];
        [unitQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            
            for (FIRDataSnapshot *unit in snapshot.children) {
                NSLog(@"Deleting UNIT %@", unit.key);
                [[[_ref child:@"units"]child:unit.key] removeValue];
            }
            
            // Remove all super-units
            FIRDatabaseQuery *superQuery = [[[_ref child:@"super-units"] queryOrderedByChild:@"community-id"] queryEqualToValue:commId];
            [superQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                
                for (FIRDataSnapshot *superUnit in snapshot.children) {
                    NSLog(@"Deleting SUPER %@", superUnit.key);
                    [[[_ref child:@"super-units"] child:superUnit.key] removeValue];
                }
                
                // Remove Community Admin
                FIRDatabaseQuery *commAdminQuery = [[[_ref child:@"community-admins"] queryOrderedByChild:@"community-id"] queryEqualToValue:commId];
                [commAdminQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                   
                    for (FIRDataSnapshot *commAdmin in snapshot.children) {
                        [[[_ref child:@"community-admins"] child: commAdmin.key] removeValue];
                    }
                    
                    // Remove security
                    FIRDatabaseQuery *secQuery = [[[_ref child:@"security"] queryOrderedByChild:@"community-id"] queryEqualToValue:commId];
                    [secQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                        
                        for (FIRDataSnapshot *security in snapshot.children) {
                            
                            NSLog(@"Deleting SEC %@", security.key);
                            [[[_ref child:@"security"] child:security.key] removeValue];
                        }
                        
                        // Delete User
                        [currentUser deleteWithCompletion:^(NSError *error) {
                            
                            if (error) {
                                //            [self alert:@"Error!" withMessage:error.description];
                            } else {
                                
                                // After sign out, go to log in screen
                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                UBLogInAdminViewController *livc = [storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
                                [self presentViewController:livc animated:YES completion:nil];
                            }
                        }];
                    }];
                }];
            }];
        }];
    }];  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currentUserEmail = [FIRAuth auth].currentUser.email;
    _currentUserId = [FIRAuth auth].currentUser.uid;
    
    _communityId = [_communityDict valueForKeyPath:@"id"];
    _communityName = [_communityName valueForKeyPath:@"values.name"];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_ref removeAllObservers];
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
