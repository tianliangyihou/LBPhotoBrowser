//
//  LBBaseController.m
//  test
//
//  Created by dengweihao on 2017/12/27.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBBaseController.h"

@interface LBBaseController ()

@end

@implementation LBBaseController

- (void)dealloc {
    NSLog(@"%@ 销毁了",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _models = @[].mutableCopy;
    [self.tableView registerClass:[LBCell class] forCellReuseIdentifier:ID];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (int i = 0; i < self.lagerURLStrings.count; i++) {
            LBURLModel *model = [LBURLModel new];
            model.thumbnailURLString = self.thumbnailURLStrings[i];
            model.largeURLString = self.lagerURLStrings[i];
            [items addObject:model];
        }
        
        for (int i = 0; i < 20; i++) {
            int count = arc4random() % 9;// [0,9)
            LBModel *model = [LBModel new];
            for (int i = 0; i < count ; i++) {
                int x = arc4random() % self.lagerURLStrings.count;
                LBURLModel *urlModel = items[x];
                LBURLModel *newModel = [[LBURLModel alloc]init];
                newModel.thumbnailURLString = urlModel.thumbnailURLString;
                newModel.largeURLString = urlModel.largeURLString;
                [model.urls addObject:newModel];
            }
            [model loadFrames];
            [self.models addObject:model];
        }
        
        
        // 确保第一组数 含有9张图片
        LBModel *model = self.models.firstObject;
        [model.urls removeAllObjects];
        [model.frames removeAllObjects];
        for (int i = 0; i < 9; i++) {
            LBURLModel *newModel = [[LBURLModel alloc]init];
            LBURLModel *urlModel = items[i];
            newModel.thumbnailURLString = urlModel.thumbnailURLString;
            newModel.largeURLString = urlModel.largeURLString;
            [model.urls addObject:newModel];
        }
        [model loadFrames];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LBCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.model = self.models[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LBModel *model = self.models[indexPath.row];
    return model.height + 50;
}

@end
