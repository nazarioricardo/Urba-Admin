//
//  UBCreateCommViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/8/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBCreateCommViewController.h"
#import "ActivityView.h"

@import Firebase;

@interface UBCreateCommViewController ()

@property (weak, nonatomic) IBOutlet UITextField *commNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *adminNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *adminEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassTextField;

@end

@implementation UBCreateCommViewController

#pragma mark - IBActions

- (IBAction)donePressed:(id)sender {
    
    if ([_commNameTextField.text isEqualToString:@""] || [_adminNameTextField.text isEqualToString:@""] || [_adminEmailTextField.text isEqualToString:@""] || [_passwordTextField.text isEqualToString:@""] || [_confirmPassTextField.text isEqualToString:@""]) {
        
        NSLog(@"Please fill all blank fields");
    } else if (![_passwordTextField.text isEqualToString:_confirmPassTextField.text]) {
        
        NSLog(@"Password mismatch! Please try again");
    } else {
        
        [self createCommunity];
    }
}

- (IBAction)cancelPressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

-(void)createCommunity {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [[FIRAuth auth] createUserWithEmail:_adminEmailTextField.text
                               password:_passwordTextField.text
                             completion:^(FIRUser *user, NSError *error) {
        
                                 if (error) {
                                     NSLog(@"Error: %@", error.description);
                                     [spinner removeSpinner];
                                 } else {
                                
                                     FIRDatabaseReference *commRef = [[FIRDatabase database] reference];
                                     commRef = [[commRef child:@"communities"] childByAutoId];
                                     
                                     [[commRef child:@"name"] setValue:_commNameTextField.text];
                                     [[commRef child:@"admin-name"] setValue:_adminNameTextField.text];
                                     [[commRef child:@"admin-email"] setValue:_adminEmailTextField.text];
                                     [[commRef child:@"admin-id"] setValue:user.uid];
                                     
                                     FIRDatabaseReference *adminRef = [[FIRDatabase database] reference];
                                     adminRef = [[adminRef child:@"community-admins"] child:user.uid];
                                     
                                     NSString *communityId = [NSString stringWithFormat:@"%@-%@", _commNameTextField.text, commRef.key];
                                     
                                     NSLog(@"Community Id: %@", communityId);
                                     
                                     [[adminRef child:@"email"] setValue:user.email];
                                     [[adminRef child:@"community-id"] setValue:commRef.key];
                                     [[adminRef child:@"community-name"] setValue:_commNameTextField.text];
                                     
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }
    }];
    
}

#pragma mark - Text View Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _commNameTextField) {
        [textField resignFirstResponder];
        [_adminNameTextField becomeFirstResponder];
    } else if (textField == _adminNameTextField) {
        [textField resignFirstResponder];
        [_adminEmailTextField becomeFirstResponder];
    } else if (textField == _adminEmailTextField){
        [textField resignFirstResponder];
        [_passwordTextField resignFirstResponder];
    } else if (textField == _passwordTextField) {
        [textField resignFirstResponder];
        [_confirmPassTextField becomeFirstResponder];
    } else {
        [self createCommunity];
    }
    
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Life Cycle

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
