//
//  PLToolbar.m
//  CardBook
//
//  Created by Paul Lynch on Mon Feb 04 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//

#import "PLToolbar.h"

// needs to cater for views, and for different targets


@implementation PLToolbar

- (id)initWithIdentifier:(NSString *)value target:(id)tget {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *toolbarPath = [[bundle pathForResource:value ofType:@"plist"] retain];
    identifier = [value retain];
    target = [tget retain];
    [self setItems:[NSDictionary dictionaryWithContentsOfFile:toolbarPath]];

    toolbar = [[[NSToolbar alloc] initWithIdentifier:identifier] retain];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];

//    [self addStandardValues];
//    [self saveToPath:toolbarPath];

    return self;
}

- (void)dealloc {
    [toolbar release];
    [identifier release];
    [target release];
    [items release];
    [defaults release];
    [super dealloc];
}

- (void)addStandardValues {
    NSToolbarItem *item;

    item = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarSeparatorItemIdentifier];
    [items setObject:item forKey:NSToolbarSeparatorItemIdentifier];
    [item release];
    item = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarSpaceItemIdentifier];
    [items setObject:item forKey:NSToolbarSpaceItemIdentifier];
    [item release];
    item = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier];
    [items setObject:item forKey:NSToolbarFlexibleSpaceItemIdentifier];
    [item release];
    item = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarShowColorsItemIdentifier];
    [items setObject:item forKey:NSToolbarShowColorsItemIdentifier];
    [item release];
    item = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarShowFontsItemIdentifier];
    [items setObject:item forKey:NSToolbarShowFontsItemIdentifier];
    [item release];
    item = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarCustomizeToolbarItemIdentifier];
    [items setObject:item forKey:NSToolbarCustomizeToolbarItemIdentifier];
    [item release];
    item = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarPrintItemIdentifier];
    [items setObject:item forKey:NSToolbarPrintItemIdentifier];
    [item release];
}

- (void)saveToPath:(NSString *)path {
    [[self items] writeToFile:path atomically:YES];
}

- (NSToolbar *)toolbar {
    return toolbar;
}

- (NSMutableDictionary *)items {
    NSEnumerator *e = [items objectEnumerator];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSToolbarItem *item;

    while (item = [e nextObject]) {
        NSMutableDictionary *value = [NSMutableDictionary dictionary];
        if ([item itemIdentifier]) {
            [value setObject:[item itemIdentifier] forKey:@"identifier"];
            if ([item label])
                [value setObject:[item label] forKey:@"label"];
            if ([item toolTip])
                [value setObject:[item toolTip] forKey:@"tooltip"];
            if ([item action])
                [value setObject:NSStringFromSelector([item action]) forKey:@"selector"];
            if ([[item image] name])
                [value setObject:[[item image] name] forKey:@"image"];
            
            [dict setObject:value forKey:[item itemIdentifier]];
        }
        [value release];
    }
    return dict;
}

- (void)setItems:(NSDictionary *)dict {
    // keys are: identifier, label, tooltip, selector, image
    NSEnumerator *e = [dict objectEnumerator];
    NSDictionary *value;
    
    [items release];
    items = [[NSMutableDictionary dictionary] retain];
    while (value = [e nextObject]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:[value objectForKey:@"identifier"]];

        if ([value objectForKey:@"label"]) {
            [item setPaletteLabel:[value objectForKey:@"label"]];
            [item setLabel:[value objectForKey:@"label"]];
        }
        if ([value objectForKey:@"tooltip"])
            [item setToolTip:[value objectForKey:@"tooltip"]];
        [item setTarget:target];
        if ([value objectForKey:@"selector"])
            [item setAction:NSSelectorFromString([value objectForKey:@"selector"])];
        if ([value objectForKey:@"image"])
            [item setImage:[NSImage imageNamed:[value objectForKey:@"image"]]];

        [items setObject:item forKey:[value objectForKey:@"identifier"]];

        [item release];
    }
}

- (void)setDefaults:(NSArray *)value {
    [value retain];
    [defaults release];
    defaults = value;
}

- (NSToolbarItem *)itemForIdentifier:(NSString *)ident {
    return [items objectForKey:ident];
}

// toolbar delegate methods

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    return defaults;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    return [items allKeys];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return [items objectForKey:itemIdentifier];
}

@end
