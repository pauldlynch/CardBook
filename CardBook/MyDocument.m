//
//  MyDocument.m
//  CardBook
//
//  Created by Paul Lynch on Tue Jan 22 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//

#import "MyDocument.h"
#import "Card.h"
#import "CardsView.h"
#import "FindPanel.h"
#import "CardInspector.h"

NSString *CBCardSelectionDidChangeNotification = @"CBCardSelectionDidChangeNotification";
NSString *CardPboardType = @"CardPboardType";

@implementation MyDocument

+ (void)initialize {
    if (self == [MyDocument class]) {
        [self setVersion:1];
    }
}

- (id)init {
    [super init];
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc MyDocument: %@", [self displayName]);
    [cards release];
    cards = nil;
    [displayCards release];
    displayCards = nil;
    [statusMessage release];
    statusMessage = nil;
    [toolbar release];
    [super dealloc];
}

- (NSMutableArray *)cards {
    if (cards == nil)
        cards = [[NSMutableArray array] retain];
    if (displayCards != nil) return displayCards;
    return cards;
}

- (void)setCards:(NSMutableArray *)array {
    [array retain];
    [cards release];
    cards = array;
    [displayCards release];
    displayCards = nil;
    [tableView reloadData];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that need to be executed once the windowController has loaded the document's window.
    [tableView registerForDraggedTypes:[self pboardTypes]];
//    [cardView setDrawsBackground:NO];
//    [scrollView setDrawsBackground:NO];
    if (!NSIsEmptyRect(windowRect)) {
        [aController setShouldCascadeWindows:NO];
        [[tableView window] setFrame:windowRect display:YES];
    }

    // toolbar set up
    toolbar = [[[PLToolbar alloc] initWithIdentifier:@"Toolbar" target:self] retain];
    [toolbar setDefaults:[NSArray arrayWithObjects:@"add", @"delete", nil]];
    [[toolbar itemForIdentifier:@"find"] setView:[findView retain]];
    [findField setTarget:[FindPanel sharedInstance]];
    [findField setAction:@selector(findNext:)];
    [[toolbar itemForIdentifier:@"find"] setMinSize:NSMakeSize(30, NSHeight([findView frame]))];
    [[toolbar itemForIdentifier:@"find"] setMaxSize:NSMakeSize(400, NSHeight([findView frame]))];
    [[cardView window] setToolbar:[toolbar toolbar]];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    NSMutableData *data = [NSMutableData dataWithCapacity:20];
    NSArchiver *coder = [[NSArchiver alloc] initForWritingWithMutableData:data];
    NSLog(@"encode: %@", aType);
    [coder encodeRootObject:cards];
    [coder encodeRect:[[tableView window] frame]];
    return data;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    // Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
    NSUnarchiver *coder = [[NSUnarchiver alloc] initForReadingWithData:data];
    int version = [coder versionForClassName:@"MyDocument"];
    NSLog(@"load version: %d, type: %@", version, aType);
    [self setCards:[coder decodeObject]];
    if (![coder isAtEnd]) {
        windowRect = [coder decodeRect];
    }
    [tableView reloadData];
    return YES;
}

- (void)addCard:(Card *)card atRow:(int)row {
    NSUndoManager *undoManager = [self undoManager];
    if (row < 0) row = [cards count];
    [cards insertObject:card atIndex:row];
    if (displayCards != nil) [displayCards insertObject:card atIndex:row];
    [tableView reloadData];
    [tableView selectRow:row byExtendingSelection:NO];
    [tableView scrollRowToVisible:row];
    [[cardView textStorage] setAttributedString:[card card]];
    [cardView setSelectedRange:NSMakeRange([[cardView string] length], 0)];
    // [self updateChangeCount:NSChangeDone];
    [undoManager registerUndoWithTarget:self selector:@selector(deleteSelectedCard:) object:self];
    [undoManager setActionName:@"Add Card"];
    [tableView noteNumberOfRowsChanged];
}

- (void)addCard:(Card *)card {
    [self addCard:card atRow:[tableView selectedRow]];
}

- (void)deleteCard:(Card *)card {
    NSUndoManager *undoManager = [self undoManager];
    int row = [cards indexOfObject:card];
    [cards removeObject:card];
    if (displayCards != nil) [displayCards removeObject:card];
    [tableView noteNumberOfRowsChanged];
    [tableView selectRow:row-1 byExtendingSelection:NO];
    [tableView scrollRowToVisible:row-1];
    // [self updateChangeCount:NSChangeDone];
    [undoManager registerUndoWithTarget:self selector:@selector(addCard:) object:card];
    [undoManager setActionName:@"Delete Card"];
}

