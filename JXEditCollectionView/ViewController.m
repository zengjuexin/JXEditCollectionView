//
//  ViewController.m
//  JXEditCollectionView
//
//  Created by 曾觉新 on 2018/9/8.
//  Copyright © 2018年 曾觉新. All rights reserved.
//

#import "ViewController.h"
#import "JXEditCollectionView.h"

#define collectionCellKey @"collectionCellKey"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet JXEditCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionLayout;


@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation ViewController



- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (int i = 0; i < 10; i++) {
        [self.dataArr addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    [self.collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:collectionCellKey];
    
    self.collectionView.didExchangeCell = ^(NSIndexPath *dragingIndexPath, NSIndexPath *targetIndexPath) {
        
        NSString *dragingData = self.dataArr[dragingIndexPath.row];
        //将原来位置的数据删掉，插入到新的位置
        [self.dataArr removeObject:dragingData];
        [self.dataArr insertObject:dragingData atIndex:targetIndexPath.row];
        
        NSLog(@"%@", self.dataArr);
        
    };
    
}
- (IBAction)clickEdit:(UIBarButtonItem *)sender {
    
    self.collectionView.isEdit = !self.collectionView.isEdit;
}

#pragma mark- UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellKey forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    
    UILabel *label = [cell.contentView viewWithTag:100];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        label.tag = 100;
        [cell.contentView addSubview:label];
    }
    label.text = self.dataArr[indexPath.row];
    
    return cell;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
