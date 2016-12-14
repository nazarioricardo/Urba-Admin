//
//  UBVerifyUserViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/22/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBVerifyUserViewController.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBVerifyUserViewController ()

@property (weak, nonatomic) IBOutlet UILabel *verificationLabel;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *unitRef;

@end

@implementation UBVerifyUserViewController

#pragma mark - IBActions

- (IBAction)acceptPressed:(id)sender {
    
    [self addUserToUnit];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postponePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)rejectPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

-(void)addUserToUnit {
    
    NSString *unitRefString = [NSString stringWithFormat:@"units/%@/users", _unitId];
    
    _unitRef = [[[[FIRDatabase database] reference] child:unitRefString] child:_userId];
    [[_unitRef child:@"name"] setValue:_userName];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ref = [[[FIRDatabase database] reference] child:@"requests"];
    [_ref child:_requestId];
    
    NSString *labelString = [NSString stringWithFormat:@"Please verify %@ for %@", _userName, _address];
    _verificationLabel.text = labelString;
}

-(void)viewWillDisappear:(BOOL)animated {
    [_ref removeAllObservers];
    [_unitRef removeAllObservers];
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
