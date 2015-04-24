//
//  ViewController.m
//  playground
//
//  Created by daniel on 4/3/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>
#import "SearchResultItem.h"
#import "SearchResultItemCell.h"

//SOCIAL_EXTERN NSString *const SLServiceTypeTwitter;
//SOCIAL_EXTERN NSString *const SLServiceTypeFacebook;
//SOCIAL_EXTERN NSString *const SLServiceTypeSinaWeibo;
//SOCIAL_EXTERN NSString *const SLServiceTypeTencentWeibo;
//SOCIAL_EXTERN NSString *const SLServiceTypeLinkedIn;

static NSString *tablewViewcellIdentifier = @"cell";

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *returnedData;
@property (nonatomic, strong) UITableView *tableview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _returnedData = [NSMutableArray array];
    
//    [self loadDataFromURL:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=monkey&rsz=8&start=1"];
    
    self.tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain]; // forget style UITableViewStylePlain :(
    [self.tableview registerClass:[SearchResultItemCell class] forCellReuseIdentifier:tablewViewcellIdentifier];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.rowHeight = 160;
    
    // forget to write autoresizingmask
//    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self leetcode];
    
    [self.view addSubview:self.tableview];
}

//// 11.11 integrating social sharing into apps
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    if ([SLComposeViewController
//         isAvailableForServiceType:SLServiceTypeTwitter]){
//        SLComposeViewController *controller =
//        [SLComposeViewController
//         composeViewControllerForServiceType:SLServiceTypeTwitter];
//        [controller setInitialText:@"MacBook Airs are amazingly thin!"];
//        [controller addImage:[UIImage imageNamed:@"MacBookAir"]];
//        [controller addURL:[NSURL URLWithString:@"http://www.apple.com/"]];
//        controller.completionHandler = ^(SLComposeViewControllerResult result){
//            NSLog(@"Completed");
//        };
////        [self presentViewController:controller animated:YES completion:nil];
//    } else {
//        NSLog(@"The twitter service is not available");
//        // TODO: login your twitter account
//    }
//}
//// end: integrating social sharing into apps

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDataFromURL:(NSString *)urlString {
    
    if (urlString == nil) {
        [NSException raise:@"url" format:@"not valid url", nil];
        return;
    }
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    // 11.1 basic url request
//    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//     11.2 handing timeout in async connection
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0f];
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    NSLog(@"start");
//    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
//    
//        if ([data length]>0 && error == nil) {
//            NSString *html = [[NSString alloc] initWithData:data
//                                                   encoding:NSUTF8StringEncoding];
//            NSLog(@"HTML = %@", html);
//        }
//        else if ([data length]==0 && error == nil) {
//            NSLog(@"Nothing was downloaded.");
//        }
//        else if (error !=nil) {
//            NSLog(@"Error happened = %@", error);
//        }
//        
//    }];
    
//     11.3 downloading sync with NSURLConnection
//    NSString *urlAsString = @"http://www.apple.com";
//    NSURL *urlSync = [NSURL URLWithString:urlAsString];
//    NSURLRequest *urlRequestSync = [NSURLRequest requestWithURL:urlSync];
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSLog(@"Firing synchronous url connection...");
//    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequestSync
//                                         returningResponse:&response
//                                                     error:&error];
//    if ([data length] > 0 && error == nil){
//        NSLog(@"%lu bytes of data was returned.", (unsigned long)[data length]);
//    }
//    else if ([data length] == 0 && error == nil){
//        NSLog(@"No data was returned.");
//    }
//    else if (error != nil){
//        NSLog(@"Error happened = %@", error);
//    }
//    NSLog(@"We are done.");
//    
//    // Firing synchronous url connection...
//    // 252117 bytes of data was returned.
//    // We are done.
    
    // how about use GCD concurrency
    NSLog(@"Firing synchronous url connection...");
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^(void) {
//        NSURL *url = [NSURL URLWithString:urlAsString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                             returningResponse:&response
                                                         error:&error];
        if ([data length] > 0 && error == nil){
            NSLog(@"%lu bytes of data was returned.",
                  (unsigned long)[data length]);
            id jsonObject = [NSJSONSerialization
                             JSONObjectWithData:data
                             options:NSJSONReadingAllowFragments    // accept one or a mixture of following values:NSJSONReadingMutableContainers(array/dict), NSJSONReadingMutableLeaves(excapsulated into instance of mutablestring), NSJSONReadingAllowFragments
                             error:&error];
            if (jsonObject != nil && error == nil){
                NSLog(@"Successfully deserialized...");
                if ([jsonObject isKindOfClass:[NSDictionary class]]){
                    NSDictionary *deserializedDictionary = jsonObject;
//                    NSLog(@"Deserialized JSON Dictionary = %@",
//                          deserializedDictionary);
                    
                    NSArray *stored = [[jsonObject objectForKey:@"responseData"] objectForKey:@"results"];
                    
                    for (NSDictionary *dict in stored) {
                        SearchResultItem *item = [SearchResultItem initSearchResultItemWithDictionary:dict];
                        [_returnedData addObject:item];
                    }
                    
                }
                else if ([jsonObject isKindOfClass:[NSArray class]]){
                    NSArray *deserializedArray = (NSArray *)jsonObject;
                    NSLog(@"Deserialized JSON Array = %@", deserializedArray);
                }
                else {
                    /* Some other object was returned. We don't know how to
                     deal with this situation as the deserializer only
                     returns dictionaries or arrays */
                }
            }
            else if (error != nil){
                NSLog(@"An error happened while deserializing the JSON data.");
            }
            
        }
        else if ([data length] == 0 && error == nil){
            NSLog(@"No data was returned.");
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error);
        }
        [self.tableview reloadData];    // if using asyn, we need to updated table view
    });
    NSLog(@"We are done.");
    NSLog(@"@%lu", [_returnedData count]);
