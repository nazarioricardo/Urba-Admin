//
//  UBAddUnitsViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBAddUnitsViewController.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBAddUnitsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *feedTable;
@property (weak, nonatomic) IBOutlet UITextField *singleUnitTextField;
@property (weak, nonatomic) IBOutlet UITextField *prefixTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *suffixTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberOfUnitsTextField;
@property (weak, nonatomic) IBOutlet UITextField *incrementorTextField;


@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *addUnitRef;
@property (strong, nonatomic) NSString *ownerName;
@property (strong, nonatomic) NSMutableArray *feedArray;
@property (strong, nonatomic) NSString *communityName;
@property (strong, nonatomic) NSString *communityId;


@end

@implementation UBAddUnitsViewController

#pragma mark - IBActions

- (IBAction)addSinglePressed:(id)sender {
    
    NSDictionary *unitDict = [NSDictionary dictionaryWithObjectsAndKeys:_singleUnitTextField.text,@"name",_communityName,@"community",_communityId,@"community-id",_superUnitName,@"super-unit",_superUnitId,@"super-unit-id", nil];
    
    _addUnitRef = [[FIRDatabase database] reference];
    [[[_addUnitRef child:@"units"] childByAutoId] setValue:unitDict];
}

- (IBAction)addBatchPressed:(id)sender {

    NSUInteger firstNumber = [_firstNumberTextField.text integerValue];
    NSUInteger highestNum = [_numberOfUnitsTextField.text integerValue];
    NSUInteger incrementor = [_incrementorTextField.text integerValue];
    
    for (NSInteger i = firstNumber; i <= highestNum; i += incrementor) {
        
        NSString *unitName = [NSString stringWithFormat:@"%@%ld%@", _prefixTextField.text, i, _suffixTextField.text];
        NSDictionary *unitDict = [NSDictionary dictionaryWithObjectsAndKeys:unitName,@"name",_communityName,@"community",_communityId,@"community-id",_superUnitName,@"super-unit",_superUnitId,@"super-unit-id", nil];
        
        _addUnitRef = [[FIRDatabase database] reference];
        [[[_addUnitRef child:@"units"] childByAutoId] setValue:unitDict];
    }
}

- (IBAction)donePressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Private

-(void)getUnits {
    
    _ref = [[[FIRDatabase database] reference] child:@"units"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"super-unit-id"] queryEqualToValue:_superUnitId];
    
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
    
    // Unpack from results array
    FIRDataSnapshot *snapshot = _feedArray[indexPath.row];
    NSDictionary<NSString *, NSDictionary *> *unitDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key, @"id",snapshot.value,@"values", nil];
    NSString *name = [unitDict valueForKeyPath:@"values.name"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // TODO: Check accounts related to units
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        FIRDataSnapshot *snapshot = _feedArray[indexPath.row];
        NSDictionary<NSString *, NSDictionary *> *unitDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key, @"id",snapshot.value,@"values", nil];
        NSString *key = [unitDict valueForKeyPath:@"id"];
        
        [[_ref child:key] removeValue];
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _feedArray = [[NSMutableArray alloc] init];
    self.navigationItem.title = _superUnitName;
    _feedTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    _ownerName = [NSString stringWithFormat:@"%@-%@", _superUnitName, _superUnitId];
    _communityName = [_communityDict valueForKeyPath:@"values.name"];
    _communityId = [_communityDict valueForKeyPath:@"id"];

    [self getUnits];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_ref removeAllObservers];
    [_addUnitRef removeAllObservers];
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
