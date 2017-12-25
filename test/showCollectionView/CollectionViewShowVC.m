//
//  CollectionViewShowVC.m
//  test
//
//  Created by dengweihao on 2017/11/13.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "CollectionViewShowVC.h"
#import "LBCollectionViewCell.h"
#import "LBPhotoBrowserManager.h"

static NSString * const cellID = @"lbPotoBrowser.cellID";

@interface CollectionViewShowVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation CollectionViewShowVC



- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _flowLayout.itemSize = CGSizeMake(80, 80);
    _flowLayout.minimumInteritemSpacing = 0;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([LBCollectionViewCell class]) bundle:nil];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:cellID];
}


#pragma mark - collectionView 数据源

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    return cell;
}

#pragma mark -  代理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
   

@end