//    Firing synchronous url connection...
//    We are done.
//    252450 bytes of data was returned.
    
    // 11.4 Modifying a URL Request with NSMutableURLRequest
//    NSURL *url = [NSURL URLWithString:urlAsString];
//    NSMutableURLRequest *urlRequest = [NSMutableURLRequest new];
//    [urlRequest setTimeoutInterval:30.0f];
//    [urlRequest setURL:url];
    
    // 11.5 Send GET http request with URLConnection
    // GET -- retrive data from web server.
    //      A GET request is a request to a web server to retrieve data.
    
//    NSString *urlAsString = ;//Place the URL of the web server here;
//    urlAsString = [urlAsString stringByAppendingString:@"?param1=First"];
//    urlAsString = [urlAsString stringByAppendingString:@"&param2=Second"];
//    NSURL *url = [NSURL URLWithString:urlAsString];
//    NSMutableURLRequest *urlRequest =
//    [NSMutableURLRequest requestWithURL:url];
//    [urlRequest setTimeoutInterval:30.0f];
//    [urlRequest setHTTPMethod:@"GET"];        // [urlRequest setHTTPMethod:@"POST"];
    
    // only for POST, DELETE and PUT 11.6 11.7 11.8
    // POST
    // DELETE -- delete a resource from web server.
    // PUT -- place a resource into web server.
//    NSString *body = @"bodyParam1=BodyValue1&bodyParam2=BodyValue2";
//    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    // end: only for POST, DELETE and PUT
    
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [NSURLConnection
//     sendAsynchronousRequest:urlRequest
//     queue:queue
//     completionHandler:^(NSURLResponse *response,
//                         NSData *data,
//                         NSError *error) {
//         if ([data length] >0 && error == nil){
//             NSString *html =
//             [[NSString alloc] initWithData:data
//                                   encoding:NSUTF8StringEncoding];
//             NSLog(@"HTML = %@", html);
//         }
//         else if ([data length] == 0 && error == nil){
//             NSLog(@"Nothing was downloaded.");
//         }
//         else if (error != nil){
//             NSLog(@"Error happened = %@", error);
//         }
//     }];
    
    return;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_returnedData == nil || [_returnedData count] == 0)
        return 8;
    if ([tableView isEqual:self.tableview])
        return [_returnedData count];
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultItemCell *cell = nil;
    
    if ([tableView isEqual:self.tableview]) {
        cell = [tableView dequeueReusableCellWithIdentifier:tablewViewcellIdentifier forIndexPath:indexPath];
        if (_returnedData == nil || [_returnedData count] == 0) {
            cell.textLabel.text = @"default";
            cell.imageView.image = [UIImage imageNamed:@"default.jpg"];
        } else {
            cell.textLabel.text = [((SearchResultItem *)[_returnedData objectAtIndex:indexPath.row]) title];
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[((SearchResultItem *)[_returnedData objectAtIndex:indexPath.row]) tbUrl]]]];
            cell.imageView.image = image;
