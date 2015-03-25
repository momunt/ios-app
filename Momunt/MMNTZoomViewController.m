//
//  MMNTZoomViewController.m
//  Momunt
//
//  Created by Masha Belyi on 7/2/14.
//  Copyright (c) 2014 Masha Belyi. All rights reserved.
//

#import "MMNTZoomViewController.h"
#import "MMNTPhoto.h"
#import "AsyncImageView.h"
#import "MMNT_MapPin.h"
#import "MMNTViewController.h"
#import "POPSpringAnimation.h"

#import "POPSpringAnimation.h"
#import "POPBasicAnimation.h"

#import "MMNT_BlurContainer.h"
#import "MMNT_TrashView.h"
#import "MMNT_ZoomCell.h"

#import "MMNTShareTransitionManager.h"
#import "MMNT_SharedVars.h"

#import "MMNTDataController.h"
#import "MMNTAccountManager.h"
#import "MMNT_ShareButtons.h"

#import "Amplitude.h"
#import "MMNTAppDelegate.h"
#import "MTReachabilityManager.h"
#import "MMNTObj.h"
#import "LocationController.h"
#import "MMNTDataController.h"

@interface MMNTZoomViewController() <MMNTShareTransitioning>{
    BOOL _following;
}
    @property CGRect startFrame;

    @property BOOL hidden;

    @property UIView *containerView;

    @property CGPoint startCenter;
//    @property CATransform3D startScale;
    @property CGAffineTransform returnScale;

    @property MMNTViewController *mainController;

    @property BOOL blurred;
    @property BOOL trashOpen;
    @property BOOL pinching; // YES when user is pinchng view to scale/rotate

//    @property MMNT_BlurContainer *blurContainer;
    @property MMNT_TrashView *trashView;

@property BOOL doneCentering;
@property BOOL doneScaling;

@property BOOL animating;

@property BOOL shouldUpdateMmntId;

@property BOOL stopBouncing;
@property CLLocationCoordinate2D touchCoordinate;

@property BOOL loadingCustomMomunt;
@property float pressDuration;
@property NSTimer *pressTimer;

@property BOOL tipPresented;
@property NSInteger currTipId;
@end

@implementation MMNTZoomViewController

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)bounceAnimation{
    POPSpringAnimation *down = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
    down.toValue = [NSValue valueWithCGPoint:CGPointMake(0,0)];
    down.springBounciness = 20;
    down.springSpeed = 10;
    down.completionBlock = ^(POPAnimation *animation, BOOL finished){
        if(!_stopBouncing){
            [self bounceAnimation];
        }
    };

    
    POPBasicAnimation *up = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
    up.toValue = [NSValue valueWithCGPoint:CGPointMake(0,-30)];
    up.duration = 0.06;
    up.beginTime = CACurrentMediaTime() + 3.0;
    up.completionBlock = ^(POPAnimation *animation, BOOL finished){
        [_zoomContainer.layer pop_addAnimation:down forKey:@"position"];
    };
    [_zoomContainer.layer pop_addAnimation:up forKey:@"position"];
    
    
    
}
-(void)stopBounce{
    _stopBouncing = YES;
    [_zoomContainer.layer pop_removeAnimationForKey:@"position"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.blurContainer = [[MMNT_BlurContainer alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:self.blurContainer atIndex:0];
    
    // add offscreen trash view
    self.trashView = [[MMNT_TrashView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-35, SCREEN_HEIGHT, 70,70)];
    [self.view addSubview:self.trashView];

    
    [self.carouselView registerClass:[MMNT_ZoomCell class] forCellWithReuseIdentifier:@"zoomCell"];
    // Configure layout
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.flowLayout setMinimumInteritemSpacing:0.0f];
    [self.flowLayout setMinimumLineSpacing:0.0f];
    [self.flowLayout setItemSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width)];
    
    [self.carouselView setCollectionViewLayout:self.flowLayout];
    self.carouselView.bounces = YES;
    [self.carouselView setShowsHorizontalScrollIndicator:NO];
    [self.carouselView setShowsVerticalScrollIndicator:NO];
    [self.carouselView setPagingEnabled:YES];
    
    [UIView transitionFromView:self.mapContainer toView:self.carouselView duration:0.0f options:UIViewAnimationOptionTransitionFlipFromRight completion:NULL];
    self.onMap = NO;
    self.onMap = NO;
    [self.view setUserInteractionEnabled:YES];
    self.mapView.showsUserLocation=YES;
    
    
    self.on = NO;
    self.blurred = YES;
    self.trashOpen = NO;
    self.width = self.view.frame.size.width;
    
    self.toShare = [[NSMutableArray alloc] init];
    self.shouldUpdateMmntId = NO;
    
    [self initGestures];
    
    // tint check image
    UIImage *checkImg = _checkImg.image;
    _checkImg.image = [self tintImage:checkImg WithColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    
    // position help prompts
    self.swipeUpPrompt.layer.transform =  CATransform3DMakeTranslation(0, -100, 0);
    self.swipeUpPrompt.backgroundColor = [UIColor clearColor];
    self.pullDownPrompt.layer.transform =  CATransform3DMakeTranslation(0, 100, 0);
    self.pullDownPrompt.backgroundColor = [UIColor clearColor];
    
    // CUSTOM ICON
    _customIcon.layer.cornerRadius = _customIcon.frame.size.width/2;
    _customIcon.clipsToBounds = YES;
    _customIcon.frame = CGRectMake(0,0,80,80);
    _customIconImage.frame = CGRectMake(20,20,40,40);
    _customIconImage.alpha = 0.0f;
    _customIcon.hidden = YES;
    
    // custom icon outline
    int radius = _customIcon.frame.size.width/2 -5;
    _outline = [CAShapeLayer layer];
    // Make a circular shape
    _outline.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius) cornerRadius:radius].CGPath;
    // Center the shape in self.view
    _outline.position = CGPointMake(CGRectGetMidX(_customIcon.frame)-radius, CGRectGetMidY(_customIcon.frame)-radius);
    // Configure the apperence of the circle
    _outline.fillColor = [UIColor clearColor].CGColor;
    _outline.strokeColor = [UIColor colorWithRed:248.0/255.0 green:139.0/255.0 blue:0.0 alpha:1.0].CGColor; //orange
    _outline.lineWidth = 3;
    _outline.strokeStart = 0.0;
    _outline.strokeEnd = 0.0;

    
    [_customIcon.layer addSublayer:_outline];
    
    // SOCIAL ICON
//    [_sourceIcon addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
    
    // FOLLOW
    [_followIcon addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown];
    [_followIcon setImage:[UIImage imageNamed:@"followPlace"] forState:UIControlStateHighlighted];
    
    
    
}

-(void)fetchPile{
    // get photos in pile - using core data
    self.toShare = [[NSMutableArray alloc] init];
    
    MMNTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"PilePhoto" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSManagedObject *matches = nil;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    if ([objects count] == 0)
    {
        NSLog(@"No matches");
    }
    else
    {
        for (int i = 0; i < [objects count]; i++)
        {
            matches = objects[i];
//            [self.name addObject:[matches valueForKey:@"name"]];
//            [self.phone addObject:[matches valueForKey:@"phone"]];
        }
    }

}

