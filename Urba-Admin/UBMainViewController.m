//
//  UBMainViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/9/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBMainViewController.h"
#import "UBFIRDatabaseManager.h"
#import "UBAddSuperUnitsViewController.h"
#import "UBVerifyUserViewController.h"
#import "Constants.h"
#import "ActivityView.h"

@interface UBMainViewController ()

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (strong, nonatomic) NSMutableArray *requestsArray;
@property (weak, nonatomic) NSString *addressToVerify;
@property (weak, nonatomic) NSString *userToVerify;
@property (weak, nonatomic) NSString *userId;
@property (weak, nonatomic) NSString *unitId;
@property (weak, nonatomic) NSString *requestId;

@end

@implementation UBMainViewController

#pragma mark - Private

- (void)getCommunity {
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"communities"
                                     orderedBy:@"admin-id"
                                    filteredBy:[UBFIRDatabaseManager getCurrentUser]
                            withSuccessHandler:^(NSArray *results) {
                                
                                NSDictionary<NSString *, NSString *> *dict = results[0];
                                
                                _communityName = [dict valueForKeyPath:@"values.name"];
                                
                                
//                                NSLog(@"Results: %@", _communityName);
                            }
                                orErrorHandler:^(NSError *error) {
                                    
                                    NSLog(@"Error: %@", error.description);
                                }];
}

-(void)getUnitRequests {
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"requests"
                                     orderedBy:@"to/id"
                                    filteredBy:[UBFIRDatabaseManager getCurrentUser]
                            withSuccessHandler:^(NSArray *results) {
                                
                                _requestsArray = [NSMutableArray arrayWithArray:results];
                                [_feedTableView reloadData];
                                NSLog(@"Results: %@", _requestsArray);
                                }
                                orErrorHandler:^(NSError *error) {
                                    
                                    NSLog(@"Error: %@", error.description);
                                }];
}

#pragma mark - Table View Data Soruce

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_requestsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Unpack  from results array
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _requestsArray[indexPath.row];
    NSString *unit = [snapshotDict valueForKeyPath:@"values.unit.name"];
    NSString *owner = [snapshotDict valueForKeyPath:@"values.unit.owner"];
    NSString *address = [NSString stringWithFormat:@"%@ %@", unit, owner];
    
    NSLog(@"Address %@", address);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", address];
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _requestsArray[indexPath.row];
    NSString *unit = [snapshotDict valueForKeyPath:@"values.unit.name"];
    NSString *owner = [snapshotDict valueForKeyPath:@"values.unit.owner"];
    _addressToVerify = [NSString stringWithFormat:@"%@ %@", unit, owner];
    _userToVerify = [snapshotDict valueForKeyPath:@"values.from.name"];
    _userId = [snapshotDict valueForKeyPath:@"values.from.id"];
    _requestId = [snapshotDict valueForKeyPath:@"id"];
    _unitId = [snapshotDict valueForKeyPath:@"values.unit.id"];
    
    [self performSegueWithIdentifier:verifySegue sender:self];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getUnitRequests];
    self.navigationItem.title = _communityName;
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
    }
}

@end
