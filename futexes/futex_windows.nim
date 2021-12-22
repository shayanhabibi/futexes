import waitonaddress

proc wait*[T](monitor: ptr T; compare: T; time: static int = 0): bool {.inline, discardable.} =
  when time == 0:
    const t = INFINITE
  else:
    const t = time
  result = waitOnAddress(monitor, compare.unsafeAddr, sizeof(T).int32, t)
    

proc wake*(monitor: pointer) {.inline.} =
  wakeByAddressSingle(monitor)

proc wakeAll*(monitor: pointer) {.inline.} =
  wakeByAddressAll(monitor)