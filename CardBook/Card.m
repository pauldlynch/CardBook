//
//  Card.m
//  CardBook
//
//  Created by Paul Lynch on Tue Jan 22 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Card.h"


@implementation Card

+ (void)initialize {
    if (self == [Card class]) {
        [self setVersion:3];
    }
}

+ (Card *)card {
    Card *newCard = [[[self alloc] init] autorelease];
    [newCard setCardString:@""];
    return newCard;
}

- (id)init {
    created = modified = [[NSCalendarDate date] retain];
    creator = modifier = [NSUserName() retain];
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc card: %@", [self title]);
    created = nil;
    creator = nil;
    modified = nil;
    modifier = nil;
    card = nil;
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:created];
    [coder encodeObject:creator];
    [coder encodeObject:modified];
    [coder encodeObject:modifier];
    [coder encodeObject:card];
    [coder encodeValueOfObjCType:@encode(bool) at:&isLocked];
}

- (id)initWithCoder:(NSCoder *)coder {
    int version = [coder versionForClassName:@"Card"];
    created = [[coder decodeObject] retain];
    creator = [[coder decodeObject] retain];
    modified = [[coder decodeObject] retain];
    modifier = [[coder decodeObject] retain];
    if (version == 1)
        [self setCardRTFD:[coder decodeObject]];
    else
        [self setCard:[coder decodeObject]];
    if (version > 2) {
        [coder decodeValueOfObjCType:@encode(bool) at:&isLocked];
    }
    return self;
}

- (NSAttributedString *)card { return card; }

- (NSString *)cardString {
    return [[self card] string];
}

- (void)setCard:(NSAttributedString *)value {
    [value retain];
    [card release];
    card = value;
}

- (void)setCardRTFD:(NSData *)value {
    [self setCard:[[NSAttributedString alloc] initWithRTFD:value documentAttributes:nil]];
}

- (void)setCardRTF:(NSData *)value {
    [self setCard:[[NSAttributedString alloc] initWithRTF:value documentAttributes:nil]];
}

- (void)setCardString:(NSString *)value {
    [self setCard:[[NSAttributedString alloc] initWithString:value]];
}

- (NSString *)title {
    NSString *title = (NSString *)[[[self cardString] componentsSeparatedByString:@"\n"] objectAtIndex:0];
    if ([title length] < 80) {
        return title;
    }
    return [[title substringToIndex:(80 - 1)] stringByAppendingString:@"..."];
}

- (bool)isLocked { return isLocked; }
- (void)setIsLocked:(bool)value {
    isLocked = value;
}


- (NSString *)creator { return creator; }
- (NSCalendarDate *)created { return created; }
- (NSString *)modifier { return modifier; }
- (NSCalendarDate *)modified { return modified; }

- (NSString *)description { return [self cardString]; }

- (BOOL)contains:(NSString *)value {
    NSRange result = [[card string] rangeOfString:value options:(NSCaseInsensitiveSearch)];
    if (result.location == NSNotFound) return NO;
    return YES;
}

- (NSComparisonResult)compare:(Card *)value {
    return [[self title] compare:[value title]];
}

- (NSComparisonResult)caseInsensitiveCompare:(Card *)value {
    return [[self title] caseInsensitiveCompare:[value title]];
}

@end
