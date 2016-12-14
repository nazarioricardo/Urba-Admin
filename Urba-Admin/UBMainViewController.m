//
//  UBMainViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/9/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBMainViewController.h"
#import "UBAddSuperUnitsViewController.h"
#import "UBVerifyUserViewController.h"
#import "UBSettingsViewController.h"
#import "Constants.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBMainViewController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITableView *feedTable;
@property (strong, nonatomic) NSMutableArray *feedArray;
@property (weak, nonatomic) NSString *addressToVerify;
@property (weak, nonatomic) NSString *userToVerify;
@property (weak, nonatomic) NSString *userId;
@property (weak, nonatomic) NSString *unitId;
@property (weak, nonatomic) NSString *requestId;

@end

@implementation UBMainViewController

- (IBAction)settingsPressed:(id)sender {
    [self performSegueWithIdentifier:settingsSegue sender:self];
}

#pragma mark - Private

-(void)getUnitRequests {
    
    _ref = [[[FIRDatabase database] reference] child:@"requests"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"to/id"] queryEqualToValue:[FIRAuth auth].currentUser.uid];
    
    [query observeEventType:FIRDataEventTypeChildAdded
                  withBlock:^(FIRDataSnapshot *snapshot) {
                      
                      if ([snapshot exists]) {
                          
                          if (![_feedArray containsObject:snapshot]) {
                              
                              if (![_feedArray count]) {
                                  [_feedArray addObject:snapshot];
                                  [_feedTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationNone];
//                                  [self hideViewAnimated:_noGuestsLabel hide:YES];
                                  [self hideViewAnimated:_feedTable hide:NO];
                              } else {
                                  [_feedArray addObject:snapshot];
                                  [_feedTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
                              }
                          }
                      }
                  }
            withCancelBlock:^(NSError *error) {
//                [self alert:@"Error!" withMessage:error.description];
            }];
    
    [query observeEventType:FIRDataEventTypeChildRemoved
                  withBlock:^(FIRDataSnapshot *snapshot) {
                      
                      NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
                      
                      for (FIRDataSnapshot *snap in _feedArray) {
                          if ([snapshot.key isEqualToString:snap.key]) {

                              [deleteArray addObject:[NSNumber numberWithInteger:[_feedArray indexOfObject:snap] ]];
                          }
                      }
                      
                      [_feedTable beginUpdates];
                      for (NSNumber *num in deleteArray) {
                          
                          if ([_feedArray count] == 1) {
                              [_feedArray removeObjectAtIndex:[num integerValue]];
                              [_feedTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[num integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                              [self hideViewAnimated:_feedTable hide:YES];
//                              [self hideViewAnimated:_noGuestsLabel hide:NO];
                          } else {
                              [_feedArray removeObjectAtIndex:[num integerValue]];
                              [_feedTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[num integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                          }
                      }
                      [_feedTable endUpdates];
                  }];
    
}

-(void)addUserToUnit:(NSString *)user withUserId:(NSString *)userId forUnit:(NSString *)unitId {
    
    NSString *unitRefString = [NSString stringWithFormat:@"units/%@/users", unitId];
    
    FIRDatabaseReference *unitRef = [[[[FIRDatabase database] reference] child:unitRefString] child:userId];
    [[unitRef child:@"name"] setValue:user];
    [[unitRef child:@"permissions"] setValue:@"head"];
    [unitRef removeAllObservers];
}

-(void)removeRequest:(NSString *)requestId {

    FIRDatabaseReference *removeRef = [[[FIRDatabase database] reference] child:@"requests"];
    [[removeRef child:requestId] removeValue];
    [removeRef removeAllObservers];
    
}

-(void)verifyRequestController:(NSString *)user withUserId:(NSString *)userId forUnit:(NSString *)unitId withRequest:(NSString *)requestId {
    
    NSString *message = [NSString stringWithFormat:@"Before verifying, be certain that this is a trusted resident at the unit: %@", user];
    
    UIAlertController *verifyView = [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Verify", nil)
                                  message: message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *verify = [UIAlertAction actionWithTitle:@"Accept"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       
                                                       [self addUserToUnit:user withUserId:userId forUnit:unitId];
                                                       [self removeRequest:requestId];
                                                       [verifyView dismissViewControllerAnimated:YES
                                                                                      completion:nil];
                                                   }];
    
    UIAlertAction *wait = [UIAlertAction actionWithTitle:@"Wait"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     
                                                     [verifyView dismissViewControllerAnimated:YES
                                                                                 completion:nil];
                                                 }];
    
    UIAlertAction *reject = [UIAlertAction actionWithTitle:@"Deny"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                       [self removeRequest:requestId];
                                                       [verifyView dismissViewControllerAnimated:YES
                                                                                      completion:nil];
                                                   }];
    
    [verifyView addAction:verify];
    [verifyView addAction:wait];
    [verifyView addAction:reject];
    [self presentViewController:verifyView animated:YES completion:nil];
}

-(void)hideViewAnimated:(UIView *)view hide:(BOOL)hidden {
    
    [UIView transitionWithView:view
                      duration:.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        view.hidden = hidden;
                    }
                    completion:nil];
}

#pragma mark - Table View Data Soruce

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_feedArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Unpack  from results array
    FIRDataSnapshot *snapshot = _feedArray[indexPath.row];
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id",snapshot.value,@"values", nil];
    NSString *unit = [snapshotDict valueForKeyPath:@"values.unit.name"];
    NSString *owner = [snapshotDict valueForKeyPath:@"values.unit.owner"];
    NSString *address = [NSString stringWithFormat:@"%@ %@", unit, owner];
    
    NSLog(@"Address %@", address);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", address];
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FIRDataSnapshot *snapshot = _feedArray[indexPath.row];
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id",snapshot.value,@"values", nil];
    
    [self verifyRequestController:[snapshotDict valueForKeyPath:@"values.from.name"]
                       withUserId:[snapshotDict valueForKeyPath:@"values.from.id"]
                          forUnit:[snapshotDict valueForKeyPath:@"values.unit.id"]
                      withRequest:[snapshotDict valueForKeyPath:@"id"]];
    
//    [self performSegueWithIdentifier:verifySegue sender:self];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = _communityName;
    _feedArray = [[NSMutableArray alloc] init];
    _feedTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated {
    [self getUnitRequests];
    if (![_feedArray count]) {
        [self hideViewAnimated:_feedTable hide:YES];
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [_ref removeAllObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqualToString:addSuperUnitsSegue]) {
        
        // Pass the selected object to the new view controller.
        UINavigationController *nvc = [segue destinationViewController];
        UBAddSuperUnitsViewController *suvc = (UBAddSuperUnitsViewController *)[nvc topViewController];
    
        [suvc setCommunityId:_communityKey];
        [suvc setCommunityName:_communityName];
    }
    
    if ([segue.identifier isEqualToString:verifySegue]) {
        UBVerifyUserViewController *uvvc = [segue destinationViewController];
        
        [uvvc setUserName:_userToVerify];
        [uvvc setUserId:_userId];
        [uvvc setAddress:_addressToVerify];
        [uvvc setRequestId:_requestId];
        [uvvc setUnitId:_unitId];
        [uvvc setMainvc:self];
    }
    
    if ([segue.identifier isEqualToString:settingsSegue]) {
        UINavigationController *nvc = [segue destinationViewController];
        UBSettingsViewController *svc = (UBSettingsViewController *)[nvc topViewController];
        
        [svc setCommunityName:_communityName];
        [svc setCommunityId:_communityKey];
    }
}

@end
