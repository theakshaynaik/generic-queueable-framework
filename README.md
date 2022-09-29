# Generic Queueable Framework
Split your queueable logic on the basis of chunk size.

## What is the use?
--> Framework can be used to process bulk records in async context.
--> We can only enqueue one queueable job in async context. If there is another queueable job fired, the framework will automatically start a scheduled job after 10 seconds to start a separate transaction and enqueue the next job as per chunk size.
