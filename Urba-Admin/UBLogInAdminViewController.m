//
//  UBLogInAdminViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/8/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBLogInAdminViewController.h"
#import "UBMainViewController.h"
#import "Constants.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBLogInAdminViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *communityName;
@property (strong, nonatomic) NSString *communityKey;

@end

@implementation UBLogInAdminViewController

#pragma mark - IBActions

- (IBAction)donePressed:(id)sender {    
    [self logIn];
}

#pragma mark - Private

-(void)logIn {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];

    [[FIRAuth auth] signInWithEmail:@"jpnazario5@hotmail.com" password:@"iamjuan" completion:^(FIRUser *user, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error.description);
            [spinner removeSpinner];
        } else {
            
            _ref = [[FIRDatabase database] reference];
            _ref = [_ref child:@"communities"];
            FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"admin-id"] queryEqualToValue:[FIRAuth auth].currentUser.uid];
            [query observeSingleEventOfType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {

                if ([snapshot exists]) {
                    
                    NSLog(@"Admin log in was successful");
                                        
                    NSDictionary *communityDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id", snapshot.value,@"values", nil];
                    
                    _communityName = [communityDict valueForKeyPath:@"values.name"];
                    _communityKey = [communityDict valueForKey:@"id"];
                    
                    NSLog(@"SNAP VALUE: %@", snapshot.value);
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

#pragma mark - Text View Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _emailTextField) {
        [textField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else {
        [self logIn];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    if ([segue.identifier isEqualToString:logInSegue]) {
        UINavigationController *nvc = [segue destinationViewController];
        UBMainViewController *umvc = (UBMainViewController *)[nvc topViewController];
        
        // Pass the selected object to the new view controller.
        [umvc setCommunityName:_communityName];
        [umvc setCommunityKey:_communityKey];
    }
}

@end
