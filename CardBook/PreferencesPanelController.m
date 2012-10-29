#import "PreferencesPanelController.h"

@implementation PreferencesPanelController

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

    sharedInstance = self;
    return self;
}

- (NSString *) windowNibName {
    return @"Preferences";
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


- (IBAction)takeKeepBackupFrom:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender state] forKey:@"KeepBackup"];
}

- (IBAction)takeOpenUntitledFrom:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender state] forKey:@"OpenUntitled"];
}

- (IBAction)takeLaunchFileFrom:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[sender stringValue] forKey:@"LaunchFile"];
}

- (IBAction)browseLaunchFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];

    //[panel beginSheetForDirectory:nil file:nil types:[NSArray arrayWithObject:@"cardbook"] modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:panel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"cardbook"]];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (result == NSOKButton) {
            [launchFileField setStringValue:[(id)panel filename]];
            [defaults setObject:[(id)panel filename] forKey:@"LaunchFile"];
        }
    }];
}

/*- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)rc contextInfo:(void *)panel {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (rc == NSOKButton) {
        [launchFileField setStringValue:[(id)panel filename]];
        [defaults setObject:[(id)panel filename] forKey:@"LaunchFile"];
    }
}*/


- (void) windowDidLoad {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [keepBackupField setState:[defaults boolForKey:@"KeepBackup"]];
    [openUntitledField setState:[defaults boolForKey:@"OpenUntitled"]];
    if ([defaults objectForKey:@"LaunchFile"]) {
        [launchFileField setStringValue:[defaults objectForKey:@"LaunchFile"]];
    [[keepBackupField window] setFrameAutosaveName:@"InspectorWindows"];
    }
}

@end
