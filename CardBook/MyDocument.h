//
//  MyDocument.h
//  CardBook
//
//  Created by Paul Lynch on Tue Jan 22 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "Card.h"
#import "PLToolbar.h"

extern NSString *CBCardSelectionDidChangeNotification;
extern NSString *CardPboardType;

@interface MyDocument : NSDocument
{
    NSMutableArray *cards;
    NSMutableArray *displayCards;
    NSArray *draggedCards;

    NSRect windowRect;
    NSString *statusMessage;
    PLToolbar *toolbar;
    
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSTableView *tableView;
    IBOutlet NSTextView *cardView;
    IBOutlet NSButton *deleteButton;
    IBOutlet NSTextField *statusField;
    IBOutlet id findView;
    IBOutlet NSTextField *findField;
}

- (NSArray *)pboardTypes;

- (IBAction)newCard:(id)sender;
- (IBAction)deleteSelectedCard:(id)sender;
- (IBAction)focus:(id)sender;
- (IBAction)unfocus:(id)sender;
- (IBAction)sort:(id)sender;
- (IBAction)showInspector:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
    
- (NSMutableArray *)cards;
- (void)setCards:(NSMutableArray *)array;
- (NSArray *)cardsForRows:(NSArray *)rows;
- (Card *)selectedCard;
- (NSMutableArray *)selectedCards;
- (void)setSelectedCards:(NSArray *)array;
- (void)addCard:(Card *)card atRow:(int)row;
- (void)addCard:(Card *)card;
- (void)deleteCard:(Card *)card;
- (void)copyRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard;
- (void)addCardFromPboard:(NSPasteboard *)pboard;
- (void)addCardFromPboard:(NSPasteboard *)pboard atRow:(int)row;

@end
