On iOS we have multiple different ways of synchronizing state between threads but it's not always obvious which option will perform the best. I made a small app to test two different types of data structures: a ring buffer and a threadsafe dictionary. All tests were run on an iPhone 11 Pro running iOS 13.2.3 and an iPhone 12 Pro running iOS 14.4. Each test was run 5 times and the highest/lowest times were discarded.

Ring Buffer (iPhone 11 Pro w/ iOS 13.2.3)
-----------
- NSLock: 1.086s
- @synchronized: 2.37s
- pthread_mutex_t: 0.667s
- dispatch_queue_t (serial): 30.30s

Ring Buffer (iPhone 12 Pro w/ iOS 14.4)
-----------
- NSLock: 1.31s
- @synchronized: 1.98s
- pthread_mutex_t: 0.63s
- dispatch_queue_t (serial): 25.92s

Multithreaded Dictionary (iPhone 11 Pro w/ iOS 13.2.3)
------------------------
- NSLock: 0.783s
- @synchronized: 2.095s
- pthread_mutex_t: 0.688s
- dispatch_queue_t (serial): 2.944s
- dispatch_queue_t (concurrent w/ write barrier): 1.719s

Multithreaded Dictionary (iPhone 12 Pro w/ iOS 14.4)
------------------------
- NSLock: 0.87s
- @synchronized: 0.39s
- pthread_mutex_t: 0.80s
- dispatch_queue_t (serial): 3.11s
- dispatch_queue_t (concurrent w/ write barrier): 2.76s