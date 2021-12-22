import std/posix
import futex

proc wait*[T](monitor: ptr T, compare: T; time: int = 0): bool {.inline, discardable.} =
  ## Suspend a thread if the value of the futex is the same as refVal.
  
  # Returns 0 in case of a successful suspend
  # If value are different, it returns EWOULDBLOCK
  # We discard as this is not needed and simplifies compat with Windows futex
  if time == 0:
    result = not(sysFutex(monitor, futex.WaitPrivate, cast[cint](compare)) != 0.cint)
  else:
    var timeout: posix.TimeSpec
    timeout.tv_sec = posix.Time(time div 1_000)
    timeout.tv_nsec = (time mod 1_000) * 1_000 * 1_000
    result = not(sysFutex(monitor, futex.WaitPrivate, cast[cint](compare), timeout = timeout.addr) != 0.cint)

proc wake*(monitor: pointer) {.inline.} =
  ## Wake one thread (from the same process)

  # Returns the number of actually woken threads
  # or a Posix error code (if negative)
  # We discard as this is not needed and simplifies compat with Windows futex
  discard sysFutex(monitor, futex.WakePrivate, 1)

proc wakeAll*(monitor: pointer) {.inline.} =
  discard sysFutex(monitor, futex.WakePrivate, high(cint))