//
//  UXReaderPageControlView.h
//  PDFReader
//
//  Created by xhgc01 on 2019/1/3.
//  Copyright © 2019 baleen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UXReaderDocument;
@class UXReaderPageControlView;
@protocol UXReaderPageControlViewDelegate <NSObject>

@required // Delegate protocols

- (void)pageControlView:(nonnull UXReaderPageControlView *)control gotoPage:(NSUInteger)page;

@end

@interface UXReaderPageControlView : UIView
@property (nullable, weak, nonatomic, readwrite) id <UXReaderPageControlViewDelegate> delegate;

- (nullable instancetype)initWithDocument:(nonnull UXReaderDocument *)document;
- (void)setCurrentPage: (NSUInteger)page;
@end
