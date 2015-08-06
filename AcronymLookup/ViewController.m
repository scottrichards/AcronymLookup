//
//  ViewController.m
//  AcronymLookup
//
//  Created by Scott Richards on 8/6/15.
//  Copyright (c) 2015 Scott Richards. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

NSString *jsonURLFeed = @"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@";

static NSString * const BaseURLString = @"http://www.raywenderlich.com/demos/weather_sample/";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *acronymField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *acronymArray;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (IBAction)onLookup:(id)sender {
  // 1
  NSString *urlString = [NSString stringWithFormat:jsonURLFeed, _acronymField.text];
  
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  // 2
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  operation.responseSerializer = [AFJSONResponseSerializer serializer];

  operation.responseSerializer.acceptableContentTypes = nil;
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    // 3
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
    
    // 4
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Acronyms"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
  }];
  
  // 5
  [operation start];
}



#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_acronymArray count];
}

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
