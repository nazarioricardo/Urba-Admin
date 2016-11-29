//
//  UBVerifyUserViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/22/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBVerifyUserViewController.h"
#import "UBFIRDatabaseManager.h"
#import "ActivityView.h"

@interface UBVerifyUserViewController ()

@property (weak, nonatomic) IBOutlet UILabel *verificationLabel;

@end

@implementation UBVerifyUserViewController

#pragma mark - IBActions

- (IBAction)acceptPressed:(id)sender {
    
    [self addUserToUnit];
    [UBFIRDatabaseManager deleteValue:@"requests"
                              childId:_requestId];
    if ([[_mainvc requestsArray] count] == 1) {
        [[_mainvc requestsArray] removeAllObjects];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postponePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)rejectPressed:(id)sender {
    
    [UBFIRDatabaseManager deleteValue:@"requests"
                              childId:_requestId];
    if ([[_mainvc requestsArray] count] == 1) {
        [[_mainvc requestsArray] removeAllObjects];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

-(void)addUserToUnit {
    
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:_userId,@"id",_userName,@"name", nil];
    
    NSString *unitRef = [NSString stringWithFormat:@"units/%@", _unitId];
    
    [UBFIRDatabaseManager addChildToExistingParent:unitRef
                                             child:@"user"
                                         withPairs:userDict];
    
    [UBFIRDatabaseManager deleteValue:@"requests"
                              childId:_requestId];
    
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *labelString = [NSString stringWithFormat:@"Please verify %@ for %@", _userName, _address];
    _verificationLabel.text = labelString;
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