- (UIImage *)tintImage:(UIImage *)image WithColor:(UIColor *)tintColor
{
    // It's important to pass in 0.0f to this function to draw the image to the scale of the screen
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

-(void)setUpWithCell:(UICollectionViewCell *)cell atIndex:(NSInteger)idx{
    [Amplitude logEvent:@"went to zoomin"];
    // set frame
    self.zoomContainer.transform = self.returnScale;
    self.zoomContainer.center = self.startCenter;
    
    [self.carouselView setContentOffset:CGPointMake(idx*320,0)];
    self.currentIdx = idx-1;
    
    // update map
    MMNTPhoto *photo = self.momunt[idx];
    _currentPhoto = photo;
    [self updateMapWithLatitude:[[[photo valueForKey:@"location"] valueForKey:@"latitude"] floatValue]
                   andLongitude:[[[photo valueForKey:@"location"] valueForKey:@"longitude"] floatValue]
     ];
    
    [self setUpMapIcons];


}

/*
    Set up Map instagram/twitter/follow icons
 */
-(void)setUpMapIcons{
    // reset follow icon
    [_followIcon setImage:[UIImage imageNamed:@"followPlace"] forState:UIControlStateNormal];
    [_followIcon setImage:[UIImage imageNamed:@"followPlace"] forState:UIControlStateHighlighted];
    _following = NO;
    
    //check that source key exists!
    if(!_currentPhoto.source || _currentPhoto==NULL || ![_currentPhoto.source respondsToSelector:@selector(isEqualToString:)]){
        _sourceIcon.hidden = YES;
        return;
    }
    // set source icon
    if([_currentPhoto.source isEqualToString:@"momunt"]){
        _sourceIcon.hidden = YES;
    }else{
        UIImage *icon = [UIImage imageNamed:[_currentPhoto.source isEqualToString:@"twitter"] ? @"twitterMap" : @"instagramMap" ];
        [_sourceIcon setImage:icon forState:UIControlStateNormal];
        [_sourceIcon setImage:icon forState:UIControlStateHighlighted];
        _sourceIcon.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _sourceIcon.hidden = NO;
    }

}


-(void)clickedGallery:(MMNTViewController *)fromVC cell:(UICollectionViewCell *)cell cellId:(NSInteger)idx withSelectedPhotos:(NSMutableArray *)photos{
    self.mainController = fromVC;
    self.animating = YES;

    [self setSharedPhotos:photos];
    
    self.currentIdx = idx;
    // setup and start animation
    self.startCenter = CGPointMake(cell.center.x, fromVC.galleryTopOffset+cell.center.y-fromVC.currentOffsetY);
//    self.startScale = CATransform3DMakeScale(cell.frame.size.width/SCREEN_WIDTH, cell.frame.size.width/SCREEN_WIDTH,1);
    self.returnScale = CGAffineTransformMakeScale(cell.frame.size.width/SCREEN_WIDTH, cell.frame.size.width/SCREEN_WIDTH);

    [self setUpWithCell:(UICollectionViewCell *)cell atIndex:(idx+1)];
    
    // blur
//    [fromVC captureBlurWithRadius:0 time:0];
//
    self.blurContainer.alpha = 1.0f;
    self.blurContainer.imageView.alpha = 1.0f;
    self.blurContainer.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    dispatch_async(dispatch_get_main_queue(), ^{
        [fromVC captureBlurToImageView:self.blurContainer.imageView];
    });
    
    fromVC.blurContainer.alpha = 0.0f;
    fromVC.blurContainer.bounds = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);

 
    //animate!
    [self transitionFromVC:fromVC];
    
}

