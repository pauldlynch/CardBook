/* PreferencesPanelController */

#import <Cocoa/Cocoa.h>

@interface PreferencesPanelController : NSWindowController
{
    IBOutlet NSButton *keepBackupField;
    IBOutlet NSButton *openUntitledField;
    IBOutlet NSTextField *launchFileField;
}

+ (id)sharedInstance;

- (IBAction)takeKeepBackupFrom:(id)sender;
- (IBAction)takeOpenUntitledFrom:(id)sender;
- (IBAction)takeLaunchFileFrom:(id)sender;
- (IBAction)browseLaunchFile:(id)sender;

@end
