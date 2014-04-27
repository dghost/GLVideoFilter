#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "QuadModel.h"
#import "ShaderManager.h"
#import "FilterManager.h"

@interface FilterViewController : GLKViewController <AVCaptureVideoDataOutputSampleBufferDelegate, MBProgressHUDDelegate>  {
    
    NSUbiquitousKeyValueStore *defaults;
    MBProgressHUD *_HUD;
    UIImage *_lockedIcon;
    UIImage *_unlockedIcon;
    BOOL _blurMode;
    BOOL _modeLock;
    NSInteger _colorMode;
    QuadModel *_quad;
    FilterManager *_filters;
    ShaderManager *_shaders;

}

- (IBAction)tapGestureRecgonizer:(UITapGestureRecognizer *)sender;
- (IBAction)swipeGestureRecognizer:(UISwipeGestureRecognizer *)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end

