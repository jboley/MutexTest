//
//  RingBufferBase.m
//  MutexTest
//
//  Created by Jesse Boley on 10/29/19.
//  Copyright © 2019 Jesse Boley. All rights reserved.
//

#import "RingBuffer.h"
#import <pthread.h>

@implementation RingBufferBase
{
    NSInteger _capacity;
    NSInteger _size;
    NSInteger _readIndex;
    NSInteger _writeIndex;
    NSInteger *_buffer;
}

- (instancetype)initWithCapacity:(NSInteger)capacity
{
    if (self = [super init]) {
        _capacity = capacity;
        _buffer = (NSInteger *)malloc(_capacity * sizeof(NSInteger));
    }
    return self;
}

- (void)put:(NSInteger)i
{
    
}

- (void)putInternal:(NSInteger)i
{
    if (_size < _capacity) {
        _buffer[_writeIndex++] = i;
        if (_writeIndex >= _capacity)
            _writeIndex = 0;
        _size++;
    }
}

- (NSInteger)get
{
    return -1;
}

- (NSInteger)getInternal
{
    NSInteger result = -1;
    if (_size > 0) {
        result = _buffer[_readIndex++];
        if (_readIndex >= _capacity)
            _readIndex = 0;
        _size--;
    }
    return result;
}

@end

@implementation RingBuffer_NSLock
{
    NSLock *_lock;
}

- (instancetype)initWithCapacity:(NSInteger)capacity
{
    if (self = [super initWithCapacity:capacity]) {
        _lock = [NSLock new];
    }
    return self;
}

- (void)put:(NSInteger)i
{
    [_lock lock];
    [self putInternal:i];
    [_lock unlock];
}

- (NSInteger)get
{
    NSInteger result = -1;
    [_lock lock];
    result = [self getInternal];
    [_lock unlock];
    return result;
}

@end

@implementation RingBuffer_Synchronized

- (void)put:(NSInteger)i
{
    @synchronized (self) {
        [self putInternal:i];
    }
}

- (NSInteger)get
{
    NSInteger result = -1;
    @synchronized (self) {
        result = [self getInternal];
    }
    return result;
}

@end

@implementation RingBuffer_PThreadMutex
{
    pthread_mutex_t _mutex;
}

- (instancetype)initWithCapacity:(NSInteger)capacity
{
    if (self = [super initWithCapacity:capacity]) {
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

- (void)put:(NSInteger)i
{
    pthread_mutex_lock(&_mutex);
    [self putInternal:i];
    pthread_mutex_unlock(&_mutex);
}

- (NSInteger)get
{
    NSInteger result = -1;
    pthread_mutex_lock(&_mutex);
    result = [self getInternal];
    pthread_mutex_unlock(&_mutex);
    return result;
}

@end

@implementation RingBuffer_DispatchQueue
{
    dispatch_queue_t _queue;
}

- (instancetype)initWithCapacity:(NSInteger)capacity
{
    if (self = [super initWithCapacity:capacity]) {
        _queue = dispatch_queue_create("ring_buffer.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)put:(NSInteger)i
{
    dispatch_sync(_queue, ^{
        [self putInternal:i];
    });
}

- (NSInteger)get
{
    __block NSInteger result = -1;
    dispatch_sync(_queue, ^{
        result = [self getInternal];
    });
    return result;
}

@end
