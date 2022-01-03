when defined(windows):
  import waitonaddress
elif defined(linux):
  import std/posix
  import futex
elif defined(macosx):
  import ulock

proc wait*[T](monitor: ptr T; compare: T; time: int = 0): bool {.inline, discardable.} =
  ## Thread will wait on address if it is the same as `compare`.
  ## 
  ## By default the wait time is infinite, however can be adjusted in msecs by time.
  ## 
  ## Returns false if times out.
  when defined(windows):
    var t: int32
    if time == 0:
      t = INFINITE
    else:
      t = time.int32
    result = waitOnAddress(monitor, compare.unsafeAddr, sizeof(T).int32, t)
  elif defined(linux):
    if time == 0:
      result = not(sysFutex(monitor, futex.WaitPrivate, cast[cint](compare)) != 0.cint)
    else:
      var timeout: posix.TimeSpec
      timeout.tv_sec = posix.Time(time div 1_000)
      timeout.tv_nsec = (time mod 1_000) * 1_000 * 1_000
      result = not(sysFutex(monitor, futex.WaitPrivate, cast[cint](compare), timeout = timeout.addr) != 0.cint)
  elif defined(macosx):
    if time == 0:
      ulock_wait(UL_COMPARE_AND_WAIT, monitor, cast[uint64](compare), high(uint32).uint32) >= 0
    else:
      ulock_wait(UL_COMPARE_AND_WAIT, monitor, cast[uint64](compare), (time * 1000).uint32) >= 0
  else:
    {.fatal: "Your OS is not supported with implemented futexes, please submit an issue".}

proc wake*(monitor: pointer) {.inline.} =
  ## Wake a single thread (should there be one) waiting on the address given.
  when defined(windows):
    wakeByAddressSingle(monitor)
  elif defined(linux):
    discard sysFutex(monitor, futex.WakePrivate, 1)
  elif defined(macosx):
    discard ulock_wake(UL_COMPARE_AND_WAIT or ULF_WAKE_THREAD, monitor, cast[uint64](0))
  else:
    {.fatal: "Your OS is not supported with implemented futexes, please submit an issue".}

proc wakeAll*(monitor: pointer) {.inline.} =
  ## Wake all threads (should there be any) waiting on the address given.
  when defined(windows):
    wakeByAddressAll(monitor)
  elif defined(linux):
    discard sysFutex(monitor, futex.WakePrivate, high(cint))
  elif defined(macosx):
    discard ulock_wake(UL_COMPARE_AND_WAIT or ULF_WAKE_ALL, monitor, cast[uint64](0))
  else:
    {.fatal: "Your OS is not supported with implemented futexes, please submit an issue".}