//
//	UXReaderPageTiledView.mm
//	UXReader Framework v0.1
//
//	Copyright © 2017 Julius Oklamcak. All rights reserved.
//

#import "UXReaderDocument.h"
#import "UXReaderPageTiledView.h"
#import "UXReaderDocumentPage.h"
#import "UXReaderTiledLayer.h"
#import "UXReaderFramework.h"
#import "PDFPageSelectionKnob.h"
#import "UXReaderSelection.h"

@implementation UXReaderPageTiledView
{
	UXReaderDocument *document;

	UXReaderDocumentPage *documentPage;

    PDFPageSelectionKnob *selectionStartKnob;

    PDFPageSelectionKnob *selectionEndKnob;

    UXReaderSelection *highlightSelection;
}
#pragma mark - Properties

@synthesize delegate;

#pragma mark - UIView class methods

+ (Class)layerClass
{
	//NSLog(@"%s", __FUNCTION__);

	return [UXReaderTiledLayer class];
}

#pragma mark - UIView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(frame));

	if ((self = [super initWithFrame:frame])) // Initialize superclass
	{
		//self.translatesAutoresizingMaskIntoConstraints = YES;
		self.contentMode = UIViewContentModeRedraw; self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = NO; self.userInteractionEnabled = NO;
	}

	return self;
}

- (nullable instancetype)initWithFrame:(CGRect)frame document:(nonnull UXReaderDocument *)documentx page:(NSUInteger)page
{
	//NSLog(@"%s %@ %@ %i", __FUNCTION__, NSStringFromCGRect(frame), documentx, int(page));

	if ((self = [self initWithFrame:frame])) // Initialize self
	{
		if ((documentx != nil) && (page < [documentx pageCount]))
		{
			document = documentx; [self openPage:page document:documentx];

		}
		else // On failure
		{
			self = nil;
		}
	}

	return self;
}

- (void)dealloc
{
	//NSLog(@"%s", __FUNCTION__);

	self.layer.delegate = nil;
    [documentPage removeObserver:self forKeyPath:@"pressSelection.rectangles"];
}

- (void)layoutSubviews
{
	//NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.bounds));

	[super layoutSubviews]; if (self.hasAmbiguousLayout) NSLog(@"%s hasAmbiguousLayout", __FUNCTION__);
}

/*
- (void)removeFromSuperview
{
	//NSLog(@"%s", __FUNCTION__);

	//self.layer.delegate = nil;

	[super removeFromSuperview];
}
*/

#pragma mark - UXReaderPageTiledView instance methods

- (void)openPage:(NSUInteger)page document:(nonnull UXReaderDocument *)documentx
{
	//NSLog(@"%s %i %@", __FUNCTION__, int(page), documentx);

	[UXReaderFramework dispatch_async_on_work_queue:
	^{
        self->documentPage = [documentx documentPage:page];

        if (self->documentPage != nil) // Redraw view
		{
			dispatch_async(dispatch_get_main_queue(),
			^{
				[self setNeedsDisplay];
                [self->documentPage addObserver:self
                               forKeyPath:@"pressSelection.rectangles"
                                  options:0
                                  context:NULL];
			});
		}
	}];
}

- (nullable UXReaderAction *)processSingleTap:(nonnull UITapGestureRecognizer *)recognizer
{
	//NSLog(@"%s %@", __FUNCTION__, recognizer);
//    NSLog(@"%@ %@", [documentPage text], [documentPage textAtIndex:0 count:11]);
//    NSLog(@"--%@--", [documentPage textAtIndex:11 count:1]);
	UXReaderAction *action = nil;
	const CGPoint point = [recognizer locationInView:self];
    NSUInteger pressIndex = [documentPage unicharIndexAtPoint:point tolerance:CGSizeMake(10, 10)];
    UXReaderSelection *selection = [documentPage isPressHighlightSelectionForIndex:pressIndex];
    if (selection) {
        self->highlightSelection = selection;
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self showHighlightMenuFromRect: [self highlightSelectionFrame] inView:self];
        }
        return nil;
    }
	if ([self pointInside:point withEvent:nil] == YES) // Ours
	{
		if (action == nil) action = [documentPage linkAction:point];

		if (action == nil) action = [documentPage textAction:point];
	}

	return action;
}

#pragma mark - CATiledLayer delegate methods

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
	//NSLog(@"%s %@ %p", __FUNCTION__, layer, context);
	if (UXReaderPageTiledView *hold = self) // Retain
	{
		[documentPage renderTileInContext:context]; // Render tile

		if (id <UXReaderRenderTileInContext> renderTile = [document renderTile])
		{
			if ([renderTile respondsToSelector:@selector(documentPage:renderTileInContext:)])
			{
				[renderTile documentPage:documentPage renderTileInContext:context];
			}
		}

		if (hold != nil) hold = nil; // Release
	}
}

