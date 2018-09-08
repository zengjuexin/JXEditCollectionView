//
//  JXEditCollectionView.h
//  JXEditCollectionView
//
//  Created by 曾觉新 on 2018/9/8.
//  Copyright © 2018年 曾觉新. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXEditCollectionView : UICollectionView

/**
 * 设置长按时间
 */
@property (nonatomic) CFTimeInterval minimumPressDuration;

/**
 * 设置编辑状态
 */
@property (nonatomic, assign) BOOL isEdit;
/**
 * 当cell位置发生变化时执行
 */
@property (nonatomic, copy) void(^didExchangeCell)(NSIndexPath *dragingIndexPath, NSIndexPath *targetIndexPath);

@end