//            cell.image.image = image;

        }

        NSMutableArray *test = [NSMutableArray array];
        NSString *s = @"ddd";
        [test addObject:s];
        
        __unused NSRange a = NSMakeRange(6, 3);
        
        
        
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - leetcode

- (void)leetcode {
    
// sort Array with NSNumber
//    NSArray *unsortedArray = [NSArray arrayWithObjects:@10, @7, @1, @15, nil];
//    NSArray *sortedArray = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return (NSComparisonResult)[obj1 compare:obj2];
//    }];
//    NSLog(@"%@", sortedArray);  // 1,7,10,15
    
    
    
    
// sort Array with NSString
//    NSArray *unsortedStrings = [NSArray arrayWithObjects:@"abd", @"zoo", @"cat", @"bath", @"1", nil];
//    NSArray *sortedStrings = [unsortedStrings sortedArrayUsingComparator:^NSComparisonResult(NSString *firstString, NSString *secondString) {
//        return [firstString compare:secondString];
//        // if do not care upper case or lower case, then
////        return [firstString caseInsensitiveCompare:secondString];
//    }];
//    NSLog(@"%@", sortedStrings);
    
    
    
    
// two sum
// Input: numbers={2, 7, 11, 15}, target=9
// Output: index1=1, index2=2
//
//    NSArray * input = [NSArray arrayWithObjects:@10, @7, @11, @15, nil];
//    int target = 17;
//
//    [self twoSum:input target:target];
    
    
    
    
// valid palindrome
//
//    NSString *testStr = [NSString stringWithFormat:@""];
//    NSString *testStr2 = [NSString stringWithFormat:@"A man, a plan, a canal: Panama"];
//    NSString *testStr3 = [NSString stringWithFormat:@"Aooa"];
//    
//    BOOL res = [self validPalindrome:testStr2];
//    NSLog(@"%d", res);
    
    
    
    
// strStr
//    int res = [self str:[NSString stringWithFormat:@"hackthonandneedle"] Str:@"needle"];
//    NSLog(@"%d", res);
    
    
    
// reverse words
//    NSString * reversedWords = [self reverseWord:@"the sky is blue"];
//    NSLog(@"%@", reversedWords);
    
    
    
// lengthOfLongestSubstring
//    int maxLen = [self lengthOfLongestSubstring:@"abcdefabcbb"];
//    NSLog(@"%d", maxLen);
    
    

// permutations
    NSArray * permu = [self permute:[NSArray arrayWithObjects:@1, @2, @3, nil]];
    NSLog(@"%@", permu);
}



// two sum
// solution 1: sort array then two pointer
// solution 2: hash table
- (void)twoSum:(NSArray *)input target:(int) target {
    __unused NSMutableArray *output = [NSMutableArray array];
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];   // store in dict, how about store in Set
    int index = 0;
    
    for (NSNumber *item in input) { //fast enumerator
        if ([tempDict objectForKey:item]) {
            NSNumber *index1 = [NSNumber numberWithInt:[[tempDict objectForKey:item] intValue]];
            NSNumber *index2 = [NSNumber numberWithInt:index];
            
            // could not array addObject: index3 or index4, since they are not object, they are int.
            __unused int index3 = [[tempDict objectForKey:item] intValue];
            __unused int index4 = index;
            
            [output addObject:index1];
            [output addObject:index2];
        } else {
            [tempDict setObject:[NSNumber numberWithInt:index] forKey:[NSNumber numberWithInt:target - [item intValue]]];
        }
        index++;
    }
    
    // convert NSMutableArray to NSArray.
    
    __unused NSArray *result = [output copy];
    
}

// two sum
- (BOOL)checkTwoSum:(NSArray *)input target:(int)target {
    NSMutableSet *set = [NSMutableSet set];
    for (NSNumber *item in input) {
        if ([set containsObject:item]) {
            return true;
        } else {
            [set addObject:[NSNumber numberWithInt:target - [item intValue]]];
        }
    }
    return false;
}

