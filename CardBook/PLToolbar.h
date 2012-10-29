//
//  PLToolbar.h
//  CardBook
//
//  Created by Paul Lynch on Mon Feb 04 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PLToolbar : NSObject {

    NSString *identifier;
    NSToolbar *toolbar;
    NSMutableDictionary *items;
    NSArray *defaults;
    id target;

}

- (id)initWithIdentifier:(NSString *)value target:(id)tget;

- (void)addStandardValues;
- (void)saveToPath:(NSString *)path;
- (NSToolbar *)toolbar;
- (void)setItems:(NSDictionary *)dict;
- (NSMutableDictionary *)items;
- (void)setDefaults:(NSArray *)value;
- (NSToolbarItem *)itemForIdentifier:(NSString *)ident;

@end
