//
//	UXReaderPageToolbar.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderPageToolbar.h"
#import "UXReaderPageControl.h"
#import "UXReaderPageControlView.h"
#import "UXReaderPageNumbers.h"
#import "UXReaderFramework.h"


typedef NS_ENUM(NSUInteger, UXReaderPageToolbarHeight) {
    UXReaderPageToolbarHeightDefault = 156,
    UXReaderPageToolbarHeightSetting = 193,
    UXReaderPageToolbarHeightTabbar = 54,
    UXReaderPageToolbarHeightPageControl = 52,
    UXReaderPageToolbarHeightBrightness = 40
};

@interface CenteredButton : UIButton
@end
@implementation CenteredButton
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.titleLabel setFont: [UIFont systemFontOfSize:12]];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(self.imageView.frame.size.height + 8 ,-self.imageView.frame.size.width, 0.0, 0.0)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(-15, 0.0, 0.0, -self.titleLabel.bounds.size.width)];
}
@end

@interface UXReaderPageToolbar () <UXReaderPageControlViewDelegate>

@end

@implementation UXReaderPageToolbar
{
	UIView *contentView;

	UXReaderDocument *document;

	__weak NSLayoutConstraint *layoutConstraintY;

	UXReaderPageControl *pageControl;

    UXReaderPageControlView *pageControlView;

	UXReaderPageNumbers *pageNumbers;

	NSUInteger pageCount;
    
    NSBundle *bundle;

    UIView *tabbar;
    UIButton *stuffButton;
    UIButton *listenButton;
    UIButton *settingButton;
    UIButton *brightnessButton;
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIView instance methods

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	if ((self = [self initWithFrame:CGRectZero])) // Initialize self
	{
		if (documentx != nil) [self populateView:documentx]; else self = nil;
	}

	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		self.translatesAutoresizingMaskIntoConstraints = NO; self.contentMode = UIViewContentModeRedraw;

		self.backgroundColor = [UIColor clearColor]; const CGFloat th = UXReaderPageToolbarHeightDefault + [UXReaderFramework safeAreaBottomHeight];

		[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
															toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];
        bundle = [NSBundle bundleForClass:[self class]];
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);

	[pageNumbers removeFromSuperview];
}

- (void)layoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));

	[super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);
}

- (void)didMoveToSuperview
{
	//NSLog(@"%s %@", __FUNCTION__, [self superview]);

	[super didMoveToSuperview];

	if ((self.superview != nil) && (pageNumbers == nil))
	{
		[self addPageNumbers:[self superview]];
	}
}

#pragma mark - UXReaderPageToolbar instance methods