-(void)transitionFromVC:(MMNTViewController *)fromVC{
    
    [self setNeedsStatusBarAppearanceUpdate];
    CGPoint targetPoint = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    
    POPSpringAnimation *center = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    center.toValue = [NSValue valueWithCGPoint:targetPoint];
    center.springBounciness = 3;
    center.springSpeed = 20;
//    center.velocity = [NSValue valueWithCGPoint:CGPointMake(100,100)];
    
    
    POPSpringAnimation *transform = [POPSpringAnimation  animationWithPropertyNamed:kPOPViewScaleXY];
    transform.toValue = [NSValue valueWithCGPoint:CGPointMake(1,1)];
    transform.springBounciness = 12;
    transform.springSpeed = 20;
    transform.velocity = [NSValue valueWithCGPoint:CGPointMake(20,20)];
    
    // (if came back from pinch/rotate gesture)
    POPSpringAnimation *rotation = [POPSpringAnimation  animationWithPropertyNamed:kPOPLayerRotation];
    rotation.toValue = @(0); //[NSValue valueWithCGPoint:CGPointMake(1,1)];
    rotation.springBounciness = 3;
    rotation.springSpeed = 20;
//    rotation.velocity = [NSValue valueWithCGPoint:CGPointMake(20,20)];
    POPSpringAnimation *position = [POPSpringAnimation  animationWithPropertyNamed:kPOPLayerTranslationXY];
    position.toValue = [NSValue valueWithCGPoint:CGPointMake(0,0)];
    position.springBounciness = 3;
    position.springSpeed = 20;

    
    
    [self.zoomContainer pop_addAnimation:transform forKey:@"scale"];
    [self.zoomContainer.layer pop_addAnimation:rotation forKey:@"rotation"];
    [self.zoomContainer.layer pop_addAnimation:position forKey:@"position"];
    [self.zoomContainer pop_addAnimation:center forKey:@"center"];
    
    //blur container
    POPBasicAnimation *fade = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fade.toValue =  @(1.0);
    fade.duration = 0.3;
    fade.completionBlock = ^(POPAnimation *animation, BOOL finished){
        self.animating = NO;
    };
    [self.blurContainer pop_addAnimation:fade forKey:@"fade"];
    
    // slideup topbar
    POPBasicAnimation *slide = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
    slide.toValue = [NSValue valueWithCGPoint:CGPointMake(0,-80)];
    slide.duration = 0.3;
    [self.fakeLogoBar.layer pop_addAnimation:slide forKey:@"slide"];
    
    self.blurred = YES;
    
    
    if(![[MMNTAccountManager sharedInstance] isTaskDone:6] ){ // swipe up to start a pile
        POPSpringAnimation *slideDown = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
        slideDown.toValue = [NSValue valueWithCGPoint:CGPointMake(0,0)];
        slideDown.springBounciness = 10;
        slideDown.springSpeed = 10;
        [self.swipeUpPrompt.layer pop_addAnimation:slideDown forKey:@"position"];
    }

    if(![[MMNTAccountManager sharedInstance] isTaskDone:5] ){ // pull down to delete
        POPSpringAnimation *slideUp = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
        slideUp.toValue = [NSValue valueWithCGPoint:CGPointMake(0,0)];
        slideUp.springBounciness = 10;
        slideUp.springSpeed = 10;
        [self.pullDownPrompt.layer pop_addAnimation:slideUp forKey:@"position"];
    }

    


}
-(void) dismiss{
//    [Amplitude logEvent:@"went to gallery"];
    
//    [self.zoomContainer.layer pop_removeAllAnimations];
    [self.zoomContainer pop_removeAllAnimations];
    [self.mainController.blurContainer pop_removeAllAnimations];
    [self.mainController.dropDownView pop_removeAllAnimations];
    
    //unblur container
    POPBasicAnimation *fade = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fade.toValue =  @(0.0);
    [self.blurContainer pop_addAnimation:fade forKey:@"fade"];
    
    // slidedown topbar
    if(!_loadingCustomMomunt){
        POPBasicAnimation *slide = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
        slide.toValue = [NSValue valueWithCGPoint:CGPointMake(0,0)];
        [self.fakeLogoBar.layer pop_addAnimation:slide forKey:@"slide"];
    }
    
    // SETUP for Dismiss
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIdx inSection:0];
    UICollectionViewCell *currCell = [self.mainController.collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
    self.startCenter = CGPointMake(currCell.center.x, self.mainController.galleryTopOffset+currCell.center.y+(_mainController.reloading ? -self.mainController.currentOffsetY+20:-self.mainController.currentOffsetY) );
    float delay = 0;
    if(currCell.center.y < self.mainController.currentOffsetY || currCell.center.y > self.mainController.currentOffsetY+self.mainController.view.frame.size.height-70){
        // scroll to correct position
        CGFloat y;
        CGFloat h = self.mainController.collectionView.frame.size.height;
        CGFloat maxH = ceilf(self.mainController.momunt.count/3) * currCell.frame.size.height;
        if(currCell.center.y < h/2){
            y = 0;
        }else if(currCell.center.y > maxH-h/2){
            y = maxH-h;
        }else{
            y = currCell.center.y - h/2;
        }
        [self.mainController.collectionView scrollRectToVisible:CGRectMake(0, y, self.mainController.view.frame.size.width, h) animated:YES];
        
        // MOVE Zoomed square back to center
        // In case it was swiped down
        POPBasicAnimation *goback = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
        goback.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
        goback.duration = 0.5;
        [self.zoomContainer pop_addAnimation:goback forKey:@"goback"];
        
        
        self.startCenter = CGPointMake(currCell.center.x, self.mainController.galleryTopOffset+currCell.center.y-y);
        delay = delay+0.5;
    }
    if(self.onMap){
        [self toggleMapView];
        delay = delay>=0.5 ? delay : delay+0.5;
    }
    
    _doneCentering = NO;
    _doneScaling = NO;
    
    POPSpringAnimation *center = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    center.toValue = [NSValue valueWithCGPoint:self.startCenter];
    center.springBounciness = 3;
    center.springSpeed = 20;
    center.beginTime = (CACurrentMediaTime() + delay);
    center.completionBlock = ^(POPAnimation *animation, BOOL finished){
        _doneCentering = YES;
        if(_doneScaling && _doneCentering){
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    };

    
    POPSpringAnimation *transform = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    transform.toValue = [NSValue valueWithCGPoint:CGPointMake(self.returnScale.a,self.returnScale.d)];
    transform.springBounciness = 15; // if change this to 5 - less bounce but transition ends faster and you can click on the next image sooner
    transform.springSpeed = 20;
    transform.beginTime = (CACurrentMediaTime() + delay);
    transform.completionBlock = ^(POPAnimation *animation, BOOL finished){
        _doneScaling = YES;
        if(_doneScaling && _doneCentering){
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    };
    
    [self.zoomContainer.layer pop_addAnimation:transform forKey:@"scale"];
    [self.zoomContainer pop_addAnimation:center forKey:@"center"];


    POPSpringAnimation *slideDown = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
    slideDown.toValue = [NSValue valueWithCGPoint:CGPointMake(0,-100)];
    slideDown.springBounciness = 10;
    slideDown.springSpeed = 10;
    [self.swipeUpPrompt.layer pop_addAnimation:slideDown forKey:@"position"];
    
    
    POPSpringAnimation *slideUp = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
    slideUp.toValue = [NSValue valueWithCGPoint:CGPointMake(0,100)];
    slideUp.springBounciness = 10;
    slideUp.springSpeed = 10;
    [self.pullDownPrompt.layer pop_addAnimation:slideUp forKey:@"position"];
    
    [self stopBounce];
}


-(void)didSwipe:(UIPanGestureRecognizer *)recognizer{
    // stop bounceAnimation
    if(!_stopBouncing)
    {
        [self stopBounce];
    }
    
    //Get point and velocity
    CGFloat threshold = 0.20*SCREEN_HEIGHT;
    CGFloat sub_threshold = 0.09*SCREEN_HEIGHT;
    CGFloat trashThreshold = 0.3*SCREEN_HEIGHT;
    CGPoint point = [recognizer translationInView:self.view];
    CGFloat percent = ABS(point.y)/threshold;
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if(recognizer.numberOfTouches>=2 || self.pinching){
        // USER IS PINCH ZOOMING. LET THEM PLAY :)
        CGFloat newX = self.view.center.x+point.x;
        CGFloat posX = MIN( MAX(self.zoomContainer.frame.size.width/2, newX) , SCREEN_WIDTH - self.zoomContainer.frame.size.width/2 );
        if(self.zoomContainer.frame.size.width > SCREEN_WIDTH){
            posX = newX;
        }
        
        self.zoomContainer.center = CGPointMake(posX, self.view.center.y + point.y);
        self.pinching = YES;
        
    }else{
//        [self.zoomContainer pop_removeAllAnimations];
        
//        CGFloat scale = MAX(1-(1-self.returnScale.a)*percent, self.returnScale.a);
//        CGFloat scale = MAX(1-(1-self.returnScale.a)*percent, 0.3);
        CGFloat scale = MAX(1-0.7*percent, 0.3);
        [self.zoomContainer setTransform:CGAffineTransformMakeScale(scale,scale)];
    
        CGFloat newX = self.view.center.x+point.x;
        CGFloat posX = MIN( MAX(self.zoomContainer.frame.size.width/2, newX) , SCREEN_WIDTH - self.zoomContainer.frame.size.width/2 );
        self.zoomContainer.center = CGPointMake(posX, self.view.center.y + point.y);

    
        if(point.y > 0){ // Swipe down
            // update blur and top bar
            if((point.y > sub_threshold && self.blurred) || (point.y<=sub_threshold && !self.blurred)){
                [self toggleBlur];
            }
            if( (point.y > trashThreshold && !self.trashOpen && ABS(velocity.y)<1000) || (point.y <= trashThreshold && self.trashOpen)){
                [self toggleTrash];
            }

        }else if(point.y < 0){
            if(ABS(point.y) > 50 && self.shareBar.frame.origin.y < 0){
                // slide bar down
                [UIView animateWithDuration:0.3 animations:^{
                    self.shareBar.transform = CGAffineTransformMakeTranslation(0, self.shareBar.frame.size.height);
                }];
                
            }else if(ABS(point.y) < 50 && self.shareBar.frame.origin.y > -self.shareBar.frame.size.height && velocity.y>0 && self.toShare.count<1){
                // slide bar up
                [UIView animateWithDuration:0.3 animations:^{
                    self.shareBar.transform = CGAffineTransformIdentity;
                }];
            }
        }
    }
    
    //
    // FINGER LIFT OFF...
    //
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if(self.pinching || (ABS(point.y)<threshold && ABS(velocity.y)<1000)){ // if swiped hard -> dissmiss view even if did not pass threshold
            // Return zoomContainer to Center of Screen
            self.pinching = NO;
            [self transitionFromVC:self.mainController];
            // slide bar up
            if(self.toShare.count<1){
                [UIView animateWithDuration:0.3 animations:^{self.shareBar.transform = CGAffineTransformIdentity;}];
            }
        }else{
            if(point.y>0 && (point.y < trashThreshold || ABS(velocity.y)>700) ){
                // swiped down -> close zoom view
                [self dismiss];
            }else if(point.y>0 && point.y >= trashThreshold && ABS(velocity.y)<1000){
                // trash this image!
                POPBasicAnimation *fall = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
                fall.toValue = [NSValue valueWithCGPoint:CGPointMake(self.zoomContainer.center.x, 800)];
                fall.duration = 0.3;
                [self.zoomContainer pop_addAnimation:fall forKey:@"fall"];

                
                // Scroll collection view underneath if needed
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIdx inSection:0];
                UICollectionViewCell *currCell = [self.mainController.collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
                
                float delay = 0;
                if(currCell.center.y < self.mainController.currentOffsetY || currCell.center.y > self.mainController.currentOffsetY+self.mainController.view.frame.size.height-70){
                    // scroll to correct position
                    CGFloat y;
                    CGFloat h = self.mainController.collectionView.frame.size.height;
                    CGFloat maxH = ceilf(self.mainController.momunt.count/3) * currCell.frame.size.height;
                    if(currCell.center.y < h/2){
                        y = 0;
                    }else if(currCell.center.y > maxH-h/2){
                        y = maxH-h;
                    }else{
                        y = currCell.center.y - h/2;
                    }
                    [self.mainController.collectionView scrollRectToVisible:CGRectMake(0, y, self.mainController.view.frame.size.width, h) animated:YES];
                    
                    delay = delay+0.5;
                }
                
                
                
                [MMNT_SharedVars runPOPSpringAnimation:kPOPViewCenter
                                                onView:self.trashView
                                               toValue:[NSValue valueWithCGPoint:CGPointMake(_trashView.center.x, _trashView.center.y+120)]
                                      springBounciness:10
                                           springSpeed:10
                                                 delay:0
                                                forKey:@"center"
                                            completion:^(BOOL finished) {
                                                self.trashView.hidden = YES;
                                                [self.mainController removedImageAtIndex:self.currentIdx];
                                                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                            }];

                
                
            }
            else{
                if(self.shareBar.frame.origin.y < 0){
                    [Amplitude logEvent:@"started pile"];
                    
                    // slide bar down
                    [UIView animateWithDuration:0.3 animations:^{
                        self.shareBar.transform = CGAffineTransformMakeTranslation(0, self.shareBar.frame.size.height);
                    }];
                    
                    
                }
                
                // hide swipe up prompt, mark as done
                [[MMNTDataController sharedInstance] setTaskDone:6];
                [UIView animateWithDuration:0.3 animations:^{
                    self.swipeUpPrompt.alpha = 0;
                }];
                
                //check if this img is already selected
//                NSString *thisUrl = [[[_momunt[self.currentIdx+1] valueForKey:@"images"] valueForKey:@"thumbnail"] valueForKey:@"url"];
                MMNTPhoto *thisPhoto = _momunt[self.currentIdx+1];
                BOOL exists = [self array:self.toShare containsPhotoWithId:thisPhoto.id];
                if(exists){
                    // fall back down
                    [self transitionFromVC:self.mainController];
                    
                }else{
                
                    self.shouldUpdateMmntId = YES;
                    
                // swiped up -> share
                CGFloat angle = lroundf((self.toShare.count+1)/2)*5*(self.toShare.count % 2 ? -1 : 1);
//                NSLog(@"%f", angle);
                
                CGAffineTransform t = CGAffineTransformMakeScale(50/SCREEN_WIDTH, 50/SCREEN_WIDTH);
                CGAffineTransform tr = CGAffineTransformRotate(t, angle);
                // 1) Finish animating container to land in the top bar
                [UIView animateWithDuration:0.3 animations:^{
                    self.zoomContainer.center = CGPointMake(SCREEN_WIDTH/2, self.shareBar.frame.size.height/2 );
                    self.zoomContainer.transform = tr;
                } completion:^(BOOL finished) {
                    // 2) Place UImage on top of dropped container

                    MMNTPhoto *photo = _momunt[self.currentIdx+1];
                    NSString *url = [[[photo valueForKey:@"images"] valueForKey:@"thumbnail"] valueForKey:@"url"];
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
                    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
                    imgView.frame = CGRectMake(0,0,50,50);
                    imgView.center = CGPointMake(SCREEN_WIDTH/2, self.shareBar.frame.size.height/2);
                    imgView.transform = CGAffineTransformMakeRotation(angle);
                    [self.sharedPicsContainer addSubview:imgView];
                    
                    [self.toShare addObject:photo];
                    
                    // Store pile info
                    [[NSUserDefaults standardUserDefaults] setObject: [MMNTObj photoArrayToString:self.toShare] forKey:@"userPile"];

                    // 3) Silently move container off screen
                    self.zoomContainer.transform = CGAffineTransformIdentity;
                    self.zoomContainer.center = CGPointMake(SCREEN_WIDTH*1.5, SCREEN_HEIGHT/2);
                    // 4) Flip to next image
                    [self advanceToIdx:self.currentIdx+1];
//                    self.currentIdx = self.currentIdx + 1;
//                    [self.carouselView setContentOffset:CGPointMake((self.currentIdx+1)*320,0)];
                    // 5) Animate zoomContainer into center from right
                    [UIView animateWithDuration:0.3 animations:^{
                        self.zoomContainer.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 );
                    }];
                }];
                }
                
            }
        }
    }
//    [recognizer setTranslation:CGPointZero inView:self.superview];
    
//    CGPoint location = [recognizer locationInView:self.superview];
}

