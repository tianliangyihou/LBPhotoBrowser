
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

@interface LBOptionView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , weak)UITableView *tableView;

@end

@implementation LBOptionView


- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [photoBrowseManager() currentTitles].count * cellHeight)];
        tableView.bottom = self.bottom;
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
        [self tableView];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissOptionView];
}

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
    photoBrowseManager().titleClickBlock(self.image,indexPath,title);;
    [self dismissOptionView];
}
@end
