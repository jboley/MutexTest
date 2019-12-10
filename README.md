On iOS, we have multiple different ways of synchronizing state between threads, but it's not always obvious which option will perform the best. 

I made a small app to test two different types of data structures (a ring buffer and a threadsafe dictionary), using a variety of different synchronization primitives. All tests were run on an iPhone 11 Pro running iOS 13.2.3. Each test was run 5 times and the highest and lowest times were discarded.

Ring Buffer
-----------

| Synchronization Type | Elapsed Time (s) |
| ------ | ----: |
| NSLock | `1.086` |
| @synchronized | `2.370` |
| pthread_mutex_t | `0.667` |
| dispatch_queue_t (serial) | `30.300` |


Multithreaded Dictionary
------------------------

| Synchronization Type | Elapsed Time (s) |
| ------ | ----: |
| NSLock | `0.783` |
| @synchronized | `2.095` |
| pthread_mutex_t | `0.688` |
| dispatch_queue_t (serial) | `2.944` |
| dispatch_queue_t (concurrent w/ write barrier) | `1.719` |
