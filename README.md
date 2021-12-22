# Futexes

Platform independent implementation of futex behaviour with a comparison wait,
wake and wakeall command available.

Darwin (macosx), linux and windows are supported. Waits accept a timeout in milliseconds
and will return false on error or timeout.