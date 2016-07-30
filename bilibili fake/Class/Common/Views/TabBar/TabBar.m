//
//  TabBar.m
//  bilibili fake
//
//  Created by 翟泉 on 2016/7/5.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "TabBar.h"

@interface TabBar ()
{
    NSMutableArray<UIButton *> *_items;
    UIView *_bottomLineView;
    
    NSInteger _index;
    
    NSArray<NSNumber *> *_tintColorRGB;
    
    UIScrollView *_scrollView;
}

@end

@implementation TabBar

@dynamic tintColorRGB;

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles style:(TabBarStyle)style {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        _style = style;
        
        if (_style == TabBarStyleScroll) {
            _scrollView = [[UIScrollView alloc] init];
//            _scrollView.bounces = NO;
            _scrollView.showsHorizontalScrollIndicator = NO;
            [self addSubview:_scrollView];
        }
        
        
        _items = [NSMutableArray arrayWithCapacity:titles.count];
        [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setTitle:obj forState:UIControlStateNormal];
            if (idx == _index) {
                [button setTitleColor:ColorRGB(self.cR,self.cG,self.cB) forState:UIControlStateNormal];
            }
            else {
                [button setTitleColor:ColorWhite(200) forState:UIControlStateNormal];
            }
            button.titleLabel.font = Font(14);
            button.tag = idx;
            [button addTarget:self action:@selector(onClickItem:) forControlEvents:UIControlEventTouchUpInside];
            if (_style == TabBarStyleScroll) {
                [_scrollView addSubview:button];
            }
            else {
                [self addSubview:button];
            }
            [_items addObject:button];
        }];
        
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = ColorRGB(self.cR,self.cG,self.cB);
        
        if (_style == TabBarStyleScroll) {
            [_scrollView addSubview:_bottomLineView];
        }
        else {
            [self addSubview:_bottomLineView];
        }
        
    }
    return self;
}

- (void)onClickItem:(UIButton *)button {
    _onClickItem ? _onClickItem(button.tag) : NULL;
}

- (NSInteger)currentIndex; {
    return _index;
}

- (void)setContentOffset:(CGFloat)contentOffset {
    
    if (contentOffset < 0 || contentOffset > _items.count-1) {
        return;
    }
    
    
    NSInteger index = (NSInteger)contentOffset;
    CGFloat progress = contentOffset - index;
    
    CGFloat lineX;
    CGFloat lineWidth;
    if (index == _items.count-1) {
        lineX = _items[index].x;
        lineWidth = _items[index].width;
    }
    else {
        lineX = _items[index].x + (_items[index + 1].x - _items[index].x) * progress;
        lineWidth = _items[index].width + (_items[index + 1].width - _items[index].width) * progress;
    }
    
    _bottomLineView.frame = CGRectMake(lineX, _bottomLineView.y, lineWidth, _bottomLineView.height);
    _scrollView.contentOffset = CGPointMake((_scrollView.contentSize.width - _scrollView.width) * (contentOffset / (_items.count-1)), 0);
    
    
//    printf("%lf %ld %lf  %ld\t", contentOffset, index, progress, _index);
    
    
    if (contentOffset > _index) {
        if (progress == 0) {
            [_items[index] setTitleColor:ColorRGB(self.cR, self.cG, self.cG) forState:UIControlStateNormal];
            [_items[index-1] setTitleColor:ColorWhite(200) forState:UIControlStateNormal];
        }
        else {
            [_items[index] setTitleColor:ColorRGB(self.cR - (self.cR-200)*progress, self.cG - (self.cG-200)*progress, self.cB - (self.cB-200)*progress) forState:UIControlStateNormal];
            [_items[index+1] setTitleColor:ColorRGB(200 + (self.cR-200)*progress, 200 + (self.cG-200)*progress, 200 + (self.cB-200)*progress) forState:UIControlStateNormal];
        }
        if (_index != index) {
            _index = index;
        }
    }
    else if (contentOffset < _index) {
        progress = 1 - progress;
        if (progress == 0) {
            [_items[index] setTitleColor:ColorRGB(self.cR, self.cG, self.cG) forState:UIControlStateNormal];
            [_items[index+1] setTitleColor:ColorWhite(200) forState:UIControlStateNormal];
        }
        else {
            [_items[index+1] setTitleColor:[self colorWithFromColorRGB:self.tintColorRGB toColorRGB:@[@200,@200,@200] progress:progress] forState:UIControlStateNormal];
            [_items[index] setTitleColor:[self colorWithFromColorRGB:@[@200,@200,@200] toColorRGB:self.tintColorRGB progress:progress] forState:UIControlStateNormal];
        }
        if (1 - progress == 0) {
            if (_index != index) {
                _index = index;
            }
        }
        else if (index+1 < _index) {
            _index = index+1;
        }
    }
    
//    printf("%lf %ld %lf  %ld\n", contentOffset, index, progress, _index);
    
}


