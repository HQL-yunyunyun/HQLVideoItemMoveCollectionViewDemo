//
//  GCVideoItemMoveCollectionView.m
//  HQLVideoItemMoveCollectionViewDemo
//
//  Created by 何启亮 on 2018/8/24.
//  Copyright © 2018年 hql_personal_team. All rights reserved.
//

#import "GCVideoItemMoveView.h"
#import <Masonry.h>
#import "CADisplayLink+GC_userInfo.h"
#import "UIScrollView+GC_BoundaryScroll.h"

static CGFloat kAnimationDuration = 0.3f;

static NSString *kCellReuseId = @"kCellReuseId";
static CGFloat kMargin = 1.0;

@interface GCVideoItemMoveView ()

/**
 scrollView
 */
@property (nonatomic, strong) UIScrollView *scrollView;

/**
 当前选中的index
 */
@property (nonatomic, assign) NSInteger currentSelectedIndex;

/**
 手势
 */
@property (nonatomic, strong) UIPanGestureRecognizer *currentPanGesture;

/**
 记录cell
 */
@property (nonatomic, strong) NSMutableArray *viewArray;

/**
 在边界时的移动
 */
@property (nonatomic, strong) CADisplayLink *displayLink;

/**
 记录上次移动的位置
 */
@property (nonatomic, assign) CGPoint panLastLocationInCollectionView;

/**
 动画期间不可以选中
 */
@property (nonatomic, assign) BOOL isDurationAnimation;

/**
 margin
 */
@property (nonatomic, assign) CGFloat itemMargin;

@property (nonatomic, assign) CGSize itemSize;

@end

@implementation GCVideoItemMoveView

#pragma mark - initialize method

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self prepareUI];
        [self setDefaults];
    }
    return self;
}

+ (CGSize)viewSize {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    return CGSizeMake(width, 50);
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - prepareUI

- (void)setDefaults {
    _scrollingSpeed = 100.0f;
    _scrollingTriggerEdgeInsets = UIEdgeInsetsMake(0, 50.0, 0, 50.0);
    [self setupBoundaryScroll];
}

- (void)prepareUI {
    // 创建scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    scrollView.contentInset = UIEdgeInsetsMake(0, [[self class] viewSize].width * 0.5, 0, [[self class] viewSize].width * 0.5);
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - event

- (void)selectedItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.viewArray.count) {
        NSAssert(NO, @"%s %d %@", __func__, __LINE__, @"");
        return;
    }
    
    [self cellClickHandle:[self.viewArray objectAtIndex:index]];
}

- (void)setupBoundaryScroll {
    self.scrollView.gc_scrollingSpeed = _scrollingSpeed;
    self.scrollView.gc_scrollingTriggerEdgeInsets = _scrollingTriggerEdgeInsets;
    __weak typeof(self) _self = self;
    self.scrollView.gc_boundaryScrollHandle = ^(CGPoint scrollDistancePoint, GCScrollingDirection scrollingDirection) {
        // view的移动
        [_self invalidateLayoutIfNecessaryWithMovePoint:scrollDistancePoint];
        _self.panLastLocationInCollectionView = GC_CGPointAdd(_self.panLastLocationInCollectionView, scrollDistancePoint);
    };
}

- (void)invalidateBoundaryScroll {
    [self.scrollView gc_invalidatesScrollTimer];
    self.scrollView.gc_scrollingSpeed = 0.0;
    self.scrollView.gc_scrollingTriggerEdgeInsets = UIEdgeInsetsZero;
    self.scrollView.gc_boundaryScrollHandle = nil;
}

/**
 移除cell
 */
