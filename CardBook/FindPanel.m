//
//  FindPanel.m
//  CardBook
//
//  Created by Paul Lynch on Sat Jan 26 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//

#import "FindPanel.h"
#import "MyDocument.h"
#import "Card.h"

#define Forward YES
#define Backward NO

@interface NSString (NSStringTextFinding)

- (NSRange)findString:(NSString *)string selectedRange:(NSRange)selectedRange options:(unsigned)mask wrap:(BOOL)wrapFlag;

@end


@implementation FindPanel

static id sharedInstance = nil;

+ (id)sharedInstance {
    if (!sharedInstance) {
        [[self allocWithZone:[[NSApplication sharedApplication] zone]] init];
    }
    return sharedInstance;
}

- (id)init {
    if (sharedInstance) {
        [super dealloc];
        return sharedInstance;
    }

    if (!(self = [super init])) return nil;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidActivate:) name:NSApplicationDidBecomeActiveNotification object:[NSApplication sharedApplication]];

    [self setFindString:@"" writeToPasteboard:NO];
    [self loadFindStringFromPasteboard];

    sharedInstance = self;
    return self;
}

- (NSString *) windowNibName {
    return @"FindPanel";
}

- (void)showWindow: (id)sender {
    if (![self window]) {
        if (![NSBundle loadNibNamed:[self windowNibName] owner:self]) {
            NSLog(@"loadNibNamed %@ failed", [self windowNibName]);
            NSBeep();
        }
    }
    [[self window] makeKeyAndOrderFront:self];
}

- (void)appDidActivate:(NSNotification *)notification {
    [self loadFindStringFromPasteboard];
}

- (void)loadFindStringFromPasteboard {
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFindPboard];
    if ([[pasteboard types] containsObject:NSStringPboardType]) {
        NSString *string = [pasteboard stringForType:NSStringPboardType];
        if (string && [string length]) {
            [self setFindString:string writeToPasteboard:NO];
        }
    }
}

- (void)loadFindStringToPasteboard {
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFindPboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteboard setString:[self findString] forType:NSStringPboardType];
}

- (void)dealloc {
    if (self != sharedInstance) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [findString release];
        [super dealloc];
    }
}

- (NSString *)findString {
    return findString;
}

- (void)setFindString:(NSString *)string {
    [self setFindString:string writeToPasteboard:YES];
}

- (void)setFindString:(NSString *)string writeToPasteboard:(BOOL)flag {
    if ([string isEqualToString:findString]) return;
    [findString autorelease];
    findString = [string copyWithZone:[self zone]];
    [self setCards:nil];
    if (findField) {
        [findField setStringValue:string];
        [findField selectText:nil];
    }
    if (flag) [self loadFindStringToPasteboard];
}

- (void)setCards:(NSMutableArray *)value {
    [value retain];
    [cards release];
    cards = value;
}

- (NSPanel *)findPanel {
    if (!findField) {
        if (![NSBundle loadNibNamed:@"FindPanel" owner:self]) {
            NSLog(@"loadNibNamed %@ failed", @"FindPanel");
            NSBeep();
        }
        if (self == sharedInstance) [[findField window] setFrameAutosaveName:@"Find"];
        [findField setStringValue:[self findString]];
    }
    return (NSPanel *)[findField window];
}

- (NSTextView *)textObjectToSearchIn {
    // not NSDocument oriented; needs to go down fR chain
    id obj = [[NSApp mainWindow] firstResponder];
    if ([obj isKindOfClass:[NSTextView class]])
        return obj;
    return nil;
//    return (obj && [obj isKindOfClass:[NSTextView class]]) ? obj : nil;
}

// actions

- (IBAction)orderFrontFindPanel:(id)sender {
    NSPanel *panel = [self findPanel];
    [findField selectText:nil];
    [panel makeKeyAndOrderFront:nil];
}

- (IBAction)findNextAndOrderFindPanelOut:(id)sender {
    [findNextButton performClick:nil];
    if (lastFindWasSuccessful) {
        [[self findPanel] orderOut:sender];
    } else {
        [findField selectText:nil];
    }
}

- (IBAction)findNext:(id)sender {
    if (findField && sender == findNextButton) {
        [self setFindString:[findField stringValue]];
    } else {
        [self setFindString:[sender stringValue]];
    }
    (void)[self find:Forward];
    if ([sender isKindOfClass:[NSTextField class]]) {
        [[sender window] makeFirstResponder:sender];
        [sender selectText:nil];
    }
}

