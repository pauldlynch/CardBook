//
//  Card.h
//  CardBook
//
//  Created by Paul Lynch on Tue Jan 22 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Card : NSObject <NSCoding> {

    NSAttributedString *card;
    NSCalendarDate *created;
    NSString *creator;
    NSCalendarDate *modified;
    NSString *modifier;
    bool isLocked;

}

+(Card *)card;

- (NSAttributedString *)card;
- (NSString *)cardString;
- (void)setCard:(NSAttributedString *)value;
- (void)setCardRTFD:(NSData *)value;
- (void)setCardRTF:(NSData *)value;
- (void)setCardString:(NSString *)value;

- (NSString *)title;

- (bool)isLocked;
- (void)setIsLocked:(bool)value;

- (NSString *)creator;
- (NSCalendarDate *)created;
- (NSString *)modifier;
- (NSCalendarDate *)modified;

- (NSString *)description;

- (BOOL)contains:(NSString *)value;
- (NSComparisonResult)compare:(Card *)value;
- (NSComparisonResult)caseInsensitiveCompare:(Card *)value;

@end