- (void)removeObjeAtIndex:(NSInteger)index {
    if (index < 0 || index > self.viewArray.count) {
        NSAssert(NO, @"%s %d %@", __func__, __LINE__, @"");
        return;
    }
    
    self.isDurationAnimation = YES;
    
    // 移除view
    @try {
        
        // 获取cell
        GCVideoItemMoveViewCell *cell = self.viewArray[index];
        cell.alpha = 1.0;
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            
            cell.alpha = 0.0;
            cell.transform = CGAffineTransformMakeScale(0.1, 0.1);
            
            if (index == self.viewArray.count - 1) {
                // 最后一个
                return;
            }
            
            for (NSInteger i = (index + 1); i < self.viewArray.count; i++) {
                UIView *aCell = self.viewArray[i];
                
                aCell.center = GC_CGPointSubtract(aCell.center, CGPointMake([self totalCellWidth], 0));
            }
            
        } completion:^(BOOL finished) {
            
            self.isDurationAnimation = NO;
            
            // 移除
            [cell removeFromSuperview];
            [self.viewArray removeObject:cell];
            
            [self.scrollView setContentSize:CGSizeMake(CGRectGetMaxX([self.viewArray.lastObject frame]) + (self.viewArray.lastObject ? self.itemMargin : 0), self.scrollView.contentSize.height)];
            
            // 回调
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoItemMoveView:didRemoveItemAtIndex:)]) {
                [self.delegate videoItemMoveView:self didRemoveItemAtIndex:index];
            }
            
        }];
        
    } @catch (NSException *exception) {
        NSAssert(NO, @"%s %d %@", __func__, __LINE__, exception);
    }
}

/**
 更新数据源
 */
- (void)reloadData {
    
    self.itemMargin = kMargin;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(videoItemMoveViewItemMargin:)]) {
        self.itemMargin = [self.dataSource videoItemMoveViewItemMargin:self];
    }
    
    self.itemSize = CGSizeZero;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(videoItemMoveViewitemSize:)]) {
        self.itemSize = [self.dataSource videoItemMoveViewitemSize:self];
    }
    
    [self.scrollView layoutIfNeeded];
    
    for (UIView *view in self.viewArray) {
        [view removeFromSuperview];
    }
    [self.viewArray removeAllObjects];
    
    NSInteger numberOfItem = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(videoItemMoveViewNumberOfItem:)]) {
        numberOfItem = [self.dataSource videoItemMoveViewNumberOfItem:self];
    } else {
        NSAssert(NO, @"%s %d %@", __func__, __LINE__, @"");
        return;
    }
    
    UIView *lastView = nil;
    CGFloat maxHeight = 0;
    for (NSInteger i = 0; i < numberOfItem; i++) {
        GCVideoItemMoveViewCell *cell = nil;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(videoItemMoveView:viewForItemAtIndex:)]) {
            cell = [self.dataSource videoItemMoveView:self viewForItemAtIndex:i];
        } else {
            NSAssert(NO, @"%s %d %@", __func__, __LINE__, @"");
            return;
        }
        
        if (![cell isKindOfClass:[GCVideoItemMoveViewCell class]]) {
            NSAssert(NO, @"%s %d %@", __func__, __LINE__, @"");
            return;
        }
        
        CGSize size = self.itemSize;
        
        CGFloat x = CGRectGetMaxX(lastView.frame) + self.itemMargin + (lastView ? self.itemMargin : 0);
        [cell setFrame:CGRectMake(x, (self.scrollView.bounds.size.height - size.height) * 0.5, size.width, size.height)];
        
        if (size.height >= maxHeight) {
            maxHeight = size.height;
        }
        
        __weak typeof(self) _self = self;
        cell.clickHandle = ^(GCVideoItemMoveViewCell *aCell) {
            [_self cellClickHandle:aCell];
        };
        
        lastView = cell;
        [self.scrollView addSubview:cell];
        [self.viewArray addObject:cell];
        
    }
    
    [self.scrollView setContentSize:CGSizeMake(CGRectGetMaxX(lastView.frame) + (lastView ? self.itemMargin : 0), maxHeight)];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoItemMoveViewDidReloadData:)]) {
        [self.delegate videoItemMoveViewDidReloadData:self];
    }
}