-(BOOL)array:(NSMutableArray *)array containsPhotoWithId:(NSString *)uid{
    for(int i = 0; i < array.count; i++) {
        MMNTPhoto *photo = array[i];
        if([photo.id isEqualToString:uid])
            return YES;
    }
    return NO;
}

-(void)toggleBlur{
    self.blurred = !self.blurred;
    
//    [self.view sendSubviewToBack:self.blurContainer];
//    [self.view sendSubviewToBack:self.trashView];
    
    self.blurContainer.layer.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.blurContainer.layer.position = CGPointMake(0, 0);
    self.blurContainer.layer.cornerRadius = 0;
    self.blurContainer.alpha = self.blurred ? 0.0 : 1.0;
    
    [self.blurContainer pop_removeAllAnimations];
    [self.mainController.dropDownView pop_removeAllAnimations];
     
    //unblur container
    POPBasicAnimation *fade = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fade.toValue =  self.blurred ? @(1.0) : @(0.0);
    [self.blurContainer pop_addAnimation:fade forKey:@"fade"];
    
    // slidedown topbar
    POPBasicAnimation *slide = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
    slide.toValue = self.blurred ? [NSValue valueWithCGPoint:CGPointMake(0,-self.fakeLogoBar.frame.size.height)] : [NSValue valueWithCGPoint:CGPointMake(0,0)];
//    [self.mainController.dropDownView.layer pop_addAnimation:slide forKey:@"slide"];
    [self.fakeLogoBar.layer pop_addAnimation:slide forKey:@"slide"];
    
}

