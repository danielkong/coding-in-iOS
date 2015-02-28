//
//  ViewController.m
//  collectionView
//
//  Created by daniel on 2/26/15.
//  Copyright (c) 2015 DK. All rights reserved.
//

#import "ViewController.h"
#import "imageCollectionViewCell.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UICollectionView *imageCollectionView;
@property (nonatomic, retain) NSArray *imageURLs;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *tableData;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSArray *imagesArray;
@property (nonatomic, retain) NSArray *fetchedData;
@property (nonatomic, retain) NSMutableArray *fetchedDataName;

// handle with collection properties.
@property (nonatomic, retain) UIView *imageCollectionViewContainer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // init data
    _tableData = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];

    _fetchedDataName = [[NSMutableArray alloc] init];
    _fetchedData = [[NSArray alloc] init];
    
    // show in table view.
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    // fetch data. and init data property.
    NSString * urlRequest = @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=monkey&rsz=8&start=10";
    NSURL *imageURL = [NSURL URLWithString:urlRequest];
    
    dispatch_async(kBgQueue, ^{
        self.data = [NSData dataWithContentsOfURL: imageURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:_data waitUntilDone:YES];
    });
    
    // show in collection view.
    _imageCollectionViewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _imageCollectionViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_imageCollectionViewContainer];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //    [flowLayout setItemSize:CGSizeMake(30, 30)];
    [flowLayout setMinimumInteritemSpacing:10.f];
    [flowLayout setMinimumLineSpacing:10.f];
    
    _imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, 7, _imageCollectionViewContainer.bounds.size.width - 30,  _imageCollectionViewContainer.bounds.size.height - 7*2) collectionViewLayout:flowLayout];
    _imageCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _imageCollectionView.delegate = self;
    _imageCollectionView.dataSource = self;
    _imageCollectionView.backgroundColor = [UIColor clearColor];
    _imageCollectionView.showsHorizontalScrollIndicator = NO;
    
    [_imageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myIdentifier"];

    [_imageCollectionViewContainer addSubview:_imageCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;//_imageURLs.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myIdentifier = @"myIdentifier";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:myIdentifier forIndexPath:indexPath];
    if (nil == cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
    cell.backgroundColor = [UIColor orangeColor];
    
    
//    [cell.imageView setImageWithURL:[NSURL URLWithString:self.imageURLs[indexPath.row]]];
    return cell;
}

# pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

# pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [_tableData count];
    return [_fetchedDataName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
//    // show localData.
//    cell.textLabel.text = [_tableData objectAtIndex:indexPath.row];
    
    // show fetched data.
    cell.textLabel.text = [_fetchedDataName objectAtIndex:indexPath.row];
    
    return cell;
}

# pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // deselect
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

# pragma mark - private

-(void)fetchedData:(NSData *)responsedata
{
    NSError* error;
    id json = [NSJSONSerialization JSONObjectWithData:responsedata options:kNilOptions error:&error];
    self.fetchedData = [[json objectForKey:@"responseData"] objectForKey:@"results"];
    if (_fetchedData.count) {
        for (NSDictionary *item in _fetchedData) {
            [_fetchedDataName addObject:[item objectForKey:@"titleNoFormatting"]];

        }

        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.imagecollection reloadData];
            [self.tableView reloadData];
        });
    }
    NSLog(@"images,%@",self.fetchedDataName);
}

@end
