//
//  JPSCollectionViewController.m
//  Collection View Animation Bug
//
//  Created by Jean-Pierre Simard on 6/14/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import "JPSCollectionViewController.h"

#define kCellReuseID        @"Cell"
#define kWidth              300
#define kCollapsedHeight    100
#define kExpandedHeight     300
#define kNumberOfCells      10
#define kContentOffsetKey   @"contentOffset"
#define kHackEnabled        TRUE

@implementation JPSCollectionViewController {
    NSMutableArray *_cells;
    BOOL _forceContentOffset;
    CGPoint _originalOffset;
}

#pragma mark - Lifecycle

- (id)init {
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        _cells = [NSMutableArray arrayWithCapacity:kNumberOfCells];
        
        for (int cell_idx = 0; cell_idx < kNumberOfCells; cell_idx++) {
            [_cells addObject:@(kCollapsedHeight)];
        }
        
        [self.collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:kCellReuseID];
        
        if (kHackEnabled) {
            [self.collectionView addObserver:self forKeyPath:kContentOffsetKey options:NSKeyValueObservingOptionNew context:NULL];
            _forceContentOffset = NO;
        }
    }
    return self;
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _cells.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellReuseID forIndexPath:indexPath];
    cell.contentView.backgroundColor = indexPath.item % 2 ? [UIColor blueColor] : [UIColor redColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kWidth, [_cells[indexPath.item] floatValue]);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger currentHeight = [_cells[indexPath.item] integerValue];
    
    BOOL expand = currentHeight == kCollapsedHeight;
    
    NSInteger newHeight = expand ? kExpandedHeight : kCollapsedHeight;
    
    __block CGRect frameUpdate = collectionView.frame;
    _originalOffset = collectionView.contentOffset;
    
    if (kHackEnabled) {
        frameUpdate.size.height += kExpandedHeight - kCollapsedHeight;
        collectionView.frame = frameUpdate;
        collectionView.contentOffset = _originalOffset;
        _forceContentOffset = YES;
    }
    
    [collectionView performBatchUpdates:^{
        _cells[indexPath.item] = @(newHeight);
    } completion:^(BOOL finished) {
        if (kHackEnabled) {
            frameUpdate.size.height -= kExpandedHeight - kCollapsedHeight;
            collectionView.frame = frameUpdate;
            _forceContentOffset = NO;
        }
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kContentOffsetKey] && _forceContentOffset && [(UIScrollView *)object contentOffset].y != _originalOffset.y) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UICollectionView *collectionView = (UICollectionView *)object;
            if (collectionView.contentSize.height < (collectionView.contentOffset.y + collectionView.bounds.size.height)) {
                _forceContentOffset = NO;
                [collectionView scrollRectToVisible:CGRectMake(_originalOffset.x, collectionView.contentSize.height - collectionView.bounds.size.height, 1, 1) animated:YES];
            } else {
                collectionView.contentOffset = _originalOffset;
            }
        });
    }
}

@end
