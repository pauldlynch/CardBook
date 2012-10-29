//
//  FindPanel.h
//  CardBook
//
//  Created by Paul Lynch on Sat Jan 26 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FindPanel : NSWindowController {
    NSString *findString;
    NSInteger findIndex;
    NSArray *cards;

    IBOutlet NSTextField *message;
    IBOutlet NSTextField *findField;
    IBOutlet NSButtonCell *ignoreCaseSwitch;
    IBOutlet id findNextButton;
    BOOL lastFindWasSuccessful;
}

+ (id)sharedInstance;

- (NSPanel *)findPanel;

- (NSString *)findString;
- (void)setFindString:(NSString *)string;
- (void)setFindString:(NSString *)string writeToPasteboard:(BOOL)flag;
- (void)loadFindStringFromPasteboard;
- (void)loadFindStringToPasteboard;
- (void)setCards:(NSMutableArray *)value;

- (IBAction)orderFrontFindPanel:(id)sender;
- (IBAction)findNextAndOrderFindPanelOut:(id)sender;
- (IBAction)findNext:(id)sender;
- (IBAction)findPrevious:(id)sender;
- (IBAction)takeFindStringFromSelection:(id)sender;
- (IBAction)jumpToSelection:sender;
- (IBAction)findAll:(id)sender;

- (NSArray *)findCards;
- (BOOL)find:(BOOL)direction;

@end
