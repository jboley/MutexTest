//
//  RingBufferBase.h
//  MutexTest
//
//  Created by Jesse Boley on 10/29/19.
//  Copyright © 2019 Jesse Boley. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RingBufferBase : NSObject

- (instancetype)initWithCapacity:(NSInteger)capacity;

// Pushes a new integer into the ring buffer
- (void)put:(NSInteger)i;

// Retrieves a value from the ring buffer
- (NSInteger)get;

// Internal implementation of put once lock is acquired
- (void)putInternal:(NSInteger)i;

// Internal implementation of get once lock is acquired
- (NSInteger)getInternal;

@end

@interface RingBuffer_NSLock : RingBufferBase
@end

@interface RingBuffer_Synchronized : RingBufferBase
@end

@interface RingBuffer_PThreadMutex : RingBufferBase
@end

@interface RingBuffer_DispatchQueue : RingBufferBase
@end

NS_ASSUME_NONNULL_END
