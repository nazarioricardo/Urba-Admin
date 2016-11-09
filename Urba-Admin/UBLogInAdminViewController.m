//
//  UBLogInAdminViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/8/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBLogInAdminViewController.h"
#import "Constants.h"
#import "ActivityView.h"

@import Firebase;

@interface UBLogInAdminViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation UBLogInAdminViewController

- (IBAction)donePressed:(id)sender {    
    [self logIn];
}

-(void)logIn {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];

    [[FIRAuth auth] signInWithEmail:_emailTextField.text password:_passwordTextField.text completion:^(FIRUser *user, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error.description);
            [spinner removeSpinner];
        } else {
            
            FIRDatabaseReference *ref = [[FIRDatabase database] reference];
            ref = [ref child:@"community-admins"];
            [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                
                if ([snapshot hasChild:user.uid]) {
                    
                    NSLog(@"Admin log in was successful");
                    [self performSegueWithIdentifier:logInSegue sender:self];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
