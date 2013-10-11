//
//  CollectionViewController.m
//  CollectionViewTut
//
//  Created by developer on 10/1/13.
//  Copyright (c) 2013 developer. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionCell.h"

@interface CollectionViewController ()
{
    NSArray * arrayCollectionImages;
}

@end

@implementation CollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    arrayCollectionImages = [[NSArray alloc] initWithObjects:@"x", @"k", @"o", @"n", @"g",nil];

    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReuseID" forIndexPath:indexPath];
    
    [[cell collectionImageView]setImage:[UIImage imageNamed:[arrayCollectionImages objectAtIndex:indexPath.item]]];
    
    return cell;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrayCollectionImages count];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
