import ulock

proc wait*[T](monitor: ptr T; compare: T; time: int = 0): bool {.inline, discardable.} =
  if time == 0:
    ulock_wait(UL_COMPARE_AND_WAIT, monitor, cast[uint64](compare), high(uint32).uint32) >= 0
  else:
    ulock_wait(UL_COMPARE_AND_WAIT, monitor, cast[uint64](compare), (time * 1000).uint32) >= 0

proc wake*(monitor: pointer) {.inline.} =
  discard ulock_wake(UL_COMPARE_AND_WAIT or ULF_WAKE_THREAD, monitor, cast[uint64](0))

proc wakeAll*(monitor: pointer) {.inline.} =
  discard ulock_wake(UL_COMPARE_AND_WAIT or ULF_WAKE_ALL, monitor, cast[uint64](0))