-(void)toggleTrash{
    self.trashOpen = !self.trashOpen;
    
    if(self.trashOpen){
        self.trashView.trashX.transform = CGAffineTransformMakeScale(0.001,0.001);
        self.trashView.trashUndo.transform = CGAffineTransformMakeScale(0.001,0.001);
        
        // hide delete prompt, set task as done
        [[MMNTDataController sharedInstance] setTaskDone:5];
        [UIView animateWithDuration:0.3 animations:^{
            self.pullDownPrompt.alpha = 0;
        }];
    }
    
    // slide trash view
    POPBasicAnimation *slide = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
    slide.toValue = self.trashOpen ? [NSValue valueWithCGPoint:CGPointMake(0,-(self.trashView.frame.size.height+20))] : [NSValue valueWithCGPoint:CGPointMake(0,0)];
    [self.trashView.layer pop_addAnimation:slide forKey:@"slide"];

    
    POPSpringAnimation *scaleX = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleX.toValue = [NSValue valueWithCGPoint: CGPointMake(1, 1)] ;
    scaleX.springBounciness = 10;
    scaleX.springSpeed = 15;
    scaleX.beginTime = (CACurrentMediaTime() + 0.05);
    [self.trashView.trashX pop_addAnimation:scaleX forKey:@"scale"];

}

-(void)setSharedPhotos:(NSArray *)photos{
    if(photos.count==0){
        return;
    }
    
    self.shareBar.transform = CGAffineTransformMakeTranslation(0, self.shareBar.frame.size.height);
    [photos enumerateObjectsUsingBlock:^(MMNTPhoto *obj, NSUInteger idx, BOOL *stop) {
        NSString *url = [[[obj valueForKey:@"images"] valueForKey:@"thumbnail"] valueForKey:@"url"];
        CGFloat angle = lroundf((self.toShare.count+1)/2)*5*(self.toShare.count % 2 ? -1 : 1);
        
        AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0,0,50,50)];
        imageView.center = CGPointMake(SCREEN_WIDTH/2, self.shareBar.frame.size.height/2);
        imageView.transform = CGAffineTransformMakeRotation(angle);
        [self.sharedPicsContainer addSubview:imageView];
        
        imageView.imageURL = [NSURL URLWithString:url];
        
        [self.toShare addObject:obj];
    }];
}
-(void) viewDidAppear:(BOOL)animated{
    self.mapView.showsUserLocation=YES;
//    [self zoomToFitMapAnnotations:self.mapView];
}

-(void)initGestures{
    // Initialize touch response
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(onDoubleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self.zoomContainer addGestureRecognizer:singleTapGestureRecognizer];
    
    // drag gesture
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    [self.zoomContainer addGestureRecognizer:recognizer];
    
    // Pinch
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.zoomContainer addGestureRecognizer:pinch];
    
    // Rotate
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
    rotate.delegate = self;
    [self.zoomContainer addGestureRecognizer:rotate];
    
    // long press gesture
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.3;
    [self.mapView addGestureRecognizer:lpgr];
    
//    // set up a two-finger pan recognizer as a dummy to steal two-finger scrolls from the scroll view
//    // we initialize without a target or action because we don't want the two-finger pan to be handled
    UIPanGestureRecognizer *twoFingerPan = [[UIPanGestureRecognizer alloc] init];
    twoFingerPan.minimumNumberOfTouches = 2;
    twoFingerPan.maximumNumberOfTouches = 2;
    [self.carouselView addGestureRecognizer:twoFingerPan];
    [twoFingerPan requireGestureRecognizerToFail:pinch];
    [twoFingerPan requireGestureRecognizerToFail:rotate];
    
    
    
    [self.carouselView.panGestureRecognizer setMinimumNumberOfTouches:1];
    [self.carouselView.panGestureRecognizer setMaximumNumberOfTouches:1];
    
}


- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    _touchCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _customIcon.center = CGPointMake(touchPoint.x, touchPoint.y+_zoomContainer.frame.origin.y);
        _customIcon.hidden = NO;
        
        _pressDuration = 0;
        _pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(incrementPressDuration) userInfo:nil repeats:YES];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        [_pressTimer invalidate];
        
//        if(_loadingCustomMomunt){
//            [Amplitude logEvent:@"map longpress"];
//            [[MMNTDataController sharedInstance] fetchMomuntAtCoordinate:_touchCoordinate andTime:[NSDate date] source:@"travel"];
//        }
        
        [UIView animateWithDuration:0.3
                              delay:_loadingCustomMomunt ? 0.5 : 0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             _customIcon.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             _customIcon.hidden = YES;
                             _customIcon.alpha = 1.1f;
                             _outline.strokeEnd = 0.0;
                             
//                             if(_loadingCustomMomunt){
//                                 [_mainController setRefreshing];
//                                 _mainController.loadedStoredMomunt = NO;
//                                 [self dismiss];
//                             }
                             

                         }];
        
        
        
//        [UIView animateWithDuration:0.3 animations:^{
//            _customIcon.alpha = 0.0f;
//        } completion:^(BOOL finished) {
//            _customIcon.hidden = YES;
//            _customIcon.alpha = 1.1f;
//            _outline.strokeEnd = 0.0;
//        }];

    }
}

- (void)incrementPressDuration {
    if(_pressDuration>=1){
        [self setHelpTaskDone];
        
        [_pressTimer invalidate];
        [UIView animateWithDuration:0.3 animations:^{_customIconImage.alpha = 1.0f;}];

        // go straight to loading custom momunt
        _loadingCustomMomunt = YES;
        
//        if(_loadingCustomMomunt){
            [Amplitude logEvent:@"map longpress"];
            [[MMNTDataController sharedInstance] fetchMomuntAtCoordinate:_touchCoordinate andTime:[NSDate date] source:@"travel"];
//        }
        
        [UIView animateWithDuration:0.3
                              delay:_loadingCustomMomunt ? 0.5 : 0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             _customIcon.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             _customIcon.hidden = YES;
                             _customIcon.alpha = 1.1f;
                             _outline.strokeEnd = 0.0;
                             
                             if(_loadingCustomMomunt){
                                 [_mainController setRefreshing];
                                 _mainController.loadedStoredMomunt = NO;
                                 [self dismiss];
                             }
                             
                         }];


        
        


    }else{
        _pressDuration = _pressDuration + 0.1;
        _outline.strokeEnd = _pressDuration/1;
//        NSLog(@"pressed for: %f secs", _pressDuration);
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100){
        // follow this location.
        if(buttonIndex==1){
            [self followThisLocation];
        }
        return;
    }
    
