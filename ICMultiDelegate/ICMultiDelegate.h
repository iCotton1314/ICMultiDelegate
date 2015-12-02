//
//  ICMultiDelegate.h
//  ICMultiDelegate
//
//  Created by iCotton on 12/1/15.
//  Copyright © 2015 iCotton. All rights reserved.
//

#import <Foundation/Foundation.h>

// this class is thread-safe.
@interface ICMultiDelegate : NSObject


- (void)addDelegate:(nonnull NSObject *)delegate;

- (void)addDelegate:(nonnull NSObject *)delegate dispatchQueue:(nullable dispatch_queue_t)dispatchQueue;

- (void)removeDelegate:(nonnull NSObject *)delegate;

@end
