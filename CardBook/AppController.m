#import "AppController.h"

@implementation AppController

+ (void) initialize {
    if (self == [AppController class]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"Defaults" ofType:@"plist"];
        NSDictionary *factorySettings = [NSDictionary dictionaryWithContentsOfFile:path];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:factorySettings];
    }
}

- (IBAction)showInspector:(id)sender {
    // use the accessor method to ensure info panel is instantiated
    [[CardInspector sharedInstance] showWindow:self];
}

- (IBAction)showPreferences:(id)sender {
    [[PreferencesPanelController sharedInstance] showWindow:self];
}

+ (void)dealloc {
    [super dealloc];
}

- (BOOL)applicationShouldOpenUntitledFile:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"OpenUntitled"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDocumentController *dc = [NSDocumentController sharedDocumentController];
    MyDocument *document = [dc currentDocument];
    if (!document) {
        [dc openDocumentWithContentsOfFile:[defaults stringForKey:@"LaunchFile"] display:YES];
    }
    [NSApp setServicesProvider:self];
}


- (void)makeCard:(NSPasteboard *)pboard
             userData:(NSString *)userData
                error:(NSString **)error
{
    NSDocumentController *dc = [NSDocumentController sharedDocumentController];
    MyDocument *document = [dc currentDocument];
    [dc setShouldCreateUI:YES];
    if (!document) {
        if ([[dc documents] count] > 0)
            document = [[dc documents] objectAtIndex:0];
    if (!document)
            document = [dc openUntitledDocumentOfType:@"CardBook Document" display:YES];
    }
    if (!document) {
        *error = NSLocalizedString(@"Error: can't open a CardBook",
                        @"Error: can't open a CardBook");
    }
    [document addCardFromPboard:pboard];
}

@end