//     MAP TRAVEL ALERT.
//    [UIView animateWithDuration:0.3 animations:^{
//        _customIcon.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        _customIcon.hidden = YES;
//        _customIcon.alpha = 1.1f;
//        _outline.strokeEnd = 0.0;
//    }];
//    
//    if(buttonIndex==1)
//    {
//        _loadingCustomMomunt = YES;
//        [_mainController setRefreshing];
//        _mainController.loadedStoredMomunt = NO;
//        [[MMNTDataController sharedInstance] fetchMomuntAtCoordinate:_touchCoordinate andTime:[NSDate date] source:@"travel"];
//        [self dismiss];
//        
//    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    NSLog(@"%@",gestureRecognizer.class);
    if([[NSString stringWithFormat:@"%@",[gestureRecognizer class]] isEqualToString:@"UIScrollViewPanGestureRecognizer"] && gestureRecognizer.numberOfTouches>1){
        return NO; // but this never happens because this is not UIScrollViewPanGestureRecognizer's delegate
    }else{
        return YES;
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if([[NSString stringWithFormat:@"%@",[otherGestureRecognizer class]] isEqualToString:@"UIScrollViewPanGestureRecognizer"]){
        return NO;
    }else{
        return YES;
    }
}


/*
 handlePinch
 Handle two finger pinch gesture on the zoomContainer
 */
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer{
    if(self.onMap){
        return;
    }
//    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
//    recognizer.scale = 1;
    
    CGPoint anchor = [recognizer locationInView:recognizer.view];
    anchor = CGPointMake(anchor.x - recognizer.view.bounds.size.width/2, anchor.y-recognizer.view.bounds.size.height/2);
    
    CGAffineTransform affineMatrix = recognizer.view.transform;
    affineMatrix = CGAffineTransformTranslate(affineMatrix, anchor.x, anchor.y);
    affineMatrix = CGAffineTransformScale(affineMatrix, [recognizer scale], [recognizer scale]);
    affineMatrix = CGAffineTransformTranslate(affineMatrix, -anchor.x, -anchor.y);
    recognizer.view.transform = affineMatrix;
    
    recognizer.scale = 1;

    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self transitionFromVC:self.mainController];
    }
}
/*
 handleRotate
 Handle two finger rotation gesture on the zoomContainer
 */
- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer{
    if(self.onMap){
        return;
    }
    
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self transitionFromVC:self.mainController];
    }
}
///*
//    handleLongPress
//    Save image to iphone gallery on long press
// */
//-(void)handleLongPress:(UILongPressGestureRecognizer *)recognizer{
//    if (recognizer.state != UIGestureRecognizerStateBegan){
//        return;
//    }
//    // get current image
//    if(!self.currentIdx)
//        self.currentIdx = 0;
//    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:(self.currentIdx+3) inSection:0];
//    UICollectionViewCell *currCell = [self.carouselView dequeueReusableCellWithReuseIdentifier:@"zoomCell" forIndexPath:indexpath];
////    UIImageView *imageView = [currCell.subviews objectAtIndex:0];
//    UIImageView *imageView1 = [currCell.subviews objectAtIndex:1]; // why index==1??? not sure. at index==0 there is a UIView
//    UIImage *image = imageView1.image;
//    
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//}

-(void)setData:(NSArray *)array {
    
    // Grab references to the first and last items
    // They're typed as id so you don't need to worry about what kind
    // of objects the originalArray is holding
    id firstItem = array[0];
    id lastItem = [array lastObject];
    
    NSMutableArray *workingArray = [array mutableCopy];
    
    // Add the copy of the last item to the beginning
    [workingArray insertObject:lastItem atIndex:0];
    
    // Add the copy of the first item to the end
    [workingArray addObject:firstItem];
    
    // Update the collection view's data source property
    NSMutableArray *new = [NSMutableArray arrayWithArray:workingArray];
    
    self.momunt = new;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tap Handlers on Map View
- (void)onDoubleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint p = [recognizer locationInView:_mapView];
    UIView *v = [_mapView hitTest:p withEvent:nil];
    
    if(!(self.onMap && [v isKindOfClass:NSClassFromString(@"MKAnnotationView")])){
        // if didn't tap pin - close map view
        [self toggleMapView];
    }
}

-(void)toggleMapView{
    if(self.animating){
        return;
    }
    if(self.onMap){
        [UIView transitionFromView:self.mapContainer toView:self.carouselView duration:0.5f options:UIViewAnimationOptionTransitionFlipFromRight completion:NULL];
        self.onMap = NO;
        [self setHelpTaskDone];
    }else{
        [Amplitude logEvent:@"went to map"];
        [[MMNTDataController sharedInstance] setTaskDone:108];
        [self setHelpTaskDone];
        
        [UIView transitionFromView:self.carouselView toView:self.mapContainer duration:0.5f options:UIViewAnimationOptionTransitionFlipFromLeft completion:NULL];
        self.onMap = YES;
        
        if(_tipPresented){
            [self setHelpTaskDone];
        }
        
        if(![[MMNTAccountManager sharedInstance] isTaskDone:107]){
            _helpTaskVC = [[MMNT_HelpTasksController alloc] init];
            _helpTaskVC.delegate = self;
            _helpTaskVC.helpText = @"Use map to travel. Hold your finger down.";
            _helpTaskVC.position = @"top";
            _helpTaskVC.taskType = @"tip";
            _helpTaskVC.taskId = 107;
            _helpTaskVC.passArea = CGRectMake(0,80,SCREEN_WIDTH, SCREEN_HEIGHT-80);
            CGImageRef imageRef = CGImageCreateWithImageInRect([_blurContainer.imageView.image CGImage], CGRectMake(0, _blurContainer.imageView.image.size.height*0.85, _blurContainer.imageView.image.size.width, _blurContainer.imageView.image.size.height*0.15));
            _helpTaskVC.blurImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            _helpTaskVC.parentVC = self;
            // present modal controller
            [_helpTaskVC performSelector:@selector(show) withObject:nil afterDelay:1.0];
            _tipPresented = YES;
            _currTipId = 107;
            
//            [_helpTaskVC show];
            
        }

    }
}
-(void)showMapTip{
    if(![[MMNTAccountManager sharedInstance] isTaskDone:108]){
        _helpTaskVC = [[MMNT_HelpTasksController alloc] init];
        _helpTaskVC.delegate = self;
        _helpTaskVC.helpText = @"Tap the photo to see the map. Use it to look at other momunts around the world.";
        _helpTaskVC.position = @"top";
        _helpTaskVC.taskType = @"tip";
        _helpTaskVC.taskId = 108;
        _helpTaskVC.passArea = CGRectMake(0,80,SCREEN_WIDTH, SCREEN_HEIGHT-80);
        CGImageRef imageRef = CGImageCreateWithImageInRect([_blurContainer.imageView.image CGImage], CGRectMake(0, _blurContainer.imageView.image.size.height*0.85, _blurContainer.imageView.image.size.width, _blurContainer.imageView.image.size.height*0.15));
        _helpTaskVC.blurImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        _helpTaskVC.parentVC = self;
        [_helpTaskVC show];
        _tipPresented = YES;
        _currTipId = 108;
        
    }
}

