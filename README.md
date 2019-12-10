On iOS, we have multiple different ways of synchronizing state between threads, but it's not always obvious which option will perform the best. I made a small app to test two different types of data structures: a ring buffer and a threadsafe dictionary. All tests were run on an iPhone 11 Pro running iOS 13.2.3. Each test was run 5 times and the highest/lowest times were discarded.

Ring Buffer
-----------
- NSLock: 1.086s
- @synchronized: 2.37s
- pthread_mutex_t: 0.667s
- dispatch_queue_t (serial): 30.30s


Multithreaded Dictionary
------------------------
- NSLock: 0.783s
- @synchronized: 2.095s
- pthread_mutex_t: 0.688s
- dispatch_queue_t (serial): 2.944s
- dispatch_queue_t (concurrent w/ write barrier): 1.719s
