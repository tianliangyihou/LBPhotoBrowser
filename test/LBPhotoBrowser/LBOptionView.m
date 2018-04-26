//
//  LBOptionView.m
//  test
//
//  Created by dengweihao on 2017/8/17.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBOptionView.h"
#import "LBPhotoBrowserConst.h"
#import "LBPhotoBrowserManager.h"

static NSString * ID = @"lb.optionView";

static CGFloat cellHeight = 50;

static inline LBPhotoBrowserManager * photoBrowseManager() {
    return [LBPhotoBrowserManager defaultManager];
}
static inline CGFloat getTableViewHeight() {
    return [photoBrowseManager() currentTitles].count * cellHeight;
}
@interface LBOptionView ()<UITableViewDelegate,UITableViewDataSource ,UIGestureRecognizerDelegate>

@property (nonatomic , weak)UITableView *tableView;

@end

@implementation LBOptionView


- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH,getTableViewHeight() + LB_BOTTOM_MARGIN)];
        tableView.bottom = LB_IS_IPHONEX ? self.bottom - LB_BOTTOM_MARGIN_IPHONEX : self.bottom;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.bounces = NO;
        [self addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

+ (instancetype)showOptionView {
    LBOptionView *view = [[self alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    CGFloat tableViewHeight = getTableViewHeight();
    [UIView animateWithDuration:0.25 animations:^{
        view.tableView.top = SCREEN_HEIGHT - tableViewHeight - LB_BOTTOM_MARGIN;
    }];
    return view;
}

+ (instancetype)showOptionViewWithCurrentCellImage:(UIImage *)image {
    LBOptionView *view = [self showOptionView];
    view.image = image;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        self.frame = [UIScreen mainScreen].bounds;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maskViewTap:)];
        [self addGestureRecognizer:tap];
        tap.delegate = self;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewPan:)];
        [self addGestureRecognizer:pan];

    }
    return self;
}

- (void)maskViewTap:(UITapGestureRecognizer *)tap {
    [self dismissOptionView];
}
- (void)maskViewPan:(UIPanGestureRecognizer *)pan {}

#pragma mark - bgView的点击事件

- (void)dismissOptionView {
    weak_self;
    [UIView animateWithDuration:0.25 animations:^{
        wself.tableView.top = SCREEN_HEIGHT;
    }completion:^(BOOL finished) {
        [wself removeFromSuperview];
    }];
}

#pragma mark - tableView数据源

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [photoBrowseManager() currentTitles].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.textLabel.text = [photoBrowseManager() currentTitles][indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    return cell;
}
#pragma mark - tableView的代理

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = photoBrowseManager().currentTitles[indexPath.row];
    NSArray *models = [photoBrowseManager().photoBrowserView valueForKeyPath:@"models"];
    LBScrollViewStatusModel *statusModel = models[photoBrowseManager().currentPage];
    if (statusModel.currentPageImage.images.count > 1) {
        if (photoBrowseManager().titleClickBlock) {
            NSData *gifData = [statusModel diskImageDataBySearchingAllPathsForKey:statusModel.url.absoluteString]; photoBrowseManager().titleClickBlock(statusModel.currentPageImage,indexPath,title,YES,gifData);;
        }
    }else {
        if (photoBrowseManager().titleClickBlock) {
            photoBrowseManager().titleClickBlock(statusModel.currentPageImage,indexPath,title,statusModel.isGif,statusModel.gifData);;
        }
    }
    [self dismissOptionView];
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch  {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"LBOptionView"]) {
        return YES;
    }
    return NO;
}



@end
