//
//  ViewController.m
//  HQLVideoItemMoveCollectionViewDemo
//
//  Created by 何启亮 on 2018/8/24.
//  Copyright © 2018年 hql_personal_team. All rights reserved.
//

#import "ViewController.h"

#import <Masonry.h>

#import "GCVideoItemMoveView.h"

@interface ViewController () <GCVideoItemMoveViewDelegate, GCVideoItemMoveViewDataSource>

@property (nonatomic, strong) GCVideoItemMoveView *moveView;

@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) NSMutableArray <GCVideoItemMoveViewCellModel *>*modelArray;

@property (nonatomic, strong) GCVideoItemMoveViewCellModel *currentModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self bulidData];
    [self prepareUI];
    [self.moveView reloadData];
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

- (void)prepareUI {
    GCVideoItemMoveView *moveView = [[GCVideoItemMoveView alloc] init];
    [self.view addSubview:moveView];
    self.moveView = moveView;
    moveView.delegate = self;
    moveView.dataSource = self;
    moveView.backgroundColor = [UIColor blackColor];
    [moveView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.centerY.equalTo(self.view);
        make.height.mas_equalTo(100);
        
    }];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:deleteButton];
    self.deleteButton = deleteButton;
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(onButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(moveView.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(100);
    }];
}

- (void)bulidData {
    for (NSInteger i = 0; i < 30; i++) {
        GCVideoItemMoveViewCellModel *model = [[GCVideoItemMoveViewCellModel alloc] init];
        model.isSelected = NO;
        model.color = (i % 2 == 0) ? [UIColor redColor] : [UIColor blueColor];
        [self.modelArray addObject:model];
    }
}

- (void)onButtonClick {
    if (!self.currentModel) {
        return;
    }
    NSInteger deleteIndex = [self.modelArray indexOfObject:self.currentModel];
    [self.modelArray removeObject:self.currentModel];
    self.currentModel = nil;
    [self.moveView removeObjeAtIndex:deleteIndex];
}

#pragma mark - GCVideoItemMoveViewDelegate

/**
 判断index的item是否可以移动
 */
- (BOOL)videoItemMoveView:(GCVideoItemMoveView *)moveView canMoveItemAtIndex:(NSInteger)index {
    return YES;
}

/**
 判断能否移动到toIndex
 */
- (BOOL)videoItemMoveView:(GCVideoItemMoveView *)moveView itemAtIndex:(NSInteger)fromIndex canMoveToIndex:(NSInteger)toIndex {
    return YES;
}

/**
 准备开始移动 --- 需要在这个代理里面完成数据的调换
 */
- (void)videoItemMoveView:(GCVideoItemMoveView *)moveView itemAtIndex:(NSInteger)fromIndex willMoveToIndex:(NSInteger)toIndex {
    GCVideoItemMoveViewCellModel *model = self.modelArray[fromIndex];
    [self.modelArray removeObject:model];
    if (toIndex >= self.modelArray.count) {
        [self.modelArray addObject:model];
    } else {
        [self.modelArray insertObject:model atIndex:toIndex];
    }
}

/**
 已经移动
 */
- (void)videoItemMoveView:(GCVideoItemMoveView *)moveView itemAtIndex:(NSInteger)fromIndex didMoveToIndex:(NSInteger)toIndex {
    
}

/**
 点击
 */
- (void)videoItemMoveView:(GCVideoItemMoveView *)moveView didSelectedItemAtIndex:(NSInteger)index {
    
    if (self.currentModel) {
        self.currentModel.isSelected = NO;
        GCVideoItemMoveViewCell *last = [moveView.viewArray objectAtIndex:[self.modelArray indexOfObject:self.currentModel]];
        [last setModel:self.currentModel];
    }
    
    self.currentModel = self.modelArray[index];
    self.currentModel.isSelected = YES;
    GCVideoItemMoveViewCell *current = [moveView.viewArray objectAtIndex:index];
    [current setModel:self.currentModel];
}

/**
 能否选中
 */
- (BOOL)videoItemMoveView:(GCVideoItemMoveView *)moveView canSelectedItemAtIndex:(NSInteger)index {
    return YES;
}

/**
 删除了item
 */
- (void)videoItemMoveView:(GCVideoItemMoveView *)moveView didRemoveItemAtIndex:(NSInteger)index {
    // 选中下一个
    if (self.modelArray.count == 0) {
        return;
    }
    NSInteger selectedIndex = index;
    if (selectedIndex >= self.modelArray.count - 1) {
        selectedIndex = self.modelArray.count - 1;
    }
    
    [moveView selectedItemAtIndex:selectedIndex];
}

/**
 did reload data
 */
- (void)videoItemMoveViewDidReloadData:(GCVideoItemMoveView *)moveView {
    [moveView selectedItemAtIndex:0];
}

#pragma mark - GCVideoItemMoveViewDataSource

/**
 获取item的数量
 */
- (NSInteger)videoItemMoveViewNumberOfItem:(GCVideoItemMoveView *)moveView {
    return self.modelArray.count;
}

/**
 获取item
 */
- (GCVideoItemMoveViewCell *)videoItemMoveView:(GCVideoItemMoveView *)moveView viewForItemAtIndex:(NSInteger)index {
    GCVideoItemMoveViewCellModel *model = self.modelArray[index];
    GCVideoItemMoveViewCell *cell = [[GCVideoItemMoveViewCell alloc] init];
    [cell setModel:model];
    return cell;
}

/**
 获取size
 */
- (CGSize)videoItemMoveViewitemSize:(GCVideoItemMoveView *)moveView {
    return CGSizeMake(50, 50);
}

/**
 获取margin
 */
- (CGFloat)videoItemMoveViewItemMargin:(GCVideoItemMoveView *)moveView {
    return 2;
}

#pragma mark - getter

- (NSMutableArray<GCVideoItemMoveViewCellModel *> *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

@end
