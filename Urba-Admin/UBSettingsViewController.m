//
//  UBSettingsViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBSettingsViewController.h"
#import "UBFIRDatabaseManager.h"
#import "ActivityView.h"

@import Firebase;

@interface UBSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *secEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@property (strong, nonatomic) NSString *currentUserEmail;
@property (strong, nonatomic) NSString *currentUserId;

@end

@implementation UBSettingsViewController

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];    
}

- (IBAction)addPressed:(id)sender {
    
    [self createSecurityUser];
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
                                     FIRDatabaseReference *ref = [[FIRDatabase database] reference];
                                     ref = [[ref child:@"security"] child:user.uid];
                                     [[ref child:@"email"] setValue:user.email];
                                     [[ref child:@"admin-email"] setValue:_currentUserEmail];
                                     [[ref child:@"admin-id"] setValue:_currentUserId];
                                     [[ref child:@"community-name"] setValue:_communityName];
                                     [[ref child:@"community-id"] setValue:_communityId];
                                     
                                     [spinner removeSpinner];
                                 }
                             }];
    
    NSLog(@"Current user: %@", [UBFIRDatabaseManager getCurrentUserEmail]);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currentUserEmail = [UBFIRDatabaseManager getCurrentUserEmail];
    _currentUserId = [UBFIRDatabaseManager getCurrentUser];
    
    NSLog(@"Current user email: %@", _currentUserEmail);
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