-(void)setHelpTaskDone{
    if(!_tipPresented){return;}
    
    [[MMNTDataController sharedInstance] setTaskDone:_currTipId];
    [_helpTaskVC hide];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[self.view.subviews lastObject] removeFromSuperview];
        _tipPresented = NO;
//    });
}
-(void)MMNTHelpTaskSkippedTaskWithId:(CGFloat)taskId{
//    [[MMNTDataController sharedInstance] setTaskDone:taskId];
    [self setHelpTaskDone];
}

- (void)onSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Single Tap");
}

-(void)updateMapWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lng{
    self.mapView.showsUserLocation=YES;
    
    CLLocationCoordinate2D coords;
    coords.latitude = lat;
    coords.longitude = lng;
    
    // initially - center on photo location pin
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coords, 1000, 1000);
    [self.mapView setRegion:viewRegion animated:NO];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    MMNT_MapPin *pin = [[MMNT_MapPin alloc] initWithCoordinate:coords];
    pin.type = @"mmnt_location";
    [self.mapView addAnnotation:pin];
    
//    /*TEST-----------------------------------------------------------------
//     */
//    // search for local businesses
//    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
//    request.naturalLanguageQuery = @"restaurant";
//    request.region = _mapView.region;
//    
//    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
//    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
//        
//        NSMutableArray *annotations = [NSMutableArray array];
//        
//        [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem *item, NSUInteger idx, BOOL *stop) {
//            MKPlacemark *annotation = [[MKPlacemark alloc] initWithPlacemark:item.placemark];
//
////            annotation.title = item.name;
////            annotation.subtitle = item.placemark.addressDictionary[(NSString *)kABPersonAddressStreetKey];
////            annotation.phone = item.phoneNumber;
//            [annotations addObject:annotation];
//        }];
//        
//        [self.mapView addAnnotations:annotations];
//    }];
    
}

-(void)zoomToFitMapAnnotations:(MKMapView*)aMapView
{
    if([aMapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(MKPointAnnotation *annotation in self.mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.3; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.3; // Add a little extra space on the sides
    
    region = [aMapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

// Set Annotation pin Image
-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pinView = nil;
    if ([annotation isKindOfClass:[MMNT_MapPin class]]){
    //CHECK [annotation type]
        static NSString *defaultPinID = @"com.invasivecode.pin";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        //pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = NO;
        //pinView.animatesDrop = YES;
        pinView.image = [UIImage imageNamed:@"pin"];    //as suggested by Squatch
        pinView.frame = CGRectMake(0,0, 28, 40);
        pinView.enabled = NO;
    }
//    else {
//        [mapView.userLocation setTitle:@"I am here"];
//    }
    return pinView;
}

// On Pin Tap
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
//    // if User location is not in visible map view, reposition map
//    if(!MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate(self.mapView.userLocation.coordinate)))
//    {
//        //Do stuff
//        [self zoomToFitMapAnnotations:self.mapView];
//    }
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [Amplitude logEvent:@"swiped through gallery"];
    
    CGFloat width = self.view.frame.size.width;
    
    self.currentIdx = scrollView.contentOffset.x>0 ? (scrollView.contentOffset.x/width<=_momunt.count-2 ?  (scrollView.contentOffset.x/width)-1 : 0) : _momunt.count-3;
    
    // Calculate where the collection view should be at the right-hand end item
    float contentOffsetWhenFullyScrolledRight = width * ([self.momunt count] -1);
    
    if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
        
        // user is scrolling to the right from the last item to the 'fake' item 1.
        // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        
        [self.carouselView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        
    } else if (scrollView.contentOffset.x == 0)  {
        
        // user is scrolling to the left from the first item to the fake 'item N'.
        // reposition offset to show the 'real' item N at the right end end of the collection view
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.momunt count] -2) inSection:0];
        
        [self.carouselView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        
    }
    
    // update map
    MMNTPhoto *photo = _momunt[self.currentIdx+1];
    _currentPhoto = photo;
    [self updateMapWithLatitude:[[[photo valueForKey:@"location"] valueForKey:@"latitude"] floatValue]
                   andLongitude:[[[photo valueForKey:@"location"] valueForKey:@"longitude"] floatValue]
    ];
    
    [self setUpMapIcons];
    
}

// set carousel offset to show pic with index (NSInteger)idx
-(void)advanceToIdx:(NSInteger)idx{
    if(idx==-1){
        idx = _momunt.count-2;
        
    }else if(idx>=_momunt.count-2){
        idx=0;
    }
    self.currentIdx = idx;
    [self.carouselView setContentOffset:CGPointMake((self.currentIdx+1)*320,0)];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.momunt.count;
}

/// Populate colletion views with images
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MMNT_ZoomCell *cell = (MMNT_ZoomCell *)[collectionView1 dequeueReusableCellWithReuseIdentifier:@"zoomCell" forIndexPath:indexPath];
    if(!cell.parentContainer)
        cell.parentContainer = self.zoomContainer;
    
    MMNTPhoto *photo = _momunt[indexPath.row];

//    [[AsyncImageLoader sharedLoader] loadImageWithURL:<#(NSURL *)#> target:<#(id)#> action:<#(SEL)#>
    
    if(!photo.uploading){
        
        NSString *path1;
        if(photo.source!=[NSNull null] && [photo.source isEqualToString:@"twitter"]){
            path1 = [[[photo valueForKey:@"images"] valueForKey:@"low_resolution"] valueForKey:@"url"];
        }else{
            path1 = [[[photo valueForKey:@"images"] valueForKey:@"thumbnail"] valueForKey:@"url"]; //set thumbnail
        }
        NSString *path2 = [[[photo valueForKey:@"images"] valueForKey:@"standard_resolution"] valueForKey:@"url"]; // followed by larger image

        [cell setUrl:[NSURL URLWithString:path1]];
        if([MTReachabilityManager sharedManager].haveInternet){
            [cell setUrl:[NSURL URLWithString:path2]];
        }

    }else{
        [cell setImage:photo.tempImage];
    }
    
    return cell;
    
    
}

- (void) buttonPress:(UIButton*)button {
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }];
}

- (IBAction)pressedSourceIcon:(id)sender {
    [_sourceIcon pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){};
    [_sourceIcon pop_addAnimation:a forKey:@"scale"];
    
    if([_currentPhoto.source isEqualToString:@"twitter"]){
        // link to twitter
        if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]] )
        {
            //open photo in instgaram app
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://status?id=%@", _currentPhoto.id ] ]];
        }
        else
        {
            //otherwise open web link
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:_currentPhoto.link]];
        }

        
        
    }else if([_currentPhoto.source isEqualToString:@"instagram"]){
        // link to instagram
        if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://"]] )
        {
            //open photo in instgaram app
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:[NSString stringWithFormat:@"instagram://media?id=%@", _currentPhoto.id ] ]];
        }
        else
        {
            //otherwise open web link
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:_currentPhoto.link]];
        }
    }
}