- (CGRect)selectionFrame {
    UXReaderSelection *pressSelection = self->documentPage.pressSelection;
    if (!pressSelection) {
        return CGRectZero;
    } else {
        CGRect rect = [[pressSelection.rectangles firstObject] CGRectValue];
        for (int i = 1; i < pressSelection.rectangles.count; i++) {
            CGRect r = [pressSelection.rectangles[i] CGRectValue];
            rect = CGRectUnion(rect, r);
        }
        return rect;
    }
}
- (CGRect)highlightSelectionFrame {
    if (!self->highlightSelection) {
        return CGRectZero;
    } else {
        CGRect rect = [[highlightSelection.rectangles firstObject] CGRectValue];
        for (int i = 1; i < highlightSelection.rectangles.count; i++) {
            CGRect r = [highlightSelection.rectangles[i] CGRectValue];
            rect = CGRectUnion(rect, r);
        }
        return rect;
    }
}

- (void)processZoomInScale: (CGFloat)scale {
    [self updateSelectionKnobs];
}
#pragma mark - longPress
- (void)processUnLongPress {
    if ([documentPage pressSelection]) {
        [documentPage unSelectWord];
        [self setNeedsDisplay];
    }
    [self hideMenuControllerIfNeeded];
}
- (void)processLongPress:(nonnull UILongPressGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView: self];
    if (!CGRectContainsPoint(self.bounds, point)) {
        return ;
    }
    NSUInteger pressIndex = [documentPage unicharIndexAtPoint:point tolerance:CGSizeMake(10, 10)];
    UXReaderSelection *selection = [documentPage isPressHighlightSelectionForIndex:pressIndex];
    if (selection) {
        self->highlightSelection = selection;
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self showHighlightMenuFromRect: [self highlightSelectionFrame] inView:self];
        }
        return;
    }
    unichar c = [documentPage unicharAtIndex:pressIndex];
    if (c) {
        [documentPage selectWordForIndex:pressIndex];
    } else {
        [documentPage unSelectWord];
    }
    if (c && recognizer.state == UIGestureRecognizerStateEnded) {
        [self showSelectionMenuFromRect: [self selectionFrame]
                                 inView:self];
    }
    [self setNeedsDisplay];
}


#pragma mark - updateSelectionKnobs
- (void)updateSelectionKnobs
{
    if (!self->selectionStartKnob) {
        self->selectionStartKnob = [[PDFPageSelectionKnob alloc] initWithFrame:CGRectZero];
        self->selectionStartKnob.start = YES;
        [self->selectionStartKnob addTarget:self
                                    action:@selector(knobChanged:)
                          forControlEvents:UIControlEventValueChanged];
        [self->selectionStartKnob addTarget:self
                                    action:@selector(knobEnded:)
                          forControlEvents:UIControlEventTouchCancel |
         UIControlEventTouchUpInside |
         UIControlEventTouchUpOutside];
        [self->selectionStartKnob addTarget:self
                                    action:@selector(knobBegan:)
                          forControlEvents:UIControlEventTouchDown];
    }
    if (!self->selectionEndKnob) {
        self->selectionEndKnob = [[PDFPageSelectionKnob alloc] initWithFrame:CGRectZero];
        self->selectionEndKnob.start = NO;
        [self->selectionEndKnob addTarget:self
                                  action:@selector(knobChanged:)
                        forControlEvents:UIControlEventValueChanged];
        [self->selectionEndKnob addTarget:self
                                  action:@selector(knobEnded:)
                        forControlEvents:UIControlEventTouchCancel |
         UIControlEventTouchUpInside |
         UIControlEventTouchUpOutside];
        [self->selectionEndKnob addTarget:self
                                  action:@selector(knobBegan:)
                        forControlEvents:UIControlEventTouchDown];
    }

    UXReaderSelection *pressSelection = [self->documentPage pressSelection];
    if (pressSelection) {
        CGRect firstRect = [[[pressSelection rectangles] firstObject] CGRectValue];
        CGRect lastRect = [[[pressSelection rectangles] lastObject] CGRectValue];
        const CGFloat w = 9;
        self->selectionStartKnob.frame = ({
            CGRect f = [self convertRect:firstRect toView:self.superview.superview];
            f.origin.x = floorf(f.origin.x - (w / 2.0));
            f.origin.y = floorf(f.origin.y - w);
            f.size.width = w;
            f.size.height = ceilf(f.size.height + w);
            f;
        });
        self->selectionEndKnob.frame = ({
            CGRect f = [self convertRect:lastRect toView:self.superview.superview];
            f.origin.x = ceilf(CGRectGetMaxX(f) - (w / 2.0) - 0.5);
            f.size.width = w;
            f.size.height = ceilf(f.size.height + w);
            f;
        });
        [self.superview.superview addSubview:self->selectionStartKnob];
        [self.superview.superview addSubview:self->selectionEndKnob];
    } else {
        [self->selectionStartKnob removeFromSuperview];
        [self->selectionEndKnob removeFromSuperview];
    }
}


