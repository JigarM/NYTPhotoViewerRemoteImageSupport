//
//  NYTPhotoViewController.m
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/11/15.
//
//

#import "NYTPhotoViewController.h"
#import "NYTPhoto.h"
#import "NYTScalingImageView.h"
#import "SDWebImageDecoder.h"
#import "SDWebImageManager.h"
#import "SDWebImageOperation.h"

#ifdef ANIMATED_GIF_SUPPORT
#import <FLAnimatedImage/FLAnimatedImage.h>
#endif

NSString * const NYTPhotoViewControllerPhotoImageUpdatedNotification = @"NYTPhotoViewControllerPhotoImageUpdatedNotification";

@interface NYTPhotoViewController () <UIScrollViewDelegate> {
    id <SDWebImageOperation> _webImageOperation;
}

@property (nonatomic) NYTPhoto *photo;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (nonatomic) NYTScalingImageView *scalingImageView;
@property (nonatomic) UIView *loadingView;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation NYTPhotoViewController

#pragma mark - NSObject

- (void)dealloc {
    _scalingImageView.delegate = nil;
    
    [_notificationCenter removeObserver:self];
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithPhoto:nil loadingView:nil notificationCenter:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInitWithPhoto:nil loadingView:nil notificationCenter:nil];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.notificationCenter addObserver:self selector:@selector(photoImageUpdatedWithNotification:) name:NYTPhotoViewControllerPhotoImageUpdatedNotification object:nil];
    
    self.scalingImageView.frame = self.view.bounds;
    [self.view addSubview:self.scalingImageView];
    
    [self.view addSubview:self.loadingView];
    [self.loadingView sizeToFit];
    
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.scalingImageView.frame = self.view.bounds;
    
    [self.loadingView sizeToFit];
    self.loadingView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

#pragma mark - NYTPhotoViewController

- (instancetype)initWithPhoto:(NYTPhoto *)photo loadingView:(UIView *)loadingView notificationCenter:(NSNotificationCenter *)notificationCenter {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        [self commonInitWithPhoto:photo loadingView:loadingView notificationCenter:notificationCenter];
    }
    
    return self;
}

- (void)commonInitWithPhoto:(NYTPhoto *)photo loadingView:(UIView *)loadingView notificationCenter:(NSNotificationCenter *)notificationCenter {
    _photo = photo;
    
    if (photo.imageData) {
        _scalingImageView = [[NYTScalingImageView alloc] initWithImageData:photo.imageData frame:CGRectZero];
    }
    else {
        UIImage *photoImage = photo.image ?: photo.placeholderImage;
        _scalingImageView = [[NYTScalingImageView alloc] initWithImage:photoImage frame:CGRectZero];
        
        if (!photoImage) {
            [self setupLoadingView:loadingView];
        }
        
        if(photo.remoteURL){
            [self _performLoadRemoteImageAndNotifyWithPhoto:photo];
        }
    }
    
    _scalingImageView.delegate = self;

    _notificationCenter = notificationCenter;

    [self setupGestureRecognizers];
}

// Load from local file
- (void)_performLoadRemoteImageAndNotifyWithPhoto:(NYTPhoto *)photo {
    @try {
        NSURL *url = [NSURL URLWithString:photo.remoteURL];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        _webImageOperation = [manager
                              downloadImageWithURL:url
                              options:0
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                  if (error) {
                                        NSLog(@"SDWebImage failed to download image: %@", error);
                                  }
                                  _webImageOperation = nil;
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self updateImage:image imageData:nil];
                                  });
                                }];
    } @catch (NSException *e) {
        NSLog(@"Photo from web: %@", e);
        _webImageOperation = nil;
        [self updateImage:nil imageData:nil];
    }
}


- (void)setupLoadingView:(UIView *)loadingView {
    self.loadingView = loadingView;
    if (!loadingView) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator startAnimating];
        self.loadingView = activityIndicator;
    }
}

- (void)photoImageUpdatedWithNotification:(NSNotification *)notification {
    NYTPhoto *photo = notification.object;
    //if ([photo conformsToProtocol:@protocol(NYTPhoto)] && [photo isEqual:self.photo]) {
        [self updateImage:photo.image imageData:photo.imageData];
    //}
}

- (void)updateImage:(UIImage *)image imageData:(NSData *)imageData {
    if (imageData) {
        [self.scalingImageView updateImageData:imageData];
    }
    else {
        [self.scalingImageView updateImage:image];
    }
    
    if (imageData || image) {
        [self.loadingView removeFromSuperview];
    } else {
        [self.view addSubview:self.loadingView];
    }
}

#pragma mark - Gesture Recognizers

- (void)setupGestureRecognizers {
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapWithGestureRecognizer:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressWithGestureRecognizer:)];
}

- (void)didDoubleTapWithGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    CGPoint pointInView = [recognizer locationInView:self.scalingImageView.imageView];
    
    CGFloat newZoomScale = self.scalingImageView.maximumZoomScale;

    if (self.scalingImageView.zoomScale >= self.scalingImageView.maximumZoomScale
        || ABS(self.scalingImageView.zoomScale - self.scalingImageView.maximumZoomScale) <= 0.01) {
        newZoomScale = self.scalingImageView.minimumZoomScale;
    }
    
    CGSize scrollViewSize = self.scalingImageView.bounds.size;
    
    CGFloat width = scrollViewSize.width / newZoomScale;
    CGFloat height = scrollViewSize.height / newZoomScale;
    CGFloat originX = pointInView.x - (width / 2.0);
    CGFloat originY = pointInView.y - (height / 2.0);
    
    CGRect rectToZoomTo = CGRectMake(originX, originY, width, height);
    
    [self.scalingImageView zoomToRect:rectToZoomTo animated:YES];
}

- (void)didLongPressWithGestureRecognizer:(UILongPressGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(photoViewController:didLongPressWithGestureRecognizer:)]) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            [self.delegate photoViewController:self didLongPressWithGestureRecognizer:recognizer];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.scalingImageView.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.panGestureRecognizer.enabled = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
    // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
    if (scrollView.zoomScale == scrollView.minimumZoomScale) {
        scrollView.panGestureRecognizer.enabled = NO;
    }
}

@end
