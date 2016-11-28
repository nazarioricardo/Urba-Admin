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

@end

@implementation UBSettingsViewController

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addPressed:(id)sender {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [[FIRAuth auth] createUserWithEmail:_secEmailTextField.text
                               password:_passwordTextField.text
                             completion:^(FIRUser *user, NSError *error) {
                                 
                                 if (error) {
                                     NSLog(@"Error: %@", error.description);
                                     [spinner removeSpinner];
                                 } else {
                                     FIRDatabaseReference *ref = [[FIRDatabase database] reference];
                                     ref = [ref child:@"security"];
                                     [[ref child:@"user-id"] child:user.uid];
                                     [[ref child:@"user-name"] child:user.email];
                                     [[ref child:@"admin-email"] child:[UBFIRDatabaseManager getCurrentUserEmail]];
                                     [[ref child:@"admin-id"] child:[UBFIRDatabaseManager getCurrentUser]];
                                     [[ref child:@"community-name"] child:_communityName];
                                     [[ref child:@"community-id"] child:_communityId];
                                     
                                     [spinner removeSpinner];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