- (IBAction)pressedFollow:(id)sender {
    
    [_followIcon pop_removeAllAnimations];
    POPSpringAnimation *a = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    a.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0,1.0)];
    a.springBounciness = 15;
    a.springSpeed = 10;
    a.completionBlock = ^(POPAnimation *animation, BOOL finished){};
    [_followIcon pop_addAnimation:a forKey:@"scale"];
    
    if(_following)
        return;
    
    if(![[MMNTAccountManager sharedInstance] isTaskDone:109]){ // if first time..
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Follow this location?"
                                                        message:@"You will find it in your places tab."
                                                       delegate:self
                                              cancelButtonTitle:@"Not Now"
                                              otherButtonTitles:@"Follow!", nil];
        alert.tag = 100;
        [alert show];
        
        [[MMNTDataController sharedInstance] setTaskDone:109];

    }else{
        [self followThisLocation];
    }

}
-(void)followThisLocation{
    [Amplitude logEvent:@"followed location"];
    _following = YES;
    double lat = [[_currentPhoto.location valueForKey:@"latitude"] doubleValue];
    double lng = [[_currentPhoto.location valueForKey:@"longitude"] doubleValue];
    CLLocation *thisLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng ];
    
    [LocationController nameFromLocation:thisLocation completion:^(NSString *name) {
        // follow this place!
        NSString *momuntId = [[MMNTDataController sharedInstance] uniqueId];
        [[MMNTApiCommuniator sharedInstance] followMomunt:momuntId lat:lat lng:lng name:name];
        
    }];
    
    // reset follow icon
    [_followIcon setImage:[UIImage imageNamed:@"verifyFollower"] forState:UIControlStateNormal];
    [_followIcon setImage:[UIImage imageNamed:@"verifyFollower"] forState:UIControlStateHighlighted];
}


- (IBAction)closeBtn:(id)sender {
    [self dismiss];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if([[segue identifier] isEqualToString:@"zoomIn"] ){        
        MMNTViewController *toVC = (MMNTViewController *) segue.destinationViewController;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIdx inSection:0];
        UICollectionViewCell *currCell = [toVC.collectionView dequeueReusableCellWithReuseIdentifier:@"galleryCell" forIndexPath:indexPath];
        AsyncImageView *currImageView = (AsyncImageView *)[currCell viewWithTag:100];
        [currImageView setAlpha:0.0f];


    }
}


- (IBAction)pressedSend:(id)sender {
    [Amplitude logEvent:@"accepted pile"];
    
    MMNTDataController *mmntDataController = [MMNTDataController sharedInstance];
    
    if(![self.toShare isEqualToArray:[MMNTDataController sharedInstance].pileMomunt.body] ){
        mmntDataController.toShareMomunt.body = [NSArray arrayWithArray: self.toShare ];
        mmntDataController.toShareMomunt.momuntId = [[MMNTDataController sharedInstance] uniqueId];
        mmntDataController.toShareMomunt.timestamp = [NSDate date]; // stores when the pile was saved
        mmntDataController.toShareMomunt.ownerId = [MMNTAccountManager sharedInstance].userId;
        if(!mmntDataController.toShareMomunt.name){
            mmntDataController.toShareMomunt.name = [NSString stringWithString:mmntDataController.currentMomunt.name];
        }
        mmntDataController.toShareMomunt.lat = mmntDataController.coordinate.latitude; // where it was shared..
        mmntDataController.toShareMomunt.lng = mmntDataController.coordinate.longitude; // where it was shared..
        mmntDataController.toShareMomunt.type = @"pile";
        
        [mmntDataController.pileMomunt setEqualTo:mmntDataController.toShareMomunt];

    }else{
        [mmntDataController.toShareMomunt setEqualTo:[MMNTDataController sharedInstance].pileMomunt];
    }
    NSLog(@"Store with ID %@", mmntDataController.toShareMomunt.momuntId);
    
    
    // set poster image to first image in _momunt
    MMNTPhoto *first = [mmntDataController.toShareMomunt.body objectAtIndex:0];
    NSString *poster = [[[first valueForKey:@"images"] valueForKey:@"standard_resolution"] valueForKey:@"url"];
    mmntDataController.toShareMomunt.poster = poster;

    
    // insert SharingViews Controller
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UINavigationController *myController = (UINavigationController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"SharingViews"];
    mmntDataController.sharePile = YES;

    
    [self addChildViewController:myController];
    self.shareNavController = myController;
    
    // Scale down fromVC subviews
    myController.view.frame = CGRectMake(0, 70, SCREEN_HEIGHT-70, SCREEN_WIDTH);
    
    MMNT_ShareButtons *firstVC = [myController.childViewControllers objectAtIndex:0];
//    [firstVC.buttons enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
//        obj.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
//    }];
    
    [self.view addSubview: myController.view];
    myController.view.frame = CGRectMake(0, 70, SCREEN_WIDTH, SCREEN_HEIGHT-70);
    
    
    // run an animation
    [UIView animateWithDuration:0.2 animations:^{
        self.zoomContainer.transform = CGAffineTransformMakeScale(0, 0);
        self.xImg.transform = CGAffineTransformMakeScale(0, 0);
        self.xBtn.userInteractionEnabled = NO; // disable buttons so can't press them again
        self.checkImg.transform = CGAffineTransformMakeScale(0, 0);
        self.checkBtn.userInteractionEnabled = NO;
        self.pullDownPrompt.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        
    // Scale up fromVC subviews
    MMNT_ShareButtons *firstVC = [myController.childViewControllers objectAtIndex:0];
    [firstVC.buttons enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        NSTimeInterval delay = 0 + ((float)idx / (float)[myController.view.subviews count]) * 0.05;
        
        POPSpringAnimation *scaleUp = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleUp.toValue = [NSValue valueWithCGPoint: CGPointMake(1, 1)] ;
        scaleUp.springBounciness = 15;
        scaleUp.springSpeed = 15;
        scaleUp.beginTime = (CACurrentMediaTime() + delay);
        [obj pop_addAnimation:scaleUp forKey:@"scale"];
        
    }];
        
        [myController didMoveToParentViewController:self];
        
        self.mainController.transitioningDelegate = self.mainController.shareViewsManager;
        self.transitioningDelegate = self.mainController.shareViewsManager;
        
    }];

    
    
}

-(void)exitingFromShareView{
    // slidedown topbar
    POPSpringAnimation *slide = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationXY];
    slide.toValue = [NSValue valueWithCGPoint:CGPointMake(0,0)];
    slide.springSpeed = 20;
    slide.springBounciness = 7;
    [self.fakeLogoBar.layer pop_addAnimation:slide forKey:@"slide"];
    
    // and slide down the background blur
    POPSpringAnimation *center = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    center.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 70)];
    center.springSpeed = 20;
    center.springBounciness = 10;
    [self.blurContainer pop_addAnimation:center forKey:@"position"];
    
    POPSpringAnimation *center1 = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    center1.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-70)];
    center1.springSpeed = 20;
    center1.springBounciness = 10;
    [self.blurContainer.imageView pop_addAnimation:center1 forKey:@"position"];
    
}

- (IBAction)pressedCancel:(id)sender {
    // slide up bar
    [UIView animateWithDuration:0.3 animations:^{
        self.shareBar.transform = CGAffineTransformIdentity;
    }
     completion:^(BOOL finished) {
         [[self.sharedPicsContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
     }];
    [self.toShare removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userPile"];
    [Amplitude logEvent:@"cancelled pile"];
}

@end
