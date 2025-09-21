#import <CoreMotion/CoreMotion.h>
#include "SC_AirPods.h"

@interface AirPodsMotion: NSObject<CMHeadphoneMotionManagerDelegate>

@property(nonatomic, strong) CMHeadphoneMotionManager *motionManager;
@property(nonatomic, strong) NSOperationQueue *motionQueue;
@property(atomic, assign) bool threadStarted;

-(void) startThread;
-(void) stopThread;
@end

@implementation AirPodsMotion {
@public std::atomic<double> qx, qy, qz, qw;
@public std::atomic<double> ux, uy, uz;
@public std::atomic<bool> connected;
}

@synthesize motionManager;

static AirPodsMotion *_instance;

+(AirPodsMotion*) sharedInstance {
    @synchronized ([AirPodsMotion class]) {
        if(!_instance) {
            _instance = [[self alloc] init];
        }
        return _instance;
    }
}


// do not call directly - use singleton from sharedInstance :)
-(id) init {
    if(self = [super init]) {
        self.motionQueue = [[NSOperationQueue alloc] init];
        self.motionQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        self.motionManager = [[CMHeadphoneMotionManager alloc] init];
        
        self.motionManager.delegate = self;
        
        qx.store(0.0, std::memory_order_relaxed);
        qy.store(0.0, std::memory_order_relaxed);
        qz.store(0.0, std::memory_order_relaxed);
        qw.store(0.0, std::memory_order_relaxed);
        
        ux.store(0.0, std::memory_order_relaxed);
        uy.store(0.0, std::memory_order_relaxed);
        uz.store(0.0, std::memory_order_relaxed);
        
        connected.store(false, std::memory_order_relaxed);
        
        self.threadStarted = NO;
    }
    return self;
}

-(void) startThread {
    if(self.threadStarted) {
        return;
    }
    self.threadStarted = YES;
    
    if(motionManager.isDeviceMotionAvailable) {
        [motionManager startDeviceMotionUpdatesToQueue:self.motionQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
                if(motion) {
                    CMQuaternion q = motion.attitude.quaternion;
                    qx.store(q.x, std::memory_order_relaxed);
                    qy.store(q.y, std::memory_order_relaxed);
                    qz.store(q.z, std::memory_order_relaxed);
                    qw.store(q.w, std::memory_order_relaxed);
                    
                    CMAcceleration a = motion.userAcceleration;
                    ux.store(a.x, std::memory_order_relaxed);
                    uy.store(a.y, std::memory_order_relaxed);
                    uz.store(a.z, std::memory_order_relaxed);
                }
            }
        ];
    } else {
        printf("No device motion is available!");
    }
}

-(void) headphoneMotionManagerDidConnect:(CMHeadphoneMotionManager *)manager {
    connected.store(true, std::memory_order_relaxed);
}

-(void) headphoneMotionManagerDidDisconnect:(CMHeadphoneMotionManager *)manager {
    connected.store(false, std::memory_order_relaxed);
}

-(void) stopThread {
    [motionManager stopDeviceMotionUpdates];
}
@end

// c implementation from SC_Airpdos.h

Quaternion getAirPodsQuaternion() {
    AirPodsMotion *m = [AirPodsMotion sharedInstance];
    Quaternion q;
    q.x = m->qx.load(std::memory_order_relaxed);
    q.y = m->qy.load(std::memory_order_relaxed);
    q.z = m->qz.load(std::memory_order_relaxed);
    q.w = m->qw.load(std::memory_order_relaxed);
    return q;
}

UserAcceleration getAirPodsUserAcceleration() {
    AirPodsMotion *m = [AirPodsMotion sharedInstance];
    UserAcceleration a;
    a.x = m->ux.load(std::memory_order_relaxed);
    a.y = m->uy.load(std::memory_order_relaxed);
    a.z = m->uz.load(std::memory_order_relaxed);
    return a;
}

void startAirPodsThread() {
    [[AirPodsMotion sharedInstance] startThread];
}

void stopAirPodsThread() {
    [[AirPodsMotion sharedInstance] stopThread];
}

bool getAirPodsStatus() {
    AirPodsMotion *m = [AirPodsMotion sharedInstance];
    return m->connected.load(std::memory_order_relaxed);
}
