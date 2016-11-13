//
//  UBAddSuperUnitsViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBAddSuperUnitsViewController.h"
#import "UBFIRDatabaseManager.h"
#import "ActivityView.h"

@interface UBAddSuperUnitsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *streetNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *superUnitsTableView;

@property (strong, nonatomic) NSString *ownerName;
@property (strong, nonatomic) NSMutableArray *superUnitsArray;

@end

@implementation UBAddSuperUnitsViewController

#pragma mark - IBActions

- (IBAction)addPressed:(id)sender {
    
    NSLog(@"Owner name to set: %@", _ownerName);
    
    if ([_streetNameTextField.text isEqualToString:@""]) {
        NSLog(@"Please fill in required field");
    } else {
        [UBFIRDatabaseManager createUnitOrSuperUnit:@"super-units" withValue:_streetNameTextField.text withOwner:_ownerName];
    }

}

- (IBAction)cancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

-(void)getSuperUnits {
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"super-units"
                                     orderedBy:@"owner"
                                    filteredBy:_ownerName
                            withSuccessHandler:^(NSArray *results) {
                                
                                _superUnitsArray = [NSMutableArray arrayWithArray:results];
                                [_superUnitsTableView reloadData];
                            }
                                orErrorHandler:^(NSError *error) {
                                    
                                    NSLog(@"Error: %@", error.description);
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
    return [_superUnitsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Unpack from results array
    NSDictionary<NSString *, NSString *> *snapshotDict = _superUnitsArray[indexPath.row];
    NSString *name = [snapshotDict objectForKey:@"name"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ownerName = [NSString stringWithFormat:@"%@-%@", _communityName, _communityId];
    
    NSLog(@"Owner name: %@", _ownerName);
    
    [self getSuperUnits];
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
