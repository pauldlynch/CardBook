//
//  MyDocumentDataSource.m
//  CardBook
//
//  Created by Paul Lynch on Thu Jan 24 2002.
//  Copyright (c) 2001 P & L Software. All rights reserved.
//

#import "MyDocumentDataSource.h"

@implementation MyDocument(MyDocumentDataSource)

// data source methods

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tv {
    return [[self cards] count];
}

- (id) tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tc row:(int) row {
    Card *c = [[self cards] objectAtIndex:row];
    return [c valueForKey:[tc identifier]];
}

- (void)tableView:(NSTableView *)tv setObjectValue:(id)object forTableColumn:(NSTableColumn *)tc row:(int)row {
    // NSUndoManager *undoManager = [self undoManager];
    Card *c = [[self cards] objectAtIndex:row];
    //[c takeValue:object forKey:[tc identifier]];
    [c setValue:object forKey:[tc identifier]];
    // should be handled by undo...
    [self updateChangeCount:NSChangeDone];
}

// drag and drop support

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard {
    if ([rows count] <= 0) return NO;
    //[draggedCards release];
    draggedCards = [[self cardsForRows:rows] retain];
    [self copyRows:rows toPasteboard:pboard];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
    if ([info draggingSource]) { // source is in same app, I think
        return NSDragOperationMove;
    }
    return (NSDragOperationCopy);
}

- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op {
    NSPasteboard *pboard = [info draggingPasteboard];
    if (op == NSTableViewDropAbove) {
        [self addCardFromPboard:pboard atRow:row];
    } else {	//     NSTableViewDropOn
        [self addCardFromPboard:pboard atRow:row+1];
    }
    if ([info draggingSource] == tv) {
        NSEnumerator *e = [draggedCards objectEnumerator];
        Card *card;
        while (card = [e nextObject]) {
            [self deleteCard:card];
        }
        [draggedCards release];
    }
    [tableView reloadData];
    return YES;
}

@end