- (void)setTitle:(NSString *)title forIndex:(NSInteger)index; {
    [_items[index] setTitle:title forState:UIControlStateNormal];
}



- (void)selectedItem:(UIButton *)itemButton; {
    [self.delegate tabBar:self didSelectIndex:itemButton.tag];
}

- (void)layoutSubviews; {
    
    
    
    if (_style == TabBarStyleNormal) {
        CGFloat itemWidth = (self.bounds.size.width - _edgeInsets.left - _edgeInsets.right - self.spacing * (_items.count-1)) / _items.count;
        [_items enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.frame = CGRectMake(_edgeInsets.left + itemWidth * idx + self.spacing * idx, _edgeInsets.top, itemWidth, self.bounds.size.height-_edgeInsets.top-_edgeInsets.bottom);
        }];
    }
    else {
        CGRect rect = CGRectMake(_edgeInsets.left, _edgeInsets.top, self.width-_edgeInsets.left-_edgeInsets.right, self.height-_edgeInsets.top-_edgeInsets.bottom);
        if (CGRectEqualToRect(rect, _scrollView.frame)) {
            return;
        }
        
        _scrollView.frame = rect;
        
        __block CGFloat x = 0;
        [_items enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat width = [obj.titleLabel textRectForBounds:CGRectMake(0, 0, 9999, 16) limitedToNumberOfLines:1].size.width;
            obj.frame = CGRectMake(x, 0, width, _scrollView.height);
            x = obj.maxX + self.spacing;
        }];
        _scrollView.contentSize = CGSizeMake(x - self.spacing, 0);
    }
    _bottomLineView.frame = CGRectMake(_items[_index].x, self.height-2 - _edgeInsets.bottom, _items[_index].width, 2);
    
    [super layoutSubviews];
}


- (void)setTintColorRGB:(NSArray<NSNumber *> *)tintColorRGB {
    _tintColorRGB = [tintColorRGB mutableCopy];
    [_items enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == _index) {
            [obj setTitleColor:ColorRGB(self.cR,self.cG,self.cB) forState:UIControlStateNormal];
        }
        else {
            [obj setTitleColor:ColorWhite(200) forState:UIControlStateNormal];
        }
    }];
    _bottomLineView.backgroundColor = ColorRGB(self.cR,self.cG,self.cB);
}

- (NSArray<NSNumber *> *)tintColorRGB {
    if (!_tintColorRGB) {
        _tintColorRGB = @[@253,@129,@164];
    }
    return _tintColorRGB;
}

- (NSInteger)cR {
    return [self.tintColorRGB[0] integerValue];
}
- (NSInteger)cG {
    return [self.tintColorRGB[1] integerValue];
}
- (NSInteger)cB {
    return [self.tintColorRGB[2] integerValue];
}


- (UIColor *)colorWithFromColorRGB:(NSArray<NSNumber *> *)fromColorRGB toColorRGB:(NSArray<NSNumber *> *)toColorRGB progress:(CGFloat)progress {
    NSInteger fR = [fromColorRGB[0] integerValue];
    NSInteger fG = [fromColorRGB[1] integerValue];
    NSInteger fB = [fromColorRGB[2] integerValue];
    NSInteger tR = [toColorRGB[0] integerValue];
    NSInteger tG = [toColorRGB[1] integerValue];
    NSInteger tB = [toColorRGB[2] integerValue];
    
    return ColorRGB(fR + (tR - fR) * progress, fG + (tG - fG) * progress, fB + (tB - fB) * progress);
}

@end