/**
 刷新cell的手势
 */
- (void)refreshPanGesture:(NSInteger)index isAdd:(BOOL)isAdd {
    
    if (index < 0 || index >= self.viewArray.count) {
        NSAssert(NO, @"%s %d %@", __func__, __LINE__, @"");
        return;
    }
    
    GCVideoItemMoveViewCell *cell = self.viewArray[index];
    
    // 更新手势
    if (!isAdd) {
        // 移除手势
        [cell removeGestureRecognizer:self.currentPanGesture];
    } else {
        // 添加手势
        [cell addGestureRecognizer:self.currentPanGesture];
    }
    
}

/**
 cell的点击事件
 */
- (void)cellClickHandle:(GCVideoItemMoveViewCell *)cell {
    // 点击
    if (self.isDurationAnimation) {
        // 不能点击
        return;
    }
    
    NSInteger index = [self.viewArray indexOfObject:cell];
    if (index == NSNotFound) {
        return;
    }
    
    // 能否选中
    BOOL canSelected = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoItemMoveView:canSelectedItemAtIndex:)]) {
        canSelected = [self.delegate videoItemMoveView:self canSelectedItemAtIndex:index];
    }
    if (!canSelected) {
        return;
    }
    
    self.currentSelectedIndex = index;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoItemMoveView:didSelectedItemAtIndex:)]) {
        [self.delegate videoItemMoveView:self didSelectedItemAtIndex:index];
    }
    
    // 判断能否移动
    BOOL canMove = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoItemMoveView:canMoveItemAtIndex:)]) {
        canMove = [self.delegate videoItemMoveView:self canMoveItemAtIndex:index];
    }
    if (canMove) {
        [self refreshPanGesture:index isAdd:YES];
    }
}

#pragma mark - gesture handle

/**
 手势的处理方法
 */
- (void)panGestureHandle:(UIPanGestureRecognizer *)panGesture {
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.isDurationAnimation = YES;
            // 记录初始位置
            self.panLastLocationInCollectionView = [panGesture locationInView:self.scrollView];
            
            // 移动到第一层
            GCVideoItemMoveViewCell *cell = self.viewArray[self.currentSelectedIndex];
            [self.scrollView bringSubviewToFront:cell];
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            CGPoint panMoveInCollectionView = GC_CGPointSubtract([panGesture locationInView:self.scrollView], self.panLastLocationInCollectionView);
            
            [self invalidateLayoutIfNecessaryWithMovePoint:panMoveInCollectionView];
            
            self.panLastLocationInCollectionView = [panGesture locationInView:self.scrollView];
            
            // 设置定时器 --- 只有水平移动
            UIView *currentCell = self.viewArray[self.currentSelectedIndex];
            [self.scrollView gc_boundaryScrollWithCurrentPoint:currentCell.center scrollDirection:kGCScrollDirectionHorizontal];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
            
            // 还原
            [UIView animateWithDuration:kAnimationDuration animations:^{
                UIView *cell = self.viewArray[self.currentSelectedIndex];
                cell.center = CGPointMake((self.currentSelectedIndex + 0.5) * [self totalCellWidth], cell.center.y);
            } completion:^(BOOL finished) {
                
            }];
            
            self.isDurationAnimation = NO;
            
            [self.scrollView gc_invalidatesScrollTimer];
            
            break;
        }
        default: { break; }
    }
    
}

#pragma mark - invalidateLayout method

/**
 view的移动
 */
