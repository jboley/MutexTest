//
//  ViewController.m
//  MutexTest
//
//  Created by Jesse Boley on 10/29/19.
//  Copyright © 2019 Jesse Boley. All rights reserved.
//

#import "ViewController.h"
#import "RingBuffer.h"
#import "MultithreadedDictionary.h"

@interface ViewController ()

@end

@implementation ViewController
{
    UIButton *_ringBufferTestsButton;
    UIButton *_dictionaryTestsButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _ringBufferTestsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_ringBufferTestsButton addTarget:self action:@selector(_runRingBufferTests:) forControlEvents:UIControlEventTouchUpInside];
    [_ringBufferTestsButton setTitle:NSLocalizedString(@"Run Ring Buffer Tests", @"Run Ring Buffer Tests") forState:UIControlStateNormal];
    [_ringBufferTestsButton sizeToFit];
    [self.view addSubview:_ringBufferTestsButton];
    _ringBufferTestsButton.frame = CGRectMake(CGRectGetMidX(self.view.bounds) - _ringBufferTestsButton.bounds.size.width / 2.0,
                                              CGRectGetMidY(self.view.bounds) - _ringBufferTestsButton.bounds.size.height / 2.0,
                                              _ringBufferTestsButton.bounds.size.width,
                                              _ringBufferTestsButton.bounds.size.height);
    
    _dictionaryTestsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_dictionaryTestsButton addTarget:self action:@selector(_runDictionaryTests:) forControlEvents:UIControlEventTouchUpInside];
    [_dictionaryTestsButton setTitle:NSLocalizedString(@"Run Dictionary Tests", @"Run Dictionary Tests") forState:UIControlStateNormal];
    [_dictionaryTestsButton sizeToFit];
    [self.view addSubview:_dictionaryTestsButton];
    _dictionaryTestsButton.frame = CGRectMake(CGRectGetMidX(self.view.bounds) - _dictionaryTestsButton.bounds.size.width / 2.0,
                                              CGRectGetMidY(self.view.bounds) - _dictionaryTestsButton.bounds.size.height / 2.0 +
                                              _ringBufferTestsButton.bounds.size.height + 15.0,
                                              _dictionaryTestsButton.bounds.size.width,
                                              _dictionaryTestsButton.bounds.size.height);
}

- (void)_runRingBufferTests:(id)sender
{
    NSArray *ringBufferClasses = @[[RingBuffer_NSLock class], [RingBuffer_Synchronized class], [RingBuffer_PThreadMutex class], [RingBuffer_DispatchQueue class]];
    __block NSUInteger classIndexToTest = 0;
    
    __weak __typeof(self) weakSelf = self;
    __block void (^completionBlock)(void);
    
    void (^runTestBlock)(void) = ^{
        [weakSelf _runRingBufferTestsForClass:ringBufferClasses[classIndexToTest++] completion:completionBlock];
    };
    completionBlock = ^{
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (classIndexToTest < ringBufferClasses.count) {
            runTestBlock();
        }
    };
    runTestBlock();
}

- (void)_runRingBufferTestsForClass:(Class)cls completion:(void(^)(void))completionBlock
{
    RingBufferBase *ringBuffer = [[cls alloc] initWithCapacity:10000000];
    
    CFTimeInterval startTime = CACurrentMediaTime();
    
    // Kick off writer
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < 10000000; i++) {
            [ringBuffer put:i];
        }
    });
    
    // Kick off reader
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < 10000000; i++) {
            NSInteger value = [ringBuffer get];
            if (value == -1) {
                i--;
                continue;
            }
            
            if (value != i) {
                NSLog(@"ERROR: Expected %ld, Got %ld", (long)i, (long)value);
            }
        }
        
        CFTimeInterval endTime = CACurrentMediaTime();
        NSLog(@"[%@] Elapsed: %lg", [NSStringFromClass(cls) substringFromIndex:[@"RingBuffer_" length]], endTime - startTime);
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock();
        });
    });
}

- (void)_runDictionaryTests:(id)sender
{
    NSArray *classesToTest = @[[MultithreadedDictionary_NSLock class], [MultithreadedDictionary_Synchronized class], [MultithreadedDictionary_PThreadMutex class], [MultithreadedDictionary_DispatchQueue class], [MultithreadedDictionary_ConcurrentDispatchQueue class]];
    __block NSUInteger classIndexToTest = 0;
    
    __weak __typeof(self) weakSelf = self;
    __block void (^completionBlock)(void);
    
    void (^runTestBlock)(void) = ^{
        [weakSelf _runDictionaryTestsForClass:classesToTest[classIndexToTest++] completion:completionBlock];
    };
    completionBlock = ^{
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if (classIndexToTest < classesToTest.count) {
            runTestBlock();
        }
    };
    runTestBlock();
}

- (void)_runDictionaryTestsForClass:(Class)cls completion:(void(^)(void))completionBlock
{
    MultithreadedDictionary *dictionary = [[cls alloc] init];
    
    CFTimeInterval startTime = CACurrentMediaTime();
    
    // Kick off writer
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < 1000000; i++) {
            int key = arc4random_uniform(1000);
            [dictionary setObject:@(YES) forKey:@(key)];
        }
    });
    
    // Kick off reader
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < 1000000; i++) {
            int key = arc4random_uniform(1000);
            id entry = [dictionary objectForKey:@(key)];
            if ((entry != nil) && ![entry boolValue]) {
                NSLog(@"Unexpected entry in dictionary for key %d", key);
            }
        }
        
        CFTimeInterval endTime = CACurrentMediaTime();
        NSLog(@"[%@] Elapsed: %lg", [NSStringFromClass(cls) substringFromIndex:[@"MultithreadedDictionary_" length]], endTime - startTime);
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock();
        });
    });
}

@end
