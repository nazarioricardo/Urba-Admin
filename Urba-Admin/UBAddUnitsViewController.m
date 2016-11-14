//
//  UBAddUnitsViewController.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBAddUnitsViewController.h"
#import "UBFIRDatabaseManager.h"
#import "ActivityView.h"

@interface UBAddUnitsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *actualUnitsTableView;
@property (weak, nonatomic) IBOutlet UITableView *previewUnitsTableView;
@property (weak, nonatomic) IBOutlet UITextField *singleUnitTextField;
@property (weak, nonatomic) IBOutlet UITextField *prefixTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *suffixTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberOfUnitsTextField;
@property (weak, nonatomic) IBOutlet UITextField *incrementorTextField;

@property (strong, nonatomic) NSString *ownerName;
@property (strong, nonatomic) NSMutableArray *unitsArray;


@end

@implementation UBAddUnitsViewController

#pragma mark - IBActions

- (IBAction)addSinglePressed:(id)sender {
    
    [UBFIRDatabaseManager createUnitOrSuperUnit:@"units"
                                      withValue:_singleUnitTextField.text
                                      withOwner:_ownerName];
}

- (IBAction)addBatchPressed:(id)sender {

    NSUInteger firstNumber = [_firstNumberTextField.text integerValue];
    NSUInteger highestNum = [_numberOfUnitsTextField.text integerValue];
    NSUInteger incrementor = [_incrementorTextField.text integerValue];
    
    for (NSInteger i = firstNumber; i <= highestNum; i += incrementor) {
        
        NSString *unit = [NSString stringWithFormat:@"%@%ld%@", _prefixTextField.text, i, _suffixTextField.text];
        
        [UBFIRDatabaseManager createUnitOrSuperUnit:@"units"
                                          withValue:unit
                                          withOwner:_ownerName];
    }
}

- (IBAction)donePressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Private

-(void)getUnits {
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"units"
                                     orderedBy:@"owner"
                                    filteredBy:_ownerName
                            withSuccessHandler:^(NSArray *results) {
                                
                                _unitsArray = [NSMutableArray arrayWithArray:results];
                                [_actualUnitsTableView reloadData];
                            }
                                orErrorHandler:^(NSError *error) {
                                    
                                    NSLog(@"Error: %@", error.description);
                                }];
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_unitsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Unpack from results array
    NSDictionary<NSString *, NSString *> *snapshotDict = _unitsArray[indexPath.row];
    NSString *name = [snapshotDict objectForKey:@"name"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = _superUnitName;
    
    _ownerName = [NSString stringWithFormat:@"%@-%@", _superUnitName, _superUnitId];

    
    [self getUnits];
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