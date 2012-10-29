//
//  CardsView.h
//  CardBook
//
//  Created by Paul Lynch on Fri Jan 25 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CardsView : NSView {
    BOOL formatted;
    int across, down;
    float vGap, hGap;
    float vInset, hInset;
    int numPages;
    
    NSArray *cards;
    float cardWidth;
    NSPrintInfo *printInfo;
}

- (id)initWithCards:(NSArray *)array width:(float)w printInfo:(NSPrintInfo *)pi;
- (void)setup;
- (void)setCards:(NSArray *)value;
- (void)setCardWidth:(float)value;
-(void)setPrintInfo:(NSPrintInfo *)value;

- (void)setVGap:(float)value;
- (void)setHGap:(float)value;
- (void)setFormatted:(bool)value;
- (void)setAcross:(int)value;
- (void)setDown:(int)value;

@end
