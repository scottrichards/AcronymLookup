//
//  ViewController.m
//  AcronymLookup
//
//  Created by Scott Richards on 8/6/15.
//  Copyright (c) 2015 Scott Richards. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "MBProgressHud.h"
#import "DetailViewController.h"

// URL feed to lookup acronym
NSString *jsonURLFeed = @"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *acronymField; // field for entering acronym to search for
@property (weak, nonatomic) IBOutlet UITableView *tableView;    // results of acronym search go here
@property (strong, nonatomic) NSArray *acronymArray;            // array of acronym Dictionaries to populate the table
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
//  [_tableView setAllowsSelection:NO]; // prevent selection of the table cell elements
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}


// invoked when user clicks on the search button, send a request to retrieve json feed
- (IBAction)onLookup:(id)sender {
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//  hud.mode = MBProgressHUDModeAnnularDeterminate;
  hud.labelText = @"Loading";
  NSString *urlString = [NSString stringWithFormat:jsonURLFeed, _acronymField.text];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  operation.responseSerializer.acceptableContentTypes = nil;
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    [hud hide:YES];
    if ([responseObject isKindOfClass:[NSArray class]]) {
      NSArray *rootArray = (NSArray *)responseObject;
      if ([rootArray count] > 0) {
        NSDictionary *rootDictionary = (NSDictionary *)rootArray[0];
        if (rootDictionary) {
          _acronymArray = rootDictionary[@"lfs"];
          [_tableView reloadData];
        }
      }
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    [hud hide:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Acronyms"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
  }];
  [operation start];
}

#pragma mark - TextField

// dismiss the keyboard when clicking the done button
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

#pragma mark - TableViewDataSource

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row < [_acronymArray count]) {
    NSDictionary *acronymItemDictionary = _acronymArray[indexPath.row];
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
  return [_acronymArray count];
}

// return the tableviewcell for the specified row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  if (indexPath.row < [_acronymArray count]) {
    NSDictionary *acronymItemDictionary = _acronymArray[indexPath.row];
    if (acronymItemDictionary != nil) {
      cell.textLabel.text = acronymItemDictionary[@"lf"];
    }
  }
  return cell;
}
@end
