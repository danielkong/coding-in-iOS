//
//  CollectionViewController.m
//  playground
//
//  Created by daniel on 4/4/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "CollectionViewController.h"
#import "SearchResultItem.h"
#import "SearchRresultCollectionViewCell.h"

static NSString *collectionViewCellIdentifier = @"collectionViewCell";

@interface CollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *returnedData;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _returnedData = [NSMutableArray array];

    UICollectionViewFlowLayout *flowLayout = [self flowLayout];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellIdentifier];
    [self.view addSubview:self.collectionView];
    
    [self loadDataFromURL:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=monkey&rsz=8&start=1"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (UICollectionViewFlowLayout *)flowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.minimumLineSpacing = 15.0f;
    flowLayout.minimumInteritemSpacing = 5.0f;
    flowLayout.itemSize = CGSizeMake(40, 40);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f); //top, left, bottom, right
    
    return flowLayout;
}

- (void)loadDataFromURL:(NSString *)urlString {
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    NSError *error = nil;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSLog(@"start");
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length]>0 && error == nil) {
            NSLog(@"get the data");
            NSDictionary *jsonObject = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:NSJSONReadingAllowFragments
                          error:&error];
            if (jsonObject != nil && error == nil) {
                if ([jsonObject isKindOfClass:[NSDictionary class]]){
                    NSArray *stored = [[jsonObject objectForKey:@"responseData"] objectForKey:@"results"];
                    
                    for (NSDictionary *dict in stored) {
                        SearchResultItem *item = [SearchResultItem initSearchResultItemWithDictionary:dict];
                        [_returnedData addObject:item];
                    }
                    NSLog(@"%lu", [_returnedData count]);
                }
            } else if (error != nil) {
                NSLog(@"An error happened while deserializing the JSON data.");
            }
        } else if ([data length] == 0 && error == nil) {
            NSLog(@"Nothing was downloaded.");
        } else if (error !=nil) {
            NSLog(@"Error happened = %@", error);
        }
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([_returnedData count] == 0 || _returnedData == nil)
        return 8;
    if ([collectionView isEqual:self.collectionView]) {
        return [_returnedData count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchRresultCollectionViewCell *cell = nil;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellIdentifier forIndexPath:indexPath];
    if ([collectionView isEqual:self.collectionView]) {
        if (_returnedData == nil || [_returnedData count] == 0) {
//            cell.imageView.image = [UIImage imageNamed:@"test-icon"];
        } else {
            cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[((SearchResultItem *)[_returnedData objectAtIndex:indexPath.row]) tbUrl]]]];
        }
    }
    return cell;
}


@end
