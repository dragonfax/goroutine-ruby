An Proof of Concept implementation of goroutines in pure ruby using Fibers (and a scheduler) instead of Threads.

A very naive implementation.

* call $scheduler.run at the end of your script
* the main function must be wrapped in a goroutine
* see the examples provided.


# TODO

* Make the scheduler invisibile (no $scheduler.run)
* Use a thread cache for the non_blocking call Threads
* Find a real async HTTP Request API
* Implement actual 'select' (epoll) based Select/Cases
