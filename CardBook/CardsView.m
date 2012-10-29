//
//  CardsView.m
//  CardBook
//
//  Created by Paul Lynch on Fri Jan 25 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//

#import "CardsView.h"
#import "Card.h"


@implementation CardsView

- initWithCards:(NSArray *)array width:(float)w printInfo:(NSPrintInfo *)pi {
    [self setCards:array];
    [self setPrintInfo:pi];
    [self setCardWidth:w];
    formatted = NO;
    vGap = 36.0;
    [self setup];
    return self;
}

- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }

- (void)dealloc {
    NSLog(@"dealloc CardsView");
    [cards release];
    [printInfo release];
    [super dealloc];
}

- (void)setup {
    NSEnumerator *e = [cards objectEnumerator];
    Card *card;
    float y = 0.0, pageBottom;
    
    NSSize pageSize = [printInfo paperSize];
    pageSize.width -= [printInfo leftMargin] + [printInfo rightMargin];
    pageSize.height -= [printInfo topMargin] + [printInfo bottomMargin];
    formatted = NO;
    numPages = 0;
    pageBottom = pageSize.height;
    
    if (cardWidth > pageSize.width) cardWidth = pageSize.width;
    
    while (card = [e nextObject]) {
        NSTextView *textView;
        NSSize textsize;
        
        NSRect r = NSMakeRect(0.0, y, cardWidth, 1e7);
        textView = [[NSTextView alloc] initWithFrame:r];
        [textView setVerticallyResizable:!formatted];
        [textView setHorizontallyResizable:NO];
        [[textView textStorage] setAttributedString:[card card]];
        [textView sizeToFit];
        textsize = [[textView layoutManager] usedRectForTextContainer:[textView textContainer]].size;
        [self addSubview:textView];
        // NSLog(@"text size: %f, %f", textsize.width, textsize.height);

        y += textsize.height + vGap;
        if (y  > pageBottom) {
            // card spills over page; what if card > 1 page??
            if (textsize.height <= pageSize.height) {
                NSLog(@"nudged to: %f", pageBottom);
                r.origin.y = pageBottom;
                y = pageBottom + textsize.height + vGap;
                [textView setFrameOrigin:r.origin];
            }
            pageBottom += pageSize.height;
            numPages++;
        }
        [textView release];
    }
    self = [super initWithFrame:NSMakeRect(0, 0, pageSize.width, y - vGap)];
}

- (void)setCards:(NSArray *)value {
    [value retain];
    [cards release];
    cards = [value retain];
}

- (void)setCardWidth:(float)value {
    cardWidth = value;
}

-(void)setPrintInfo:(NSPrintInfo *)value {
    [value retain];
    [printInfo release];
    printInfo = [value retain];
}

- (void)setVGap:(float)value { vGap = value; }
- (void)setHGap:(float)value { vGap = value; }
- (void)setFormatted:(bool)value { formatted = value; }
- (void)setAcross:(int)value { across = value; }
- (void)setDown:(int)value { down = value; }

// in theory these two methods are in some way "better" than plain drawRect

/* - (BOOL)knowsPageRange:(NSRangePointer)range {
    range->location = 1;
    range->length = numPages;
    return YES;
}

- (NSRect)rectForPage:(int)page {
    // this needs to allow for page borders, so isn't suitable for
    // normal view based applications
    NSRect r = NSMakeRect(0.0, (page-1) * [printInfo paperSize].height, [printInfo paperSize].width, page * [printInfo paperSize].height);
    NSLog(@"rectForPage: %f, %f, %f, %f", r.origin.x, r.origin.y, r.size.width, r.size.height);
    return r;
} */

- (void)drawRect:(NSRect)rect {
// all done with NSTextViews
}

- (void)drawPageBorderWithSize:(NSSize)borderSize {
    // in theory, I can use this to print page numbers and decorations
    // NSLog(@"borderSize: %f, %f", borderSize.width, borderSize.height);
}


@end