- (void)populateView:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %@", __FUNCTION__, documentx);

	document = documentx; pageCount = [document pageCount];

    
    [self addTabbar:self];
    [self addPageControlView:self];
    [self addBrightnessButton:self];
}
- (void)addTabbar:(nonnull UIView *)view
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [baseView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [baseView setBackgroundColor:[UIColor whiteColor]];
    [view addSubview:baseView];
    CGFloat bh = UXReaderPageToolbarHeightTabbar + [UXReaderFramework safeAreaBottomHeight];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:baseView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                        toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:baseView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                        toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:baseView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                        toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [baseView addConstraint:[NSLayoutConstraint constraintWithItem:baseView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                          toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:bh]];

// --------------------------------------------------------------------------------------------------------------------------------
    tabbar = [[UIView alloc] initWithFrame:CGRectZero];
    [tabbar setBackgroundColor:[UIColor whiteColor]];
    [tabbar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [baseView addSubview:tabbar];
    CGFloat th = UXReaderPageToolbarHeightTabbar;
    [baseView addConstraint:[NSLayoutConstraint constraintWithItem:tabbar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                            toItem:baseView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [baseView addConstraint:[NSLayoutConstraint constraintWithItem:tabbar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                        toItem:baseView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [baseView addConstraint:[NSLayoutConstraint constraintWithItem:tabbar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                        toItem:baseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-[UXReaderFramework safeAreaBottomHeight]]];
    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:tabbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                          toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:th]];

// --------------------------------------------------------------------------------------------------------------------------------

    static NSString *const stuffName = @"UXReader-Toolbar-Outline";
    UIImage *stuffImage = [UIImage imageNamed:stuffName inBundle:bundle compatibleWithTraitCollection:nil];
    stuffImage = [stuffImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    stuffButton = [[CenteredButton alloc] initWithFrame:CGRectZero];
    [stuffButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [stuffButton setExclusiveTouch:YES];
    [stuffButton addTarget:self action:@selector(stuffButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [stuffButton setImage:stuffImage forState:UIControlStateNormal]; [stuffButton setShowsTouchWhenHighlighted:YES];
    [stuffButton setTitle:@"目录" forState:UIControlStateNormal];
    [stuffButton setTitleColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [stuffButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [tabbar addSubview:stuffButton];

    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:stuffButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                        toItem:tabbar attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:stuffButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                        toItem:tabbar attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:stuffButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                          toItem:tabbar attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:stuffButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                          toItem:tabbar attribute:NSLayoutAttributeWidth multiplier:1.0/3 constant:0.0]];
// --------------------------------------------------------------------------------------------------------------------------------
    static NSString *const listenName = @"UXReader-Toolbar-Listen";
    UIImage *listenImage = [UIImage imageNamed:listenName inBundle:bundle compatibleWithTraitCollection:nil];
    listenImage = [listenImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    listenButton = [[CenteredButton alloc] initWithFrame:CGRectZero];
    [listenButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [listenButton setExclusiveTouch:YES];
    [listenButton addTarget:self action:@selector(stuffButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [listenButton setImage:listenImage forState:UIControlStateNormal]; [listenButton setShowsTouchWhenHighlighted:YES];
    [listenButton setTitle:@"听书" forState:UIControlStateNormal];
    [listenButton setTitleColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [listenButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [tabbar addSubview:listenButton];

    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:listenButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                          toItem:stuffButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:listenButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                          toItem:tabbar attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:listenButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                          toItem:tabbar attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:listenButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                          toItem:tabbar attribute:NSLayoutAttributeWidth multiplier:1.0/3 constant:0.0]];
// --------------------------------------------------------------------------------------------------------------------------------
    static NSString *const settingName = @"UXReader-Toolbar-Setting";
    UIImage *settingImage = [UIImage imageNamed:settingName inBundle:bundle compatibleWithTraitCollection:nil];
    settingImage = [settingImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settingButton = [[CenteredButton alloc] initWithFrame:CGRectZero];
    [settingButton setTranslatesAutoresizingMaskIntoConstraints:NO]; [settingButton setExclusiveTouch:YES];
    [settingButton addTarget:self action:@selector(stuffButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [settingButton setImage:settingImage forState:UIControlStateNormal]; [settingButton setShowsTouchWhenHighlighted:YES];
    [settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [settingButton setTitleColor:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [settingButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [tabbar addSubview:settingButton];

    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:settingButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                          toItem:listenButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:settingButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                          toItem:tabbar attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:settingButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                          toItem:tabbar attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [tabbar addConstraint:[NSLayoutConstraint constraintWithItem:settingButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                          toItem:tabbar attribute:NSLayoutAttributeWidth multiplier:1.0/3 constant:0.0]];
// --------------------------------------------------------------------------------------------------------------------------------
    UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
    [line setTranslatesAutoresizingMaskIntoConstraints:NO];
    [line setBackgroundColor: [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0]];
    [baseView addSubview:line];
    [baseView addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                            toItem:baseView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [baseView addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                            toItem:baseView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [baseView addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                            toItem:baseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [line addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                        toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:1.0]];

}

- (void)addPageControlView:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

	if (pageControlView == nil) // Create UXReaderPageControl
	{
		if ((pageControlView = [[UXReaderPageControlView alloc] initWithDocument:document]))
		{
			[view addSubview:pageControlView];
            [pageControlView setDelegate:self];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:pageControlView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
																toItem:tabbar attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];

			[view addConstraint:[NSLayoutConstraint constraintWithItem:pageControlView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
																toItem:view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
            [view addConstraint:[NSLayoutConstraint constraintWithItem:pageControlView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                                toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];

			[pageControlView addConstraint:[NSLayoutConstraint constraintWithItem:pageControlView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
																toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:UXReaderPageToolbarHeightPageControl]];
		}
	}
}

- (void)addBrightnessButton:(nonnull UIView *)view {
    brightnessButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [brightnessButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIImage *brightnessNImage = [UIImage imageNamed:@"UXReader-Toolbar-Brightness-N"];
    UIImage *brightnessDImage = [UIImage imageNamed:@"UXReader-Toolbar-Brightness-D"];
    brightnessNImage = [brightnessNImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    brightnessDImage = [brightnessDImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [brightnessButton setImage:brightnessNImage forState:UIControlStateNormal];
    [brightnessButton setImage:brightnessDImage forState:UIControlStateSelected];
    [brightnessButton addTarget:self action:@selector(brightnessButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:brightnessButton];

    [view addConstraint:[NSLayoutConstraint constraintWithItem:brightnessButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                        toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-15.0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:brightnessButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                        toItem:pageControlView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0]];
    [brightnessButton addConstraint:[NSLayoutConstraint constraintWithItem:brightnessButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:UXReaderPageToolbarHeightBrightness]];
    [brightnessButton addConstraint:[NSLayoutConstraint constraintWithItem:brightnessButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:UXReaderPageToolbarHeightBrightness]];
}

- (void)addPageNumbers:(nonnull UIView *)view
{
	//NSLog(@"%s %@", __FUNCTION__, view);

//    if (pageNumbers == nil) // Create UXReaderPageNumbers
//    {
//        if ((pageNumbers = [[UXReaderPageNumbers alloc] initWithFrame:CGRectZero]))
//        {
//            [view addSubview:pageNumbers]; const CGFloat yo = ([UXReaderFramework isSmallDevice] ? 64.0 : 80.0);
//
//            [view addConstraint:[NSLayoutConstraint constraintWithItem:pageNumbers attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
//                                                                toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
//
//            [view addConstraint:[NSLayoutConstraint constraintWithItem:pageNumbers attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
//                                                                toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-yo]];
//        }
//    }
}

- (void)showPageNumber:(NSUInteger)page ofPages:(NSUInteger)pages
{
    [self showPage:page ofPages:pages];
}

- (void)showPage:(NSUInteger)page ofPages:(NSUInteger)pages
{
    [pageControlView setCurrentPage:page];
}

- (void)setLayoutConstraintY:(nonnull NSLayoutConstraint *)constraint
{
	//NSLog(@"%s %@", __FUNCTION__, constraint);

	layoutConstraintY = constraint;
}

- (void)hideAnimated
{
	//NSLog(@"%s", __FUNCTION__);

	if (layoutConstraintY.constant <= 0.0) // Visible
	{
		const NSTimeInterval ti = [UXReaderFramework animationDuration];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void)
		{
			layoutConstraintY.constant = +self.bounds.size.height; [[self superview] layoutIfNeeded]; pageNumbers.alpha = 0.0;
		}
		completion:^(BOOL finished)
		{
			pageNumbers.hidden = YES; self.hidden = YES;
		}];
	}
}

- (void)showAnimated
{
	//NSLog(@"%s", __FUNCTION__);

	if (layoutConstraintY.constant > 0.0) // Hidden
	{
		pageNumbers.hidden = NO; self.hidden = NO; // Unhide the view

		const NSTimeInterval ti = [UXReaderFramework animationDuration];

		[UIView animateWithDuration:ti delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void)
		{
			layoutConstraintY.constant -= self.bounds.size.height; [[self superview] layoutIfNeeded]; pageNumbers.alpha = 1.0;
		}
		completion:^(BOOL finished)
		{
		}];
	}
}

- (BOOL)isVisible
{
	//NSLog(@"%s", __FUNCTION__);

	return (layoutConstraintY.constant <= 0.0);
}

- (void)setEnabled:(BOOL)enabled
{
	//NSLog(@"%s %i", __FUNCTION__, enabled);

	[pageControl setEnabled:enabled];
}

#pragma mark - UXReaderPageControlViewDelegate
- (void)pageControlView:(UXReaderPageControlView *)control gotoPage:(NSUInteger)page {
    if ([delegate respondsToSelector:@selector(pageToolbar:gotoPage:)])
    {
        [delegate pageToolbar:self gotoPage:page];
    }
}

#pragma mark - UIButton action methods

- (void)stuffButtonTapped:(UIButton *)button
{

    if ([delegate respondsToSelector:@selector(pageToolbar:stuffButton:)])
    {
        [delegate pageToolbar:self stuffButton:button];
    }
}
- (void)listenButtonTapped:(UIButton *)button
{

    if ([delegate respondsToSelector:@selector(pageToolbar:listenButton:)])
    {
        [delegate pageToolbar:self listenButton:button];
    }
}
- (void)settingButtonTapped:(UIButton *)button
{

    if ([delegate respondsToSelector:@selector(pageToolbar:settingButton:)])
    {
        [delegate pageToolbar:self settingButton:button];
    }
}
- (void)brightnessButtonTapped:(UIButton *)button
{
    [button setSelected:!button.selected];
    if ([delegate respondsToSelector:@selector(pageToolbar:brightnessButton:)])
    {
        [delegate pageToolbar:self brightnessButton:button];
    }
}


@end
