//
//  MultithreadedDictionary.m
//  MutexTest
//
//  Created by Jesse Boley on 10/29/19.
//  Copyright © 2019 Jesse Boley. All rights reserved.
//

#import "MultithreadedDictionary.h"
#import <pthread.h>

@implementation MultithreadedDictionary
{
    NSMutableDictionary *_dictionary;
}

- (instancetype)init
{
    if (self = [super init]) {
        _dictionary = [NSMutableDictionary new];
    }
    return self;
}

- (id)objectForKey:(id)key
{
    return nil;
}

- (void)setObject:(id)object forKey:(id)key
{
    
}

- (id)internalObjectForKey:(id)key
{
    return _dictionary[key];
}

- (void)internalSetObject:(id)object forKey:(id)key
{
    _dictionary[key] = object;
}

@end

@implementation MultithreadedDictionary_NSLock
{
    NSLock *_lock;
}

- (instancetype)init
{
    if (self = [super init]) {
        _lock = [NSLock new];
    }
    return self;
}

- (id)objectForKey:(id)key
{
    id result = nil;
    [_lock lock];
    result = [self internalObjectForKey:key];
    [_lock unlock];
    return result;
}

- (void)setObject:(id)object forKey:(id)key
{
    [_lock lock];
    [self internalSetObject:object forKey:key];
    [_lock unlock];
}

@end

@implementation MultithreadedDictionary_Synchronized

- (id)objectForKey:(id)key
{
    id result = nil;
    @synchronized (self) {
        result = [self internalObjectForKey:key];
    }
    return result;
}

- (void)setObject:(id)object forKey:(id)key
{
    @synchronized (self) {
        [self internalSetObject:object forKey:key];
    }
}

@end

@implementation MultithreadedDictionary_PThreadMutex
{
    pthread_mutex_t _mutex;
}

- (instancetype)init
{
    if (self = [super init]) {
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

- (id)objectForKey:(id)key
{
    id result = nil;
    pthread_mutex_lock(&_mutex);
    result = [self internalObjectForKey:key];
    pthread_mutex_unlock(&_mutex);
    return result;
}

- (void)setObject:(id)object forKey:(id)key
{
    pthread_mutex_lock(&_mutex);
    [self internalSetObject:object forKey:key];
    pthread_mutex_unlock(&_mutex);
}

@end

@implementation MultithreadedDictionary_DispatchQueue
{
    dispatch_queue_t _queue;
}

- (instancetype)init
{
    if (self = [super init]) {
        _queue = dispatch_queue_create("dictionary.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (id)objectForKey:(id)key
{
    __block id result = nil;
    dispatch_sync(_queue, ^{
        result = [self internalObjectForKey:key];
    });
    return result;
}

- (void)setObject:(id)object forKey:(id)key
{
    dispatch_sync(_queue, ^{
        [self internalSetObject:object forKey:key];
    });
}

@end

@implementation MultithreadedDictionary_ConcurrentDispatchQueue
{
    dispatch_queue_t _queue;
}

- (instancetype)init
{
    if (self = [super init]) {
        _queue = dispatch_queue_create("dictionary.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (id)objectForKey:(id)key
{
    __block id result = nil;
    dispatch_sync(_queue, ^{
        result = [self internalObjectForKey:key];
    });
    return result;
}

- (void)setObject:(id)object forKey:(id)key
{
    dispatch_barrier_sync(_queue, ^{
        [self internalSetObject:object forKey:key];
    });
}

@end
