#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"


@interface FilterViewController : GLKViewController <AVCaptureVideoDataOutputSampleBufferDelegate, MBProgressHUDDelegate>  {
    
}

- (IBAction)tapGestureRecgonizer:(UITapGestureRecognizer *)sender;
- (IBAction)swipeGestureRecognizer:(UISwipeGestureRecognizer *)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end

