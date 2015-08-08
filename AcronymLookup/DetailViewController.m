//
//  DetailViewController.m
//  AcronymLookup
//
//  Created by Scott Richards on 8/7/15.
//  Copyright (c) 2015 Scott Richards. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *acronymName;
@property (weak, nonatomic) IBOutlet UILabel *since;
@property (weak, nonatomic) IBOutlet UILabel *frequency;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) NSNumberFormatter *numberFormatterNoStyle;
@property (strong, nonatomic) NSArray *alternateAcronyms;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  _numberFormatter = [NSNumberFormatter new];
  _numberFormatterNoStyle = [NSNumberFormatter new];
  [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
  [_numberFormatterNoStyle setNumberStyle:NSNumberFormatterNoStyle];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
  NSNumber *frequency = _acronymData[@"freq"];
  NSNumber *since = _acronymData[@"since"];
  NSString *sinceString;
  _acronymName.text = _acronymData[@"lf"];
  sinceString = [_numberFormatterNoStyle stringFromNumber:since];
  _since.text = sinceString;
  NSString *frequencyString = [_numberFormatter stringFromNumber:frequency];
  NSLog(@"Frequency: %@",frequencyString);
  _frequency.text = [_numberFormatter stringFromNumber:frequency];
  _alternateAcronyms = _acronymData[@"vars"];
  if (_alternateAcronyms) {
    [_tableView reloadData];
  }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row < [_alternateAcronyms count]) {
    NSDictionary *acronymItemDictionary = _alternateAcronyms[indexPath.row];
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.acronymData = acronymItemDictionary;
    [self.navigationController pushViewController:detailViewController animated:YES];
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

// return number of acronym items
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_alternateAcronyms count];
}

// return the tableviewcell for the specified row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  if (indexPath.row < [_alternateAcronyms count]) {
    NSDictionary *acronymItemDictionary = _alternateAcronyms[indexPath.row];
    if (acronymItemDictionary != nil) {
      cell.textLabel.text = acronymItemDictionary[@"lf"];
    }
  }
  return cell;
}

@end
