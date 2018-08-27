//
//  GCVideoItemMoveCollectionView.h
//  HQLVideoItemMoveCollectionViewDemo
//
//  Created by 何启亮 on 2018/8/24.
//  Copyright © 2018年 hql_personal_team. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GCVideoItemMoveViewCell.h"

@class GCVideoItemMoveView;

@protocol GCVideoItemMoveViewDelegate <NSObject>

@optional

/**
 判断index的item是否可以移动
 */
- (BOOL)videoItemMoveView:(GCVideoItemMoveView *)moveView canMoveItemAtIndex:(NSInteger)index;

/**
 判断能否移动到toIndex
 */
- (BOOL)videoItemMoveView:(GCVideoItemMoveView *)moveView itemAtIndex:(NSInteger)fromIndex canMoveToIndex:(NSInteger)toIndex;

/**
 准备开始移动 --- 需要在这个代理里面完成数据的调换
 */
- (void)videoItemMoveView:(GCVideoItemMoveView *)moveView itemAtIndex:(NSInteger)fromIndex willMoveToIndex:(NSInteger)toIndex;

/**
 已经移动
 */
- (void)videoItemMoveView:(GCVideoItemMoveView *)moveView itemAtIndex:(NSInteger)fromIndex didMoveToIndex:(NSInteger)toIndex;

/**
 点击
 */
- (void)videoItemMoveView:(GCVideoItemMoveView *)moveView didSelectedItemAtIndex:(NSInteger)index;

/**
 能否选中
 */
- (BOOL)videoItemMoveView:(GCVideoItemMoveView *)moveView canSelectedItemAtIndex:(NSInteger)index;

/**
 删除了item
 */
- (void)videoItemMoveView:(GCVideoItemMoveView *)moveView didRemoveItemAtIndex:(NSInteger)index;

/**
 didReloadData
 */
- (void)videoItemMoveViewDidReloadData:(GCVideoItemMoveView *)moveView;

@end

@protocol GCVideoItemMoveViewDataSource <NSObject>

/**
 获取item的数量
 */
- (NSInteger)videoItemMoveViewNumberOfItem:(GCVideoItemMoveView *)moveView;

/**
 获取item
 */
- (GCVideoItemMoveViewCell *)videoItemMoveView:(GCVideoItemMoveView *)moveView viewForItemAtIndex:(NSInteger)index;

@optional

/**
 获取size
 */
- (CGSize)videoItemMoveViewitemSize:(GCVideoItemMoveView *)moveView;

/**
 获取margin
 */
- (CGFloat)videoItemMoveViewItemMargin:(GCVideoItemMoveView *)moveView;

@end

@interface GCVideoItemMoveView : UIView

/**
 滚动速度
 */
@property (nonatomic, assign) CGFloat scrollingSpeed;

/**
 触发滚动的范围
 */
@property (nonatomic, assign) UIEdgeInsets scrollingTriggerEdgeInsets;

/**
 记录cell
 */
@property (nonatomic, strong, readonly) NSMutableArray *viewArray;

@property (nonatomic, weak) id<GCVideoItemMoveViewDelegate> delegate;

@property (nonatomic, weak) id<GCVideoItemMoveViewDataSource> dataSource;

/**
 手动选中某个item
 */
- (void)selectedItemAtIndex:(NSInteger)index;

/**
 刷新 --- 创建时会默认调用一次
 */
- (void)reloadData;

/**
 移除cell
 */
- (void)removeObjeAtIndex:(NSInteger)index;

+ (CGSize)viewSize;

@end