- (IBAction)findPrevious:(id)sender {
    if (findField) [self setFindString:[findField stringValue]];
    (void)[self find:Backward];
}

- (IBAction)takeFindStringFromSelection:(id)sender {
    NSTextView *textView = [self textObjectToSearchIn];
    if (textView) {
        NSString *selection = [[textView string] substringWithRange:[textView selectedRange]];
        [self setFindString:selection];
    }
}

- (IBAction)jumpToSelection:sender {
    NSTextView *textView = [self textObjectToSearchIn];
    if (textView) {
        [textView scrollRangeToVisible:[textView selectedRange]];
    }
}

- (IBAction)findAll:(id)sender {
    MyDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
    [document setSelectedCards:[self findCards]];
}

// finally, the real stuff...

// however, the design is dumb.  There should be a category on NSTextView
// and another on NSTableView, both implementing a Finder protocol,
// which calls a find primitive supported by both the table view datasource
// and the NSText complex.

- (NSArray *)findCards {
    NSMutableArray *result = [NSMutableArray array];
    NSEnumerator *e;
    Card *card;
    MyDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
    
    [self setCards:nil];
    findIndex = -1;
    // need to get cards from MyDocument,,,
    e = [[document cards] objectEnumerator];
    while (card = [e nextObject]) {
        if ([card contains:findString])
            [result addObject:card];
    }
    if ([result count] > 0) {
        [self setCards:result];
        return result;
    } else
        NSBeep();
    return nil;
}

- (BOOL)find:(BOOL)direction {
    NSTextView *text = [self textObjectToSearchIn];
    lastFindWasSuccessful = NO;
    if (text) {
        NSString *textContents = [text string];
        unsigned textLength;
        if (textContents && (textLength = [textContents length])) {
            NSRange range;
            unsigned options = 0;
            if (direction == Backward) options |= NSBackwardsSearch;
            if ([ignoreCaseSwitch state]) options |= NSCaseInsensitiveSearch;
            range = [textContents findString:[self findString] selectedRange:[text selectedRange] options:options wrap:YES];
            if (range.length) {
                [text setSelectedRange:range];
                [text scrollRangeToVisible:range];
                lastFindWasSuccessful = YES;
            }
        }
        if (!lastFindWasSuccessful) {
            NSBeep();
            [message setStringValue:NSLocalizedStringFromTable(@"Not found", @"FindPanel", @"Status displayed in find panel when the find string is not found.")];
        } else {
            [message setStringValue:@""];
        }
        return lastFindWasSuccessful;
    }
    if (cards == nil) [self findCards];
    if (cards && ([cards count] > 0)) {
        MyDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
        // pick the next one from the list
        if (direction == Forward) findIndex++;
        if (direction == Backward) findIndex--;
        if (findIndex < 0) findIndex = [cards count]-1;
        if (findIndex >= [cards count]) findIndex = 0;
    
        lastFindWasSuccessful = YES;
        [document setSelectedCards:[NSArray arrayWithObject:[cards objectAtIndex:findIndex]]];
        [message setStringValue:@""];
    } else {
        NSBeep();
        [message setStringValue:NSLocalizedString(@"Not found", @"Status displayed in find panel when the find string is not found.")];
    }
    return lastFindWasSuccessful;
}


@end


@implementation NSString (NSStringTextFinding)

- (NSRange)findString:(NSString *)string selectedRange:(NSRange)selectedRange options:(unsigned)options wrap:(BOOL)wrap {
    BOOL forwards = (options & NSBackwardsSearch) == 0;
    unsigned length = [self length];
    NSRange searchRange, range;

    if (forwards) {
        searchRange.location = NSMaxRange(selectedRange);
        searchRange.length = length - searchRange.location;
        range = [self rangeOfString:string options:options range:searchRange];
        if ((range.length == 0) && wrap) {	/* If not found look at the first part of the string */
            searchRange.location = 0;
            searchRange.length = selectedRange.location;
            range = [self rangeOfString:string options:options range:searchRange];
        }
    } else {
        searchRange.location = 0;
        searchRange.length = selectedRange.location;
        range = [self rangeOfString:string options:options range:searchRange];
        if ((range.length == 0) && wrap) {
            searchRange.location = NSMaxRange(selectedRange);
            searchRange.length = length - searchRange.location;
            range = [self rangeOfString:string options:options range:searchRange];
        }
}
return range;
}

@end

