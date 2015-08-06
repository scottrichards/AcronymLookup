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
@property (strong, nonatomic) NSDictionary *acronymDictionary;
@property (strong, nonatomic) NSString *prettyString;
@property (weak, nonatomic) IBOutlet UITextView *acronymResults;
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
  //  NSString *urlString = [NSString stringWithFormat:@"%@weather.php?format=json", BaseURLString];
//  [self requestJSON:urlString];
  
  _prettyString = @"";
  
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  // 2
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  operation.responseSerializer = [AFJSONResponseSerializer serializer];

  operation.responseSerializer.acceptableContentTypes = nil;
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    // 3
    self.acronymDictionary = (NSDictionary *)responseObject;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
      [self parseJSONDictionary:(NSDictionary *)responseObject depth:0];
    } else if ([responseObject isKindOfClass:[NSArray class]]) {
      [self parseJSONArray:(NSArray *)responseObject depth:0];
    }
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
    _acronymResults.text = _prettyString;
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


// make the async request for the JSON data at specified url
// urlAsString -> the url to make the request for JSON data
- (void)requestJSON:(NSString *)urlAsString
{
  NSURL *url = [[NSURL alloc] initWithString:urlAsString];
  NSLog(@"%@", urlAsString);
  
  [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    
    if (error) {
      NSLog(@"Received an error: %@",error.description);
      [self performSelectorOnMainThread:@selector(outputResults:) withObject:@"Received an ERROR.  Make sure it is a valid url and you have an interent connection." waitUntilDone:0];
    } else {
      [self parseJSONData:data];
    }
  }];
}

// parse the data as a JSON string
- (void)parseJSONData:(NSData *)data
{
  NSError *error = nil;
  _prettyString = @"";
  NSJSONReadingOptions options = NSJSONReadingMutableContainers;
  id object = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
  
  if (error) {
    NSLog(@"Error Parsing JSON Data");
    [self performSelectorOnMainThread:@selector(outputResults:) withObject:@"Error Parsing JSON Data. Make sure the url points to a valid JSON file." waitUntilDone:0];
  } else {
    if ([object isKindOfClass:[NSDictionary class]]) {
      [self parseJSONDictionary:(NSDictionary *)object depth:0];
    } else if ([object isKindOfClass:[NSArray class]]) {
      [self parseJSONArray:(NSArray *)object depth:0];
    }
    NSLog(@"%@",_prettyString);
    [self performSelectorOnMainThread:@selector(outputResults:) withObject:_prettyString waitUntilDone:0];
  }
}

// put the results in the results TextView
- (void)outputResults:(NSString *)results
{
  [_acronymResults setText:results];
}


// pretty print all of the items in the dictionary
// dictionary -> the dictionary of items to be printed
// depth -> increment when called to indicate how deeply we have recursed print this many tabs before outputing the items
// key -> if specified this is the key corresponding to this dictionary print it before printing the dictionary as its value pair
- (void)parseJSONDictionary:(NSDictionary *)dictionary depth:(uint)depth
{
  [self formatString:@"{" depth:depth++];
  for (NSString *key in dictionary) {
    id value = dictionary[key];
    if ([value isKindOfClass:[NSString class]]) {
      NSString *outputStr = [NSString stringWithFormat:@"\"%@\" : \"%@\"",key,value];
      [self formatString:outputStr depth:depth];
    } else if ([value isKindOfClass:[NSNumber class]]) {
      NSNumber *number = value;
      NSString *outputStr;
      if (CFNumberIsFloatType((CFNumberRef)number)) {
        outputStr = [NSString stringWithFormat:@"\"%@\" : %f",key,(float)[number floatValue]];
      } else {
        outputStr = [NSString stringWithFormat:@"\"%@\" : %ld",key,(long)[number integerValue]];
      }
      [self formatString:outputStr depth:depth];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
      NSString *keyString = [NSString stringWithFormat:@"\"%@\" :",key];
      [self formatString:keyString depth:depth];
      [self parseJSONDictionary:(NSDictionary *)value depth:depth+1];
    }  else if ([value isKindOfClass:[NSArray class]]) {
      NSString *keyString = [NSString stringWithFormat:@"\"%@\" :",key];
      [self formatString:keyString depth:depth];
      [self parseJSONArray:(NSArray *)value depth:depth+1];
    }
  }
  [self formatString:@"}" depth:--depth];
}


// pretty print all of the items in the array
// array -> the array of items to be printed
// depth -> increment when called to indicate how deeply we have recursed print this many tabs before outputing the items
- (void)parseJSONArray:(NSArray *)array depth:(uint)depth
{
  [self formatString:@"[" depth:depth];
  for (id object in array) {
    if ([object isKindOfClass:[NSString class]]) {
      NSString *outputStr = [NSString stringWithFormat:@"Value = %@",object];
      [self formatString:outputStr depth:depth];
    } else if ([object isKindOfClass:[NSNumber class]]) {
      NSNumber *number = object;
      NSString *outputStr = [NSString stringWithFormat:@"Value = %ld",(long)[number integerValue]];
      [self formatString:outputStr depth:depth];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
      [self parseJSONDictionary:(NSDictionary *)object depth:depth+1];
    } else if ([object isKindOfClass:[NSArray class]]) {
      [self parseJSONArray:(NSArray *)object depth:depth+1];
    }
  }
  [self formatString:@"]" depth:depth];
}

// output the string prepended with depth # of tabs
- (NSString *)formatString:(NSString *)string depth:(uint)depth
{
  NSString *tabs = @"";
  for (uint i=0;i<depth;i++) {
    tabs = [tabs stringByAppendingString:@"\t"];
  }
  NSString *formattedString;
  formattedString = [NSString stringWithFormat:@"%@%@\n",tabs,string];
  
  _prettyString = [_prettyString stringByAppendingString:formattedString];
  return formattedString;
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
