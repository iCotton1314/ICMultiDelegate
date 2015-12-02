//
//  ViewController.m
//  ICMultiDelegate
//
//  Created by iCotton on 12/1/15.
//  Copyright © 2015 iCotton. All rights reserved.
//

#import "ViewController.h"
#import "ICMultiDelegate.h"


@protocol ICMultiDelegateTestDelegate <NSObject>

- (void)delegateWithArg1:(NSUInteger)arg1 arg2:(CGFloat)arg2 arg3:(NSString *)arg3;

@end

@interface ICMultiDelegateTest : NSObject
@property (nonatomic, strong) ICMultiDelegate<ICMultiDelegateTestDelegate>       *icMultiDelegate;

- (void)invoke;

@end

@implementation ICMultiDelegateTest

- (id)init {
    if(self = [super init]) {
        _icMultiDelegate = (ICMultiDelegate<ICMultiDelegateTestDelegate> *)[[ICMultiDelegate alloc] init];
    }
    
    return self;
}

- (void)invoke {
    [self.icMultiDelegate delegateWithArg1:100 arg2:0.85 arg3:@"test"];
}

@end


@interface ICTestImplementation : NSObject <ICMultiDelegateTestDelegate>
@property (nonatomic, copy) NSString        *name;

- (id)initWithName:(NSString *)name;

@end

@implementation ICTestImplementation

- (id)initWithName:(NSString *)name {
    if(self = [super init]) {
        _name = name;
    }

    return self;
}

- (void)delegateWithArg1:(NSUInteger)arg1 arg2:(CGFloat)arg2 arg3:(NSString *)arg3 {
    NSLog(@"%@----%@", _name, NSStringFromSelector(_cmd));
}

@end

@interface ViewController ()
{
    ICMultiDelegateTest *test;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    test = [[ICMultiDelegateTest alloc] init];
    
    ICTestImplementation *test1 = [[ICTestImplementation alloc] initWithName:@"test1"];
    ICTestImplementation *test2 = [[ICTestImplementation alloc] initWithName:@"test2"];
    ICTestImplementation *test3 = [[ICTestImplementation alloc] initWithName:@"test3"];
    ICTestImplementation *test4 = [[ICTestImplementation alloc] initWithName:@"test4"];
    ICTestImplementation *test5 = [[ICTestImplementation alloc] initWithName:@"test5"];
    ICTestImplementation *test6 = [[ICTestImplementation alloc] initWithName:@"test6"];
    
    dispatch_queue_t queue = dispatch_queue_create("com.example.myqueue", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
        [test.icMultiDelegate addDelegate:test1];
        [test invoke];
    });
    
    dispatch_async(queue, ^{
        [test.icMultiDelegate addDelegate:test2];
        [test invoke];
    });
    
    dispatch_async(queue, ^{
        [test invoke];
        [test.icMultiDelegate addDelegate:test3];
    });
    
    dispatch_async(queue, ^{
        [test invoke];
        [test.icMultiDelegate addDelegate:test4];
    });
    
    dispatch_async(queue, ^{
        [test.icMultiDelegate addDelegate:test5];
        [test invoke];
    });
    
    dispatch_async(queue, ^{
        [test.icMultiDelegate addDelegate:test6];
        [test invoke];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