// valid palindrome
- (BOOL)validPalindrome:(NSString *)s {
    if(s == nil || s.length == 0)  return true;
    
    int i = 0;
    int j = (int)s.length - 1;
    while (i < j) {
        while (![self isValidLetter:[s substringWithRange:NSMakeRange(i,1)]] && i < j) {
            i++;
        }
        while (![self isValidLetter:[s substringWithRange:NSMakeRange(j,1)]] && i < j) {
            j--;
        }
//        NSRange range1 = NSMakeRange(i,1);
//        NSRange range2 = NSMakeRange(j,1);

        if (![[[s substringWithRange:NSMakeRange(i,1)] lowercaseString] isEqualToString:[[s substringWithRange:NSMakeRange(j,1)] lowercaseString]]) {   // could not use !=, need to use isEqualToString
            return false;
        } else {
            i++;
            j--;
        }
    }
    return true;
}

- (BOOL)isValidLetter:(NSString *)stringChar {
    unichar c = [stringChar characterAtIndex:0];
    NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *letterSet = [NSCharacterSet letterCharacterSet];
    if ([numericSet characterIsMember:c]) {
        NSLog(@"Congrats, it is a number...");
        return true;
    } else if ([letterSet characterIsMember:c]) {
        NSLog(@"Congrats, it is a letter...");
        return true;
    }
    return false;
}

// strStr
- (int)str:(NSString *)str1 Str:(NSString *)str2 {
    if (str1 == nil || str2 == nil)
        return -1;
    
    for (int i = 0; i < str1.length - str2.length + 1; i++) {
        int j = 0;
        for (j = 0; j<str2.length; j++) {
            if ([str1 characterAtIndex:(i+j)] != [str2 characterAtIndex:j]) {
//                NSString *tmpChar = [NSString stringWithFormat:@"%C", [str1 characterAtIndex:i]];
                break;
            }
        }
        
        if (j == str2.length) {
            return i;
//            return (NSUInteger)i;
        }
    }
    return -1;
}

// reverse Words
- (NSString *)reverseWord:(NSString *)s {
    if (s == nil || s.length == 0)
        return s;
    
    NSArray *strArr = [s componentsSeparatedByString:@" "];
    NSUInteger len = [strArr count];
    
    if (len == 0)
        return @"";
    
    NSMutableString *res = [NSMutableString string];
    
    for (int i = (int)len - 1; i>=0; i--) {
        [res appendString:[strArr objectAtIndex:i]];
        [res appendString:@" "];
    }
    
    return res;
}

// longest substring without repeating
- (int)lengthOfLongestSubstring:(NSString *)str {
    if (str.length <= 1)
        return (int)str.length;
    
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    int pre = 0;
    
    for (int i = 0; i < str.length; i++) {
        NSString *tmpChar = [NSString stringWithFormat:@"%C", [str characterAtIndex:i]];
        if (![map objectForKey:tmpChar]) {
            [map setObject:[NSNumber numberWithInt:i] forKey:tmpChar];
        } else {
            pre = fmax(pre, [map count]);
            i = [[map objectForKey:tmpChar] intValue];
            [map removeAllObjects];
        }
    }
    
    return fmax(pre, [map count]);
}

// permutations
- (NSArray *)permute:(NSArray *)nums {
    NSMutableArray *res = [NSMutableArray array];
    if (nums == nil || [nums count] == 0)
        return [res copy];
    
    NSMutableArray *list = [NSMutableArray array];
    [self permutationRes:res withList:list withNums:nums]; // withStartIndex:0
    
    return [res copy];
}

- (void)permutationRes:(NSMutableArray *)res withList:(NSMutableArray *)list withNums:(NSArray *)nums { // withStartIndex:(int)startIndex
    
    if ([list count] == [nums count]) {
        [res addObject:[NSMutableArray arrayWithArray:list]]; // must to create new, do not use list
        return;
    }
    
    for (int i = 0; i < [nums count]; i++) {
        if ([list containsObject:[nums objectAtIndex:i]]) {
            continue;
        }
        [list addObject:[nums objectAtIndex:i]];
        [self permutationRes:res withList:list withNums:nums];  // withStartIndex:0
        [list removeObject:[nums objectAtIndex:i]];
    }
}

//

@end
