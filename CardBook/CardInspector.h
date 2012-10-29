#import <Cocoa/Cocoa.h>

#import "AppController.h"
#import "MyDocument.h"
#import "Card.h"

extern NSString *CBCardSelectionDidChangeNotification;

@interface CardInspector : NSWindowController {
    IBOutlet NSTabView *tabView;
    IBOutlet NSTextField *createdField;
    IBOutlet NSTextField *creatorField;
    IBOutlet NSTextField *modifiedField;
    IBOutlet NSTextField *modifierField;
    IBOutlet NSButton *lockedButton;
}

+ (id)sharedInstance;

- (IBAction)setLockedFlag:(id)sender;

    - (void)cardSelectionDidChange:(NSNotification *)note;
- (void)cardSelectionDidChangeTo:(Card *)expense;

- (void)windowDidResignMain:(NSNotification *)note;
- (void)windowDidBecomeMain:(NSNotification *)note;
- (void)inspectSelectedCardFromWindow:(NSWindow *)window;

@end