- (NSArray *)cardsForRows:(NSArray *)rows {
    NSMutableArray* list = [NSMutableArray array];
    NSEnumerator *i = [rows objectEnumerator];
    NSNumber *r;
    int row = 0;

    if ([rows count] <= 0) return [NSArray array];
    while (r = [i nextObject]) {
        Card *card;
        if (row > [r intValue]) row = [r intValue];
        card = [[self cards] objectAtIndex:[r intValue]];
        [list addObject:card];
    }
    return [NSArray arrayWithArray:list];
}

- (Card *)selectedCard {
    int row = [tableView selectedRow];
    Card *card = nil;
    if (row != -1) {
        card = [[self cards] objectAtIndex:row];
    }
    return card;
}

// should really be in an NSTableView category
- (NSMutableArray *)selectedRows {
    NSMutableArray* list = [NSMutableArray array];
    NSEnumerator *i = [tableView selectedRowEnumerator];
    NSNumber *r;
    while (r = [i nextObject]) {
        [list addObject:r];
    }
    return list;
}

- (NSMutableArray *)selectedCards {
    NSMutableArray* list = [NSMutableArray array];
    NSEnumerator *i = [tableView selectedRowEnumerator];
    NSNumber *r;
    int row = 0;
    while (r = [i nextObject]) {
        if (row > [r intValue]) row = [r intValue];
        [list addObject:[[self cards] objectAtIndex:[r intValue]]];
    }
    return list;
}

-(void)setSelectedCards:(NSArray *)array {
    NSEnumerator *e = [array reverseObjectEnumerator];
    Card *card;
    BOOL extend = NO;

    while (card = [e nextObject]) {
        int i = [[self cards] indexOfObject:card];
        if (i != -1) {
            [tableView selectRow:i byExtendingSelection:extend];
            [tableView scrollRowToVisible:i];
            extend = YES;
        }
    }
}

// actions

-(IBAction) newCard:(id)sender {
    [self addCard:[Card card] atRow:[tableView selectedRow]];
}

-(IBAction) deleteSelectedCard:(id)sender {
    Card *card;
    int row = [tableView selectedRow];
    if (row != -1) {
        NSArray *cardArray = [self selectedCards];
        NSEnumerator *e = [cardArray objectEnumerator];
        while (card = [e nextObject]) {
            [self deleteCard:card];
        }
    }
}

- (void)focusOn:(NSMutableArray *)cardArray {
    NSUndoManager *undoManager = [self undoManager];
    [undoManager registerUndoWithTarget:self selector:@selector(focusOn:) object:displayCards];
    [undoManager setActionName:@"Focus"];
    [cardArray retain];
    [displayCards release];
    displayCards = [cardArray retain];
    [tableView noteNumberOfRowsChanged];
    [tableView reloadData];
}

- (IBAction)focus:(id)sender {
    [self focusOn:[self selectedCards]];
}

- (IBAction)unfocus:(id)sender {
    NSUndoManager *undoManager = [self undoManager];
    [undoManager registerUndoWithTarget:self selector:@selector(focusOn:) object:displayCards];
    [undoManager setActionName:@"Unfocus"];
    [displayCards release];
    displayCards = nil;
    [tableView reloadData];
}

- (IBAction)sort:(id)sender {
    NSMutableArray *array = cards;
    [array sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [self setCards:array];
}

- (IBAction)showInspector:(id)sender {
    // use the accessor method to ensure info panel is instantiated
    [[CardInspector sharedInstance] showWindow:self];
}

// other delegate stuff

- (BOOL) validateMenuItem:(NSMenuItem *)item {
    BOOL isValid = NO;

    if ([item action] == @selector(newCard:)) {
        isValid = YES;
    }
    if ([item action] == @selector(deleteSelectedCard:)) {
        if ([tableView selectedRow] != -1)
            isValid = YES;
    }
    if ([item action] == @selector(focus:)) {
        if ([tableView selectedRow] != -1)
            isValid = YES;
    }
    if ([item action] == @selector(unfocus:)) {
    }
    if (!isValid) isValid = [super validateMenuItem:item];
    return isValid;
}

- (BOOL) keepBackupFile {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"KeepBackup"];
}

// notifications

- (void) tableViewSelectionDidChange:(NSNotification *)note {
    int selectedRow = [tableView selectedRow];
    BOOL hasSelectedRow = (selectedRow != -1);
    Card *selectedCard = nil;

    // update control state
    [cardView setEditable:hasSelectedRow];
    [deleteButton setEnabled:hasSelectedRow];
    // update the notes view text
    if (hasSelectedRow) {
        statusMessage = [[NSString stringWithFormat:NSLocalizedString(@"%d card(s) selected (out of %d)", @"%d card(s) selected (out of %d)"), [tableView numberOfSelectedRows], [[self cards] count]] retain];
        [statusField setObjectValue:statusMessage];
        if ([tableView numberOfSelectedRows] == 1) {
            selectedCard = [[self cards] objectAtIndex:selectedRow];
            [[cardView textStorage] setAttributedString:[selectedCard card]];
            [cardView setEditable:![selectedCard isLocked]];
            [deleteButton setEnabled:YES];
        } else {
            [cardView setString:@""];
            [cardView setEditable:NO];
            [deleteButton setEnabled:NO];
        }
    } else {
        [statusField setObjectValue:[NSString stringWithFormat:NSLocalizedString(@"%d cards", @"%d cards"), [[self cards] count]]];
        [cardView setString:@""];
        [deleteButton setEnabled:NO];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CBCardSelectionDidChangeNotification object:self];
    [[cardView window] flushWindow];
}

