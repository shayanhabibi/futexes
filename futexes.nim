when defined(windows):
  import futexes/futex_windows
  export futex_windows
elif defined(linux):
  import futexes/futex_linux
  export futex_linux
elif defined(macosx):
  import futexes/futex_darwin
  export futex_darwin
else:
  proc wait*[T](monitor: ptr T; compare: T; time: static int = 0): bool {.inline, discardable.} =
    {.fatal: "Your OS is not supported with implemented futexes, please submit an issue".}
  proc wake*(monitor: pointer) {.inline.} =
    {.fatal: "Your OS is not supported with implemented futexes, please submit an issue".}
  proc wakeAll*(monitor: pointer) {.inline.} =
    {.fatal: "Your OS is not supported with implemented futexes, please submit an issue".}
