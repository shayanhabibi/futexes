import waitonaddress

proc wait*[T](monitor: ptr T; compare: T; time: int = 0): bool {.inline, discardable.} =
  var t: int32
  if time == 0:
    t = INFINITE
  else:
    t = time.int32
  result = waitOnAddress(monitor, compare.unsafeAddr, sizeof(T).int32, t)
  # If false, can get last error and check if its ERROR_TIMEOUT to make sure
  # it's not some other issue
    

proc wake*(monitor: pointer) {.inline.} =
  wakeByAddressSingle(monitor)

proc wakeAll*(monitor: pointer) {.inline.} =
  wakeByAddressAll(monitor)