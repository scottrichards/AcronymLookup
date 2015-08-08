//
//  DetailViewController.m
//  AcronymLookup
//
//  Created by Scott Richards on 8/7/15.
//  Copyright (c) 2015 Scott Richards. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *acronymName;    // display name of acronym at top
@property (weak, nonatomic) IBOutlet UILabel *since;          // date acronym was used
@property (weak, nonatomic) IBOutlet UILabel *frequency;      // frequency label
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;   // number formatter for frequency
@property (strong, nonatomic) NSNumberFormatter *numberFormatterNoStyle;  // number formatter for year no commas
@property (strong, nonatomic) NSArray *alternateAcronyms;     // date for alternate acronyms
@property (weak, nonatomic) IBOutlet UITableView *tableView;  // tableView to display alternates
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  _numberFormatter = [NSNumberFormatter new];
  _numberFormatterNoStyle = [NSNumberFormatter new];
  [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
  [_numberFormatterNoStyle setNumberStyle:NSNumberFormatterNoStyle];
  [_tableView setAllowsSelection:NO];   // prevent selection since we don't do anything
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// view is being displayed update the data reload table view
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

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

// return number of alternate acronym items
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
