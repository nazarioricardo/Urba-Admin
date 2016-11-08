//
//  UBCreateCommViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/8/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBCreateCommViewController.h"

@import Firebase;

@interface UBCreateCommViewController ()

@property (weak, nonatomic) IBOutlet UITextField *commNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *adminNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *adminEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassTextField;

@end

@implementation UBCreateCommViewController

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
}

-(void)createCommunity {
    
    [[FIRAuth auth] createUserWithEmail:_adminEmailTextField.text
                               password:_passwordTextField.text
                             completion:^(FIRUser *user, NSError *error) {
        
                                 if (error) {
                                     NSLog(@"Error: %@", error.description);
                                 } else {
                                
                                     //TODO: Create community
                                     FIRDatabaseReference *ref = [[FIRDatabase database] reference];
                                     ref = [[ref child:@"communities"] childByAutoId];
                                     
                                     [[ref child:@"name"] setValue:_commNameTextField.text];
                                     [[ref child:@"admin-name"] setValue:_adminNameTextField.text];
                                     [[ref child:@"admin-email"] setValue:_adminEmailTextField.text];
                                     [[ref child:@"admin-id"] setValue:user.uid];
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