#pragma mark - Knob Changed

- (void)knobChanged:(PDFPageSelectionKnob *)knob {
    int start = -1, end = -1;
    if (knob == self->selectionStartKnob) {
        CGPoint point = [self convertPoint:self->selectionStartKnob.point fromView:self->selectionStartKnob.superview];
        start = (int)[documentPage unicharIndexAtPoint:point tolerance:CGSizeMake(50, 50)];
    }
    if (knob == self->selectionEndKnob) {
        CGPoint point = [self convertPoint:self->selectionEndKnob.point fromView:self->selectionEndKnob.superview];
        end = (int)[documentPage unicharIndexAtPoint:point tolerance:CGSizeMake(50, 50)];
    }
    
    [documentPage selectCharactersFrom:start to:end];
}

- (void)knobEnded:(PDFPageSelectionKnob *)knob {
    [self showSelectionMenuFromRect:self.selectionFrame inView:self];
}

- (void)knobBegan:(PDFPageSelectionKnob *)knob {

}

#pragma mark - menuControl
- (void)showSelectionMenuFromRect:(CGRect)rect
                           inView:(UIView *)view {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    NSMutableArray* menuItems = [NSMutableArray array];
    [menuItems addObject:
     [[UIMenuItem alloc] initWithTitle:[bundle localizedStringForKey:@"Copy" value:nil table:nil]
                                action:@selector(copySelectedString:)]];
    [menuItems addObject:
     [[UIMenuItem alloc] initWithTitle:[bundle localizedStringForKey:@"Highlight" value:nil table:nil]
                                action:@selector(highlightSelectedString:)]];
    [menuItems addObject:
     [[UIMenuItem alloc] initWithTitle:[bundle localizedStringForKey:@"Note" value:nil table:nil]
                                action:@selector(noteSelectedString:)]];
    menuController.menuItems = menuItems;
    menuController.arrowDirection = UIMenuControllerArrowDefault;
    [menuController setTargetRect:rect
                           inView:view];
    [self becomeFirstResponder];
    [menuController setMenuVisible:YES animated:YES];
}

- (void)showHighlightMenuFromRect:(CGRect)rect
                           inView:(UIView *)view {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    NSMutableArray* menuItems = [NSMutableArray array];

    [menuItems addObject: [[UIMenuItem alloc] initWithTitle:[bundle localizedStringForKey:@"Copy" value:nil table:nil]
                                                     action:@selector(copyHighlightString:)]];
    [menuItems addObject:
     [[UIMenuItem alloc] initWithTitle:[bundle localizedStringForKey:@"Delete" value:nil table:nil]
                                action:@selector(deleteHighlightString:)]];
    menuController.menuItems = menuItems;
    menuController.arrowDirection = UIMenuControllerArrowDefault;
    [menuController setTargetRect:rect
                           inView:view];
    [self becomeFirstResponder];
    [menuController setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(highlightSelectedString:)) {
        return YES;
    } else if (action == @selector(copySelectedString:)) {
        return YES;
    } else if (action == @selector(noteSelectedString:)) {
        return YES;
    } else if (action == @selector(copyHighlightString:)) {
        return YES;
    } else if (action == @selector(deleteHighlightString:)) {
        return YES;
    }
    return NO;
}

#pragma mark - normal
- (void)highlightSelectedString:(id)sender {
    [documentPage highlightPressSelection];
    [documentPage unSelectWord];
}
- (void)noteSelectedString:(id)sender {

}
- (void)copySelectedString:(id)sender {
    UIPasteboard *pd = [UIPasteboard generalPasteboard];
    [pd setString: [documentPage pressSelectionText]];
    [documentPage unSelectWord];
}

#pragma mark - highlight
- (void)copyHighlightString:(id)sender {
    UIPasteboard *pd = [UIPasteboard generalPasteboard];
    NSString *highlightStr = [documentPage textAtIndex:[highlightSelection index] count:[highlightSelection count]];
    [pd setString: highlightStr];
}
- (void)deleteHighlightString:(id)sender {
    [documentPage deleteHighlightSelectionForSelection: self->highlightSelection];
    [self setNeedsDisplay];
}

#pragma mark - note


#pragma mark - observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateSelectionKnobs];
    [self setNeedsDisplay];
}

- (void)hideMenuControllerIfNeeded {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.menuVisible) {
        [menuController setMenuVisible:NO animated:YES];
    }
}

@end
