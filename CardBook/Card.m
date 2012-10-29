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
    /*[coder encodeObject:created];
    [coder encodeObject:creator];
    [coder encodeObject:modified];
    [coder encodeObject:modifier];
    [coder encodeObject:card];
    [coder encodeValueOfObjCType:@encode(bool) at:&isLocked];*/
    
    [coder encodeObject:created forKey:@"CardBookCreated"];
    [coder encodeObject:creator forKey:@"CardBookCreator"];
    [coder encodeObject:modified forKey:@"CardBookModified"];
    [coder encodeObject:modifier forKey:@"CardBookModifier"];
    [coder encodeObject:card forKey:@"CardBookCard"];
    [coder encodeBool:isLocked forKey:@"CardBookIsLocked"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ([coder allowsKeyedCoding]) {
        created = [[coder decodeObjectForKey:@"CardBookCreated"] retain];
        creator = [[coder decodeObjectForKey:@"CardBookCreator"] retain];
        modified = [[coder decodeObjectForKey:@"CardBookModified"] retain];
        modifier = [[coder decodeObjectForKey:@"CardBookModifier"] retain];
        [self setCard:[coder decodeObjectForKey:@"CardBookCard"]];
        isLocked = [coder decodeBoolForKey:@"CardBookIsLocked"];
        return self;
    }
    
    // support old versions
    NSInteger version = [coder versionForClassName:@"Card"];
    //NSLog(@"initWithCoder version %ld", version);
    if (version == NSNotFound) NSLog(@"error loading cardbook file, version number for Card class not found");
    created = [[coder decodeObject] retain];
    creator = [[coder decodeObject] retain];
    modified = [[coder decodeObject] retain];
    modifier = [[coder decodeObject] retain];
    if (version == 1)
        [self setCardRTFD:[coder decodeObject]];
    else
        [self setCard:[coder decodeObject]];
    if (version == 3) {
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
    [self setCard:[[[NSAttributedString alloc] initWithRTFD:value documentAttributes:nil] autorelease]];
}

- (void)setCardRTF:(NSData *)value {
    [self setCard:[[[NSAttributedString alloc] initWithRTF:value documentAttributes:nil] autorelease]];
}

- (void)setCardString:(NSString *)value {
    [self setCard:[[[NSAttributedString alloc] initWithString:value] autorelease]];
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
