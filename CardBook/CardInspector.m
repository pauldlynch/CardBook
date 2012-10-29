
#import "CardInspector.h"

@implementation CardInspector

static id sharedInstance = nil;

+ (id)sharedInstance {
    if (!sharedInstance) {
        [[self allocWithZone:[[NSApplication sharedApplication] zone]] init];
    }
    return sharedInstance;
}

- init {
    NSNotificationCenter *dnc;

    if (sharedInstance) {
        [super dealloc];
        return sharedInstance;
    }

    if (!(self = [super init])) return nil;

    sharedInstance = self;
    
    dnc = [NSNotificationCenter defaultCenter];
    
    // register for selection changed notifications
    [dnc addObserver:self
        selector:@selector(cardSelectionDidChange:)
        name:CBCardSelectionDidChangeNotification
        object:nil];
        
    // register for main window change notifications
    [dnc addObserver:self
        selector:@selector(windowDidBecomeMain:)
        name:NSWindowDidBecomeMainNotification
        object:nil];
    [dnc addObserver:self
        selector:@selector(windowDidResignMain:)
        name:NSWindowDidResignMainNotification
        object:nil];
        
    return self;
}

- (void)windowDidLoad {
    // set the initial view
    [super windowDidLoad];
    [self inspectSelectedCardFromWindow:
            [[NSApplication sharedApplication] mainWindow]];
    [[creatorField window] setFrameAutosaveName:@"InspectorWindows"];
}

- (void)cardSelectionDidChange:(NSNotification *)note {
    // documents notify us that the selection has changed
    // we need to find out the newly-selected card
    [self cardSelectionDidChangeTo:[[note object] selectedCard]];
}

- (void)cardSelectionDidChangeTo:(Card *)card {
    if (card == nil) {
        [tabView selectTabViewItemAtIndex:0];
    } else {
        [tabView selectTabViewItemAtIndex: 1];
        [creatorField setStringValue:[card creator]];
        [createdField setObjectValue:[card created]];
        [modifierField setStringValue:[card modifier]];
        [modifiedField setObjectValue:[card modified]];
        [lockedButton setState:[card isLocked]];
    }
}

- (IBAction)setLockedFlag:(id)sender {
    NSDocumentController *dc = [NSDocumentController sharedDocumentController];
    [[[dc currentDocument] selectedCard] setIsLocked:[lockedButton state]];
}

// watch out for key window changing
// -- selected expense will obviously change at the same time
- (void)windowDidResignMain:(NSNotification *)note {
    [self cardSelectionDidChangeTo:nil];
}

- (void)windowDidBecomeMain:(NSNotification *)note {
    [self inspectSelectedCardFromWindow:[note object]];
}

- (void)inspectSelectedCardFromWindow:(NSWindow *)window {
    Card *card = nil;
    id windowDelegate = [window delegate];
    
    if (windowDelegate && [windowDelegate respondsToSelector:@selector(selectedCard)]) {
        card = [windowDelegate selectedCard];
    }
    [self cardSelectionDidChangeTo:card];
}

- (NSString *)windowNibName {
    return @"CardInspector";
}

- (void)dealloc {
    // release instance variables and remove from notification center
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
    [dnc removeObserver:self];
    [super dealloc];
}

@end
