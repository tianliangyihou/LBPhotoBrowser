//
//  LBWebImageCollectionViewVC.m
//  test
//
//  Created by dengweihao on 2018/1/22.
//  Copyright © 2018年 dengweihao. All rights reserved.
//

#import "LBWebImageCollectionViewVC.h"
#import "LBPhotoBrowserManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

static inline CGSize lb_screenSize(){
    return [UIScreen mainScreen].bounds.size;
}


@interface LBWebCollectionViewCell :UICollectionViewCell
@property (nonatomic , weak)UIImageView *imageView;
@end

@implementation LBWebCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        self.backgroundColor = [UIColor whiteColor];
        _imageView = imageView;
    }
    return self;
}
@end

@interface LBWebImageCollectionViewVC ()<UICollectionViewDelegateFlowLayout,
                                         UICollectionViewDelegate,
                                         UICollectionViewDataSource,
                                         UIImagePickerControllerDelegate,
                                         UINavigationControllerDelegate>
@property (nonatomic , weak)UICollectionView *collectionView;
@property (nonatomic , strong)NSArray <NSString *> *lagerURLStrings;

@end

@implementation LBWebImageCollectionViewVC

static NSString * const reuseIdentifier = @"webCell";

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(100, 100);
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,120,lb_screenSize().width, 110) collectionViewLayout:flowLayout];
        [self.view addSubview:collectionView];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor lightGrayColor];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    if ([UIDevice currentDevice].systemVersion.floatValue > 11.0) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.lagerURLStrings = @[//大图
                             @"http://p7.pstatp.com/large/w960/5321000135125ebb938a",
                             @"http://ww1.sinaimg.cn/large/61b69811gw1f6bqb1bfd2j20b4095dfy.jpg",
                             @"http://ww1.sinaimg.cn/large/54477ddfgw1f6bqkbanqoj20ku0rsn4d.jpg",
                             @"http://ww4.sinaimg.cn/large/006ka0Iygw1f6b8gpwr2tj30bc0bqmyz.jpg",
                             @"http://ww2.sinaimg.cn/large/9c2b5f31jw1f6bqtinmpyj20dw0ae76e.jpg",
                             @"http://ww1.sinaimg.cn/large/536e7093jw1f6bqdj3lpjj20va134ana.jpg",
                             ];
    [self.collectionView registerClass:[LBWebCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.lagerURLStrings.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBWebCollectionViewCell *cell = (LBWebCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.lagerURLStrings[indexPath.row]]];
    return cell;
}
#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableArray *items = @[].mutableCopy;
    UICollectionView *cell = [collectionView cellForItemAtIndexPath:indexPath];// 这里不会为空
    for (int i = 0; i < self.lagerURLStrings.count; i++ ) {
        LBWebCollectionViewCell *cell = ( LBWebCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        LBPhotoWebItem *item = [[LBPhotoWebItem alloc]initWithURLString:self.lagerURLStrings[i] frame:cell.frame];
        item.placeholdImage = [UIImage imageNamed:@"placehold.jpeg"];
        [items addObject:item];
    }
    // 这里只要你开心 可以无限addBlock
    [[[[[LBPhotoBrowserManager defaultManager]showImageWithWebItems:items selectedIndex:indexPath.row fromImageViewSuperView:collectionView] addCollectionViewLinkageStyle:UICollectionViewScrollPositionCenteredHorizontally cellReuseIdentifier:reuseIdentifier]addLongPressShowTitles:@[@"保存图片",@"删除",@"识别二维码",@"取消"]]addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title, BOOL isGif, NSData *gifImageData) {
        LBPhotoBrowserLog(@"%@",title);
    }].lowGifMemory = YES;
    [LBPhotoBrowserManager defaultManager].needPreloading = NO;
}
@end
