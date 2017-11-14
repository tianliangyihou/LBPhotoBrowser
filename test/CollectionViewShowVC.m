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

@property (nonatomic , strong)NSArray *urlStrings;

@property (nonatomic , strong)NSArray *unwantedStrings;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation CollectionViewShowVC

- (NSArray *)urlStrings {
    if (!_urlStrings) {
        _urlStrings = @[
                        
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1503555021950&di=17c2df6a4e00eb9cd903ca4b242420e6&imgtype=0&src=http%3A%2F%2Fpic.92to.com%2Fanv%2F201606%2F27%2Feo5n02tvqa5.gif",
                        
                        // 这个gif144张 全部加载在内存中占用210M
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1504425455943&di=26c76de065684dcca127e0970254518c&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F0143d4578075450000012e7eb2106a.gif",
                        
                        @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1929354940,3549861327&fm=117&gp=0.jpg",
                        
                        [[NSBundle mainBundle] pathForResource:@"loner.jpg" ofType:nil],
                        
                        [[NSBundle mainBundle] pathForResource:@"timg.gif" ofType:nil],
                        
                        @"http://ww4.sinaimg.cn/bmiddle/406ef017jw1ec40av2nscj20ip4p0b29.jpg"
                        ];
    }
    return _urlStrings;
}

- (NSArray *)unwantedStrings {
    if (!_unwantedStrings) {
        _unwantedStrings =  @[
                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1504425455943&di=26c76de065684dcca127e0970254518c&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F0143d4578075450000012e7eb2106a.gif",
                      @"http://ww4.sinaimg.cn/bmiddle/406ef017jw1ec40av2nscj20ip4p0b29.jpg"
                              ];
    }
    return _unwantedStrings;
}

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _contentLabel.text = @"这里可以忽略某个cell的点击事件,以及忽略该cell图片的展示 \n这里忽略了第2和6个cell \n\n当你通过拖动手势pop这个界面的时候,会发现展示动图的imageView上的image消失了 \n如果有兴趣点击测试按钮后,进行拖动(真机有效)"; 
}


#pragma mark - collectionView 数据源

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.urlStrings.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.urlString = self.urlStrings[indexPath.row];
    return cell;
}

#pragma mark -  代理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlString = self.urlStrings[indexPath.row];
    if ([self.unwantedStrings containsObject:urlString]) {
        LBPhotoBrowserLog(@"点击了 --- %@",indexPath);
        return;
    }
    
    [[LBPhotoBrowserManager defaultManager] showImageWithURLArray:self.urlStrings fromCollectionView:collectionView selectedIndex:(int)indexPath.row unwantedUrls:self.unwantedStrings];
    [[[LBPhotoBrowserManager defaultManager] addLongPressShowTitles:@[@"保存图片",@"分享",@"识别二维码",@"取消"]] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
        LBPhotoBrowserLog(@"%@",title);
    }].lowGifMemory = YES;
}

@end

