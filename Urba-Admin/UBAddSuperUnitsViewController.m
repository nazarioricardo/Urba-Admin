//
//  UBAddSuperUnitsViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBAddSuperUnitsViewController.h"
#import "UBFIRDatabaseManager.h"
#import "UBAddUnitsViewController.h"
#import "Constants.h"
#import "ActivityView.h"

@import FirebaseAuth;
@import FirebaseDatabase;

@interface UBAddSuperUnitsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *streetNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *feedTable;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSString *ownerName;
@property (strong, nonatomic) NSMutableArray *feedArray;

@property (weak, nonatomic) NSString *selectedKey;
@property (weak, nonatomic) NSString *selectedName;

@end

@implementation UBAddSuperUnitsViewController

#pragma mark - IBActions

- (IBAction)addPressed:(id)sender {
    
    NSLog(@"Owner name to set: %@", _ownerName);
    
    if ([_streetNameTextField.text isEqualToString:@""]) {
        NSLog(@"Please fill in required field");
    } else {
        
        NSDictionary *superUnitDict = [NSDictionary dictionaryWithObjectsAndKeys:_streetNameTextField.text,@"name",_communityName,@"community",_communityId,@"community-id", nil];
        [UBFIRDatabaseManager addChildByAutoId:@"super-units" withPairs:superUnitDict];
    }

}

- (IBAction)cancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

-(void)getSuperUnits {
    
    _ref = [[[FIRDatabase database] reference] child:@"visitors"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"community-id"] queryEqualToValue:_communityId];
    
    [query observeEventType:FIRDataEventTypeChildAdded
                  withBlock:^(FIRDataSnapshot *snapshot) {
                      
                      if ([snapshot exists]) {
                          
                          if (![_feedArray containsObject:snapshot]) {
                              
                              if (![_feedArray count]) {
                                  [_feedArray addObject:snapshot];
                                  [_feedTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationNone];
//                                  [self hideViewAnimated:_noGuestsLabel hide:YES];
//                                  [self hideViewAnimated:_feedTable hide:NO];
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
//                              [self hideViewAnimated:_feedTable hide:YES];
//                              [self hideViewAnimated:_noGuestsLabel hide:NO];
                          } else {
                              [_feedArray removeObjectAtIndex:[num integerValue]];
                              [_feedTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[num integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                          }
                      }
                      [_feedTable endUpdates];
                  }];

}

-(BOOL)checkIfCommunityHasSuperUnits {
    
    return [UBFIRDatabaseManager checkIfNodeHasChild:@"super-units"
                                               child:_ownerName];
}

#pragma mark - Table View Data Source

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
    NSDictionary<NSString *, NSDictionary *> *superUnitDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id",snapshot.value,@"values", nil];
    NSString *name = [superUnitDict valueForKeyPath:@"values.name"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    FIRDataSnapshot *snapshot = _feedArray[indexPath.row];
    NSDictionary<NSString *, NSDictionary *> *superUnitDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id",snapshot.value,@"values", nil];
    
    _selectedKey = [superUnitDict valueForKeyPath:@"id"];
    _selectedName = selectedCell.textLabel.text;
    
    [self performSegueWithIdentifier:addUnitsSegue sender:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        FIRDataSnapshot *snapshot = _feedArray[indexPath.row];
        NSDictionary<NSString *, NSDictionary *> *superUnitDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id",snapshot.value,@"values", nil];
        NSString *key = [superUnitDict valueForKeyPath:@"id"];
        
        [[_ref child:key] removeValue];
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ownerName = [NSString stringWithFormat:@"%@-%@", _communityName, _communityId];
    
    NSLog(@"Owner name: %@", _ownerName);
    
    [self getSuperUnits];
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
    
    if ([segue.identifier isEqualToString:addUnitsSegue]) {
        UBAddUnitsViewController *auvc = [segue destinationViewController];
        
        [auvc setSuperUnitId:_selectedKey];
        [auvc setSuperUnitName:_selectedName];
        [auvc setCommunityId:_communityId];
        [auvc setCommunityName:_communityName];

    }
    
    // Pass the selected object to the new view controller.
}

@end
