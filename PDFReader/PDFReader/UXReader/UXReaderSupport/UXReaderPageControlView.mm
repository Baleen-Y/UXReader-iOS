//
//  UXReaderPageControlView.m
//  PDFReader
//
//  Created by xhgc01 on 2019/1/3.
//  Copyright © 2019 baleen. All rights reserved.
//

#import "UXReaderPageControlView.h"
#import "UXReaderDocument.h"

@implementation UXReaderPageControlView
{
    UXReaderDocument *document; NSUInteger pageCount;

    NSUInteger currentPage; NSValue *lastPointValue; BOOL showRTL;

    CGFloat wantedControlWidth;

    UILabel *titleLabel;
    UIButton *lastButton;
    UIButton *nextButton;
    UISlider *pageSlider;
}
#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIControl instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
    //NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

    if ((self = [super initWithFrame:frame])) // Initialize superclass
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [UIColor whiteColor];
        currentPage = NSUIntegerMax;
    }

    return self;
}

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)documentx
{
    //NSLog(@"%s %@", __FUNCTION__, documentx);

    if ((self = [self initWithFrame:CGRectZero])) // Initialize self
    {
        if (documentx != nil) [self prepare:documentx]; else self = nil;
    }

    return self;
}

- (void)dealloc
{
    //NSLog(@"%s", __FUNCTION__);
}

- (void)layoutSubviews
{
    //NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));
    [super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);
}
#pragma mark - UXReaderPageControl instance methods

- (void)prepare:(nonnull UXReaderDocument *)documentx
{
    //NSLog(@"%s %@", __FUNCTION__, documentx);
    document = documentx; pageCount = [document pageCount];
    [self addTitleLabel];
    [self addPageControl];
}
- (void)addTitleLabel {
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:@"测试"];
    [titleLabel setTextColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f]];
    [self addSubview:titleLabel];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:25.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-25.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
    [titleLabel addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                          toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:13.0]];
}
- (void)addPageControl {
    pageSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    [pageSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    pageSlider.minimumValue = 0;
    pageSlider.maximumValue = pageCount-1;
    pageSlider.minimumTrackTintColor = [UIColor colorWithRed:207.0f/255.0f green:46.0f/255.0f blue:84.0f/255.0f alpha:1.0f];
    pageSlider.maximumTrackTintColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    [pageSlider setThumbImage:[UIImage imageNamed:@"UXReader-Toolbar-Thumb"] forState:UIControlStateNormal];
    [pageSlider setThumbImage:[UIImage imageNamed:@"UXReader-Toolbar-Thumb"] forState:UIControlStateHighlighted];
    [pageSlider addTarget:self action:@selector(pageSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [pageSlider addTarget:self action:@selector(pageSliderDrapUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pageSlider];
    CGFloat pw = [[UIScreen mainScreen] bounds].size.width - 140;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:pageSlider attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:pageSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:15.0]];
    [pageSlider addConstraint:[NSLayoutConstraint constraintWithItem:pageSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                              toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:pw]];
// --------------------------------------------------------------------------------------------------------------------------------
    lastButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [lastButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [lastButton setExclusiveTouch:YES];
    [lastButton setTitle:@"上一页" forState:UIControlStateNormal];
    [lastButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [lastButton setTitleColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [lastButton setTitleColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f] forState:UIControlStateDisabled];
    [lastButton addTarget:self action:@selector(lastButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lastButton];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lastButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                        toItem:pageSlider attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lastButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                        toItem:pageSlider attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-5.0]];
// --------------------------------------------------------------------------------------------------------------------------------
    nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [nextButton setExclusiveTouch:YES];
    [nextButton setTitle:@"下一页" forState:UIControlStateNormal];
    [nextButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [nextButton setTitleColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f] forState:UIControlStateDisabled];
    [nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:nextButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                        toItem:pageSlider attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:nextButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                        toItem:pageSlider attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:5.0]];
}
- (void)pageSliderChanged: (UISlider *)slider {
    currentPage = int(slider.value);
    [self updateView];
}
- (void)pageSliderDrapUp: (UISlider *)slider {
    currentPage = int(slider.value);
    [self updateView];
    if ([delegate respondsToSelector:@selector(pageControlView:gotoPage:)])
    {
        [delegate pageControlView:self gotoPage:currentPage];
    }
}
- (void)lastButtonTapped: (UIButton *)button {
    currentPage -= 1;
    [self updateView];
    if ([delegate respondsToSelector:@selector(pageControlView:gotoPage:)])
    {
        [delegate pageControlView:self gotoPage:currentPage];
    }
}
- (void)nextButtonTapped: (UIButton *)button {
    currentPage += 1;
    if (currentPage > pageCount-1) {
        currentPage = pageCount-1;
    }
    [self updateView];
    if ([delegate respondsToSelector:@selector(pageControlView:gotoPage:)])
    {
        [delegate pageControlView:self gotoPage:currentPage];
    }
}
- (void)setCurrentPage:(NSUInteger)page {
    currentPage = page;
    [self updateView];
}

- (void)updateView {
    pageSlider.value = currentPage;
    [lastButton setEnabled:YES];
    [nextButton setEnabled:YES];
    if (currentPage == 0) {
        [lastButton setEnabled:NO];
    }
    if (currentPage == pageCount-1) {
        [nextButton setEnabled:NO];
    }
}
@end
