//
//  MultithreadedDictionary.h
//  MutexTest
//
//  Created by Jesse Boley on 10/29/19.
//  Copyright © 2019 Jesse Boley. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultithreadedDictionary : NSDictionary

- (instancetype)init;

- (id)objectForKey:(id)key;

- (void)setObject:(id)object forKey:(id)key;

// Internal implementation of -objectForKey: once lock is acquired
- (id)internalObjectForKey:(id)key;

// Internal implementation of -setObject:forKey: once lock is acquired
- (void)internalSetObject:(id)object forKey:(id)key;

@end

@interface MultithreadedDictionary_NSLock : MultithreadedDictionary
@end

@interface MultithreadedDictionary_Synchronized : MultithreadedDictionary
@end

@interface MultithreadedDictionary_PThreadMutex : MultithreadedDictionary
@end

@interface MultithreadedDictionary_DispatchQueue : MultithreadedDictionary
@end

@interface MultithreadedDictionary_ConcurrentDispatchQueue : MultithreadedDictionary
@end

NS_ASSUME_NONNULL_END
