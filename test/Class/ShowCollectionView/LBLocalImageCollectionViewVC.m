
//
//  LBCollectionViewVC.m
//  test
//
//  Created by dengweihao on 2018/1/19.
//  Copyright © 2018年 dengweihao. All rights reserved.
//

#import "LBLocalImageCollectionViewVC.h"
#import "LBWebImageCollectionViewVC.h"
#import "LBPhotoBrowserManager.h"

static inline CGSize lb_screenSize(){
    return [UIScreen mainScreen].bounds.size;
}

@interface LBCellModel :NSObject
@property (nonatomic , strong)UIImage *image;
@property (nonatomic , assign)BOOL isAdd;

@end
@implementation LBCellModel
@end

@interface LBCollectionViewCell :UICollectionViewCell
@property (nonatomic , weak)UIImageView *imageView;
@end

@implementation LBCollectionViewCell
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

@interface LBLocalImageCollectionViewVC ()<UICollectionViewDelegateFlowLayout,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate>
@property (nonatomic , weak)UICollectionView *collectionView;
@property (nonatomic , strong)NSMutableArray *datas;

@end

@implementation LBLocalImageCollectionViewVC

static NSString * const reuseIdentifier = @"Cell";

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [[NSMutableArray alloc]init];
    }
    return _datas;
}

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
    [self.collectionView registerClass:[LBCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    LBCellModel *model = [[LBCellModel alloc]init];
    model.isAdd = YES;
    model.image = [UIImage imageNamed:@"add_channel_titlbar_thin_new_night_16x16_"];
    [self.datas addObject:model];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"网络" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightBtnClick {
    LBWebImageCollectionViewVC *cvc = [[LBWebImageCollectionViewVC alloc]init];
    [self.navigationController pushViewController:cvc animated:YES];
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LBCellModel *model = (LBCellModel *)self.datas[indexPath.item];
    LBCollectionViewCell *cell = (LBCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageView.image = model.image;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LBCellModel *model = (LBCellModel *)self.datas[indexPath.item];
    if (model.isAdd) {
        [self getImageFromIpc];
    }else {
        NSMutableArray *items = @[].mutableCopy;
        UICollectionView *cell = [collectionView cellForItemAtIndexPath:indexPath];// 这里不会为空
        for (LBCellModel *showModel in self.datas) {
            if (showModel.isAdd) continue;
            LBPhotoLocalItem *item = [[LBPhotoLocalItem alloc]initWithImage:showModel.image frame:cell.frame];
            [items addObject:item];
        }
        // 这里只要你开心 可以无限addBlock
        weak_self;
        [[[[[LBPhotoBrowserManager defaultManager] showImageWithLocalItems:items selectedIndex:indexPath.row fromImageViewSuperView:collectionView] addLongPressShowTitles:@[@"保存图片",@"删除",@"识别二维码",@"取消"]] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
            LBPhotoBrowserLog(@"%@",title);
            // 这里的indexPath 指的是 这个title 在 @[@"保存图片",@"删除",@"识别二维码",@"取消"] 中的位置,如果想取在当前展示图片在collectionView中的位置,使用[LBPhotoBrowserManager defaultManager].currentPage
        }]addCollectionViewLinkageStyle:UICollectionViewScrollPositionCenteredHorizontally cellReuseIdentifier:reuseIdentifier];
    }
}

- (void)getImageFromIpc
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark -- <UIImagePickerControllerDelegate>--
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        LBCellModel *model = [[LBCellModel alloc]init];
        model.image = image;
        [self.datas insertObject:model atIndex:0];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
    }];
    
}

@end
