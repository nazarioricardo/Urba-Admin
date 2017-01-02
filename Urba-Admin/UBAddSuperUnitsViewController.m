//
//  UBAddSuperUnitsViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBAddSuperUnitsViewController.h"
#import "UBAddUnitsViewController.h"
#import "Constants.h"
#import "ActivityView.h"

@import FirebaseAuth;
@import FirebaseDatabase;

@interface UBAddSuperUnitsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *streetNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *feedTable;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *addRef;
@property (strong, nonatomic) NSMutableArray *feedArray;

@property (strong, nonatomic) NSString *communityName;
@property (strong, nonatomic) NSString *communityId;

@property (weak, nonatomic) NSString *selectedKey;
@property (weak, nonatomic) NSString *selectedName;

@end

@implementation UBAddSuperUnitsViewController

#pragma mark - IBActions

- (IBAction)addPressed:(id)sender {
    
    if ([_streetNameTextField.text isEqualToString:@""]) {
        NSLog(@"Please fill in required field");
    } else {
        
        
        
        NSDictionary *superUnitDict = [NSDictionary dictionaryWithObjectsAndKeys:_streetNameTextField.text,@"name",_communityName,@"community",_communityId,@"community-id", nil];
        _addRef = [[[FIRDatabase database] reference] child:@"super-units"];
        [[_addRef childByAutoId] setValue:superUnitDict];
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

-(void)getSuperUnits {
    
    NSLog(@"Get super-units called with ID: %@", _communityId);
    
    _ref = [[[FIRDatabase database] reference] child:@"super-units"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"community-id"] queryEqualToValue:_communityId];
    
    [query observeEventType:FIRDataEventTypeChildAdded
                  withBlock:^(FIRDataSnapshot *snapshot) {
                      
                      NSLog(@"SNAP: %@", snapshot);
                      
                      if ([snapshot exists]) {
                          
                          if (![_feedArray containsObject:snapshot]) {
                              
                              if (![_feedArray count]) {
                                  [_feedArray addObject:snapshot];
                                  [_feedTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationNone];
                              } else {
                                  [_feedArray addObject:snapshot];
                                  [_feedTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
                              }
                          }
                      }
                  }
            withCancelBlock:^(NSError *error) {
                NSLog(@"ERROR: %@", error.description);
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
                              [_feedTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[num integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
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
    _feedArray = [[NSMutableArray alloc] init];
    _feedTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _communityName = [_communityDict valueForKeyPath:@"values.name"];
    _communityId = [_communityDict valueForKeyPath:@"id"];
    
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
        [auvc setCommunityDict:_communityDict];

    }
    
    // Pass the selected object to the new view controller.
}

@end