- (void)invalidateLayoutIfNecessaryWithMovePoint:(CGPoint)point {
    // 获取当前要移动的view
    if (self.currentSelectedIndex < 0 || self.currentSelectedIndex >= self.viewArray.count) {
        NSAssert(NO, @"%s %d %@", __func__, __LINE__, @"");
        return;
    }
    
    GCVideoItemMoveViewCell *cell = self.viewArray[self.currentSelectedIndex];
    // 只移动x值
    CGPoint afterMovePoint = GC_CGPointAdd(cell.center, CGPointMake(point.x, 0));
    
    // 可以超出范围
    cell.center = afterMovePoint;
    
    // 判断是否有超出范围
    BOOL isOver = NO;
    if (afterMovePoint.x < ([self totalCellWidth] * 0.5)) {
        isOver = YES;
        afterMovePoint.x = [self totalCellWidth] * 0.5;
    }
    if (afterMovePoint.x > (self.scrollView.contentSize.width - ([self totalCellWidth] * 0.5))) {
        isOver = YES;
        afterMovePoint.x = (self.scrollView.contentSize.width - ([self totalCellWidth] * 0.5));
    }
    
    if (isOver) {
        // 超出范围
        return;
    }
    
    // 判断移动后的位置是否需要调转
    NSInteger toIndex = cell.center.x / [self totalCellWidth];
    if (toIndex == self.currentSelectedIndex) {
        // 一模一样
        return;
    }
    
    BOOL canMove = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoItemMoveView:itemAtIndex:canMoveToIndex:)]) {
        canMove = [self.delegate videoItemMoveView:self itemAtIndex:self.currentSelectedIndex canMoveToIndex:toIndex];
    }
    if (!canMove) {
        // 不能移动
        return;
    }
    // 可以移动
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoItemMoveView:itemAtIndex:willMoveToIndex:)]) {
        [self.delegate videoItemMoveView:self itemAtIndex:self.currentSelectedIndex willMoveToIndex:toIndex];
    } else {
        // 没有实现代理
        return;
    }
    
    NSInteger fromIndex = self.currentSelectedIndex;
    self.currentSelectedIndex = toIndex;
    [self moveAnimationWithFromIndex:fromIndex toIndex:toIndex];
}

/**
 移动view
 */
- (void)moveAnimationWithFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex == toIndex) {
        return;
    }
    if (fromIndex < 0 || fromIndex >= self.viewArray.count || toIndex < 0 || toIndex >= self.viewArray.count) {
        NSAssert(NO, @"%s %d %@", __func__, __LINE__, @"");
        return;
    }
    
    // 中间view移动的方向
    BOOL isRight = toIndex > fromIndex ? NO : YES;
    @try {
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            
            NSInteger startIndex = isRight ? fromIndex - 1 : fromIndex + 1;
            for (NSInteger i = startIndex; (isRight ? (i >= toIndex) : (i <= toIndex)); (isRight ? (i--) : (i++))) {
                UIView *cell = self.viewArray[i];
                if (isRight) {
                    cell.center = GC_CGPointAdd(cell.center, CGPointMake([self totalCellWidth], 0));
                } else {
                    cell.center = GC_CGPointSubtract(cell.center, CGPointMake([self totalCellWidth], 0));
                }
            }
            
            // 移动view
            GCVideoItemMoveViewCell *currentCell = [self.viewArray objectAtIndex:fromIndex];
            [self.viewArray removeObject:currentCell];
            if (toIndex >= self.viewArray.count) {
                [self.viewArray addObject:currentCell];
            } else {
                [self.viewArray insertObject:currentCell atIndex:toIndex];
            }
            
        } completion:^(BOOL finished) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoItemMoveView:itemAtIndex:didMoveToIndex:)]) {
                [self.delegate videoItemMoveView:self itemAtIndex:fromIndex didMoveToIndex:toIndex];
            }
            
        }];
        
    } @catch(NSException *exception) {
        NSAssert(NO, @"%s %d %@", __func__, __LINE__, exception);
    }
}

#pragma mark - setter & getter

- (CGFloat)totalCellWidth {
    return self.itemMargin * 2 + self.itemSize.width;
}

- (UIPanGestureRecognizer *)currentPanGesture {
    if (!_currentPanGesture) {
        _currentPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)];
    }
    return _currentPanGesture;
}

- (NSMutableArray *)viewArray {
    if (!_viewArray) {
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}

@end