- (void) textDidChange:(NSNotification *)notification {
    NSUndoManager *undoManager = [self undoManager];
    int selectedRow = [tableView selectedRow];
    if (selectedRow != -1) {
        Card *card = [[self cards] objectAtIndex:selectedRow];
        // NSData *oldCard = [card card];
        // [[undoManager prepareWithInvocationTarget:card] setCard:oldCard];
        [undoManager registerUndoWithTarget:card selector:@selector(setCard:) object:[card card]];
        [undoManager setActionName:@"Change Card"];
        [card setCard:[[NSAttributedString alloc] initWithAttributedString:[cardView textStorage]]];
        // [self updateChangeCount:NSChangeDone];
        [tableView reloadData];
    }
}

// pasteboard support

- (NSArray *)pboardTypes {
    // what about file, URL and image types?
    NSMutableArray *types = [NSMutableArray arrayWithObject:CardPboardType];
    [types addObject:NSRTFDPboardType];
    [types addObject:NSRTFPboardType];
    [types addObject:NSStringPboardType];
    return types;
}

- (void)copyRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard {
    NSArray *array = [self cardsForRows:rows];
    NSData *data = [NSArchiver archivedDataWithRootObject:array];
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSEnumerator *e = [array objectEnumerator];
    Card *card;
    while (card = [e nextObject]) {
        [aString appendAttributedString:[card card]];
    }
    [pboard declareTypes:[self pboardTypes] owner:self];
    [pboard setData:data forType:CardPboardType];
    [pboard setString:[aString string] forType:NSStringPboardType];
    [pboard setData:[aString RTFDFromRange:NSMakeRange(0, [aString length]) documentAttributes:nil] forType:NSRTFDPboardType];
    [pboard setData:[aString RTFFromRange:NSMakeRange(0, [aString length]) documentAttributes:nil] forType:NSRTFPboardType];
}

- (IBAction)copy:(id)sender {
    [self copyRows:[self selectedRows] toPasteboard:[NSPasteboard generalPasteboard]];
}

- (IBAction)cut:(id)sender {
    [self copy:self];
    [self deleteSelectedCard:self];
}

- (IBAction)paste:(id)sender {
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    [self addCardFromPboard:pboard];
}

- (void)addCardFromPboard:(NSPasteboard *)pboard {
    [self addCardFromPboard:pboard atRow:[tableView selectedRow]-1];
}

- (void)addCardFromPboard:(NSPasteboard *)pboard atRow:(int)row {
    Card *card;
    NSData *data;
    NSString *type;
    
    type = [pboard availableTypeFromArray:[self pboardTypes]];

    if ([type isEqual:CardPboardType]) {
        NSEnumerator *e;
        NSArray *cardArray;
        data = [pboard dataForType:CardPboardType];
        cardArray = [NSUnarchiver unarchiveObjectWithData:data];
        e = [cardArray objectEnumerator];
        while (card = [e nextObject])
            [self addCard:card atRow:row];
    }
    if ([type isEqual:NSRTFDPboardType]) {
        data = [pboard dataForType:NSRTFDPboardType];
        card = [Card card];
        [card setCardRTFD:data];
        [self addCard:card atRow:row];
    }
    if ([type isEqual:NSRTFPboardType]) {
        data = [pboard dataForType:NSRTFPboardType];
        card = [Card card];
        [card setCardRTF:data];
        [self addCard:card atRow:row];
    }
    if ([type isEqual:NSStringPboardType]) {
        NSString *pboardString = [pboard stringForType:NSStringPboardType];
        card = [Card card];
        [card setCardString:pboardString];
        [self addCard:card atRow:row];
    }
}

- (void)printShowingPrintPanel:(BOOL)flag {
    CardsView *view = [[CardsView alloc] initWithCards:[self cards] width:[[tableView window] frame].size.width printInfo:[self printInfo]];
    NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:view printInfo:[self printInfo]];
    [view setCardWidth:[[tableView window] frame].size.width];
    [printOp setShowPanels:flag];
    [printOp runOperation];
    [view release];
}

/* - (void)windowDidMove:(NSNotification *)aNotification {
    [self updateChangeCount:NSChangeDone];
}

- (void)windowDidResize:(NSNotification *)aNotification {
    [self updateChangeCount:NSChangeDone];
} */

@end
