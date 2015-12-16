//
//  ICMultiDelegate.m
//  ICMultiDelegate
//
//  Created by iCotton on 12/1/15.
//  Copyright © 2015 iCotton. All rights reserved.
//

#import <objc/runtime.h>

#import "ICMultiDelegate.h"

#pragma mark - //////////////////////////
#pragma mark - NSObject (ICMultiDelegate)


static char kICMultiDelegateQueueKey;
@interface NSObject (ICMultiDelegate)
@property (nonatomic, strong) dispatch_queue_t          multiDelegateQueue;

@end

@implementation NSObject (ICMultiDelegate)
@dynamic multiDelegateQueue;

- (void)setMultiDelegateQueue:(dispatch_queue_t)multiDelegateQueue {
    objc_setAssociatedObject(self, &kICMultiDelegateQueueKey, multiDelegateQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (dispatch_queue_t)multiDelegateQueue {
    return objc_getAssociatedObject(self, &kICMultiDelegateQueueKey);
}

- (void)releaseMultiDelegateQueue {
    objc_removeAssociatedObjects(self.multiDelegateQueue);
}

@end


#pragma mark - /////////////////////////////
#pragma mark - ICMultiDelegate Implementation

@interface ICMultiDelegate()
{
    NSMutableArray              *_delegates;
    NSLock                      *_lock;
}

@end

@implementation ICMultiDelegate

#pragma mark - Life Cycle

- (id)init {
    if(self = [super init]) {
        _delegates  = [[NSMutableArray alloc] init];
        _lock       = [[NSLock alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_delegates removeAllObjects];
    _delegates  = nil;
    _lock       = nil;
}

#pragma mark - Private

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    for (NSObject *delegate in _delegates) {
        NSMethodSignature *result = [delegate methodSignatureForSelector:aSelector];
        
        if (result != nil) {
            return result;
        }
    }
    
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    
    void (^ lookupBlock)() = ^{
        for (NSObject *delegate in _delegates) {
            if ([delegate respondsToSelector:selector]) {
                NSInvocation *cloneInvocation = [self cloneInvocation:anInvocation];
                
                void (^ invokeBlock)() = ^{
                    @autoreleasepool {
                        [cloneInvocation invokeWithTarget:delegate];
                    }
                };
                
                if(delegate.multiDelegateQueue) {
                    dispatch_async(delegate.multiDelegateQueue, invokeBlock);
                }
                else {
                    invokeBlock();
                }
            }
        }
    };
    
    [_lock lock];
    lookupBlock();
    [_lock unlock];
}

- (NSInvocation *)cloneInvocation:(NSInvocation *)originalInvocation {
    NSMethodSignature *methodSignature = [originalInvocation methodSignature];
    
    NSInvocation *cloneInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [cloneInvocation setSelector:[originalInvocation selector]];
    
    NSUInteger i, count = [methodSignature numberOfArguments];
    for (i = 2; i < count; i++) {
        void *argument;
        [originalInvocation getArgument:&argument atIndex:i];
        if(argument != NULL) {
            [cloneInvocation setArgument:&argument atIndex:i];
        }
        else {
            NSString *selectorStr = NSStringFromSelector([originalInvocation selector]);
            
            NSString *format = @"Argument error to method %@";
            NSString *reason = [NSString stringWithFormat:format, selectorStr];
            
            [[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
        }
    }
    
    [cloneInvocation retainArguments];
    
    return cloneInvocation;
}

- (void)doNothing {

}

#pragma mark - Public

- (void)addDelegate:(id)delegate {
    [self addDelegate:delegate dispatchQueue:nil];
}

- (void)addDelegate:(nonnull NSObject *)delegate dispatchQueue:(nullable dispatch_queue_t)dispatchQueue {
    NSAssert(delegate != nil, @"delegate must be non-null");
    
    delegate.multiDelegateQueue = dispatchQueue;
    
    [_lock lock];
    [_delegates addObject:delegate];
    [_lock unlock];
}

- (void)removeDelegate:(id)delegate {
    [_lock lock];
    [_delegates removeObject:delegate];
    [_lock unlock];
}

@end
