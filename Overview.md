# Known issues #

  * When compiling a project with this ANE the following warning may appear. It seems it can be safely ignored and the project will work fine anyway. However, it would be appreciated if someone could help solving it, if possible:

> "ld: warning: PIE disabled. Absolute addressing (perhaps -mdynamic-no-pic) not allowed in code signed PIE, but used in `_`llvm`_`unwind from AOTBuildOutput-0.o. To fix this warning, don't compile with -mdynamic-no-pic or link with -Wl,-no`_`pie"

  * When calling a TWRequest, the custom parameters object passed to the functions must contain strings, otherwise an exception is thrown by Objective C. To solve this a try-catch was added, and therefore the ANE only works on AIR 3.4+.

# API #

Browse the source code for a sample project showing the ANE features and its usage.

# FAQ #

**Why native Twitter and not the Social Framework added in iOS 6?**

As an iOS user, I feel iOS 6 a little deceiving, and most people I know is skipping it for now, so I felt the native Framework was a better target.