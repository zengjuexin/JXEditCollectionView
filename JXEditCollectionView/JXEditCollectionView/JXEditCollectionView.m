//
//  JXEditCollectionView.m
//  JXEditCollectionView
//
//  Created by 曾觉新 on 2018/9/8.
//  Copyright © 2018年 曾觉新. All rights reserved.
//

#import "JXEditCollectionView.h"

@interface JXEditCollectionView()

@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@property (nonatomic, weak) UICollectionViewCell *dragingCell;//准备用来移动的cell
@property (nonatomic, strong) UIImageView *tempCell;

@property (nonatomic, strong) NSIndexPath *dragingIndexPath;
@property (nonatomic, strong) NSIndexPath *targetIndexPath;

@end


@implementation JXEditCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.minimumPressDuration = 0.1;
    }
    return self;
}

- (UILongPressGestureRecognizer *)longGesture
{
    if (!_longGesture) {
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _longGesture.minimumPressDuration = self.minimumPressDuration;
    }
    return _longGesture;
}
- (UIImageView *)tempCell
{
    if (!_tempCell) {
        _tempCell = [[UIImageView alloc] initWithFrame:CGRectZero];
        _tempCell.hidden = YES;
    }
    return _tempCell;
}
- (void)setIsEdit:(BOOL)isEdit
{
    _isEdit = isEdit;
    if (_isEdit) {
        [self addGestureRecognizer:self.longGesture];
        [self addSubview:self.tempCell];
    } else {
        [self endEditAnimateWithCompletion:^{
            [self removeGestureRecognizer:self.longGesture];
            [self.tempCell removeFromSuperview];
        }];
    }
}
- (void)setMinimumPressDuration:(CFTimeInterval)minimumPressDuration
{
    _minimumPressDuration = minimumPressDuration;
    if (_longGesture) {
        _longGesture.minimumPressDuration = minimumPressDuration;
    }
}


#pragma mark- 手势处理
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self gestureBegan:gesture];
            break;
        case UIGestureRecognizerStateChanged:
            [self gestureChanged:gesture];
            break;
        case UIGestureRecognizerStateEnded:
            [self gestureEnded:gesture];
            break;
        case UIGestureRecognizerStateCancelled:
            [self gestureEnded:gesture];
            break;
            
        default:
            
            break;
    }
}

- (void)gestureBegan:(UILongPressGestureRecognizer *)gesture
{
    if (self.dragingCell && self.dragingCell.hidden) {
        self.dragingCell.hidden = NO;
    }
    
    CGPoint point = [gesture locationInView:self];
    //获得准备移动的cell
    self.dragingIndexPath = [self getDragingIndexPathWithPoint:point];
    self.dragingCell = [self cellForItemAtIndexPath:self.dragingIndexPath];
    
    //将准备移动的cell截图展示
    self.tempCell.frame = self.dragingCell.frame;
    self.tempCell.center = point;
    self.tempCell.image = [self createTempCellImageViewFrameCell:self.dragingCell];
    self.tempCell.hidden = NO;
    
    //隐藏原有的cell
    self.dragingCell.hidden = YES;//隐藏原有的cell
    
    [self bringSubviewToFront:self.tempCell];
}

- (void)gestureChanged:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    
    self.targetIndexPath = [self getTargetIndexPathWithPoint:point];
    
    self.tempCell.center = point;
    
    if (self.dragingIndexPath && self.targetIndexPath) {
        [self moveItemAtIndexPath:self.dragingIndexPath toIndexPath:self.targetIndexPath];
        if (self.didExchangeCell) {
            self.didExchangeCell(self.dragingIndexPath, self.targetIndexPath);
        }
        _dragingIndexPath = _targetIndexPath;
    }
}

- (void)gestureEnded:(UILongPressGestureRecognizer *)gesture
{
    [self endEditAnimateWithCompletion:nil];
}

- (void)endEditAnimateWithCompletion:(void(^)(void))completion
{
    [UIView animateWithDuration:0.3 animations:^{
        self.tempCell.frame = self.dragingCell.frame;
    } completion:^(BOOL finished) {
        self.dragingCell.hidden = NO;
        self.tempCell.hidden = YES;
        if (completion) {
            completion();
        }
    }];
}


//获取被拖动IndexPath的方法
-(NSIndexPath*)getDragingIndexPathWithPoint:(CGPoint)point
{
    NSIndexPath* dragingIndexPath = nil;
    //遍历所有屏幕上的cell
    for (NSIndexPath *indexPath in [self indexPathsForVisibleItems]) {
        //判断cell是否包含这个点
        if (CGRectContainsPoint([self cellForItemAtIndexPath:indexPath].frame, point)) {
            dragingIndexPath = indexPath;
            break;
        }
    }
    return dragingIndexPath;
}

//获得目标的indexPath
- (NSIndexPath *)getTargetIndexPathWithPoint:(CGPoint)point
{
    NSIndexPath *targetIndexPath = nil;
    for (NSIndexPath *indexPath in [self indexPathsForVisibleItems]) {
        if (indexPath == self.dragingIndexPath) {continue;}
        
        if (CGRectContainsPoint([self cellForItemAtIndexPath:indexPath].frame, point)) {
            targetIndexPath = indexPath;
            break;
        }
    }
    return targetIndexPath;
}


//截图获取cell样式
- (UIImage *)createTempCellImageViewFrameCell:(UICollectionViewCell *)cell
{
    UIGraphicsBeginImageContextWithOptions(cell.frame.size, NO, [UIScreen mainScreen].scale);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}


@end
