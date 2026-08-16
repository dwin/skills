# Go

- Write straightforward Go. Prefer small concrete functions and data types over
  premature interfaces, generic helpers, builders, or fluent APIs.
- Define interfaces where consumed, keep them narrow, and return concrete types
  unless callers need substitution.
- Put `context.Context` first, propagate it through blocking work, and never
  store it in a struct. Give every derived context a reachable cancellation
  path.
- Give every goroutine an owner, termination signal, and join strategy. Bound
  concurrency and make channel-closing ownership unambiguous.
- Wrap errors with useful operation context using `%w`; use `errors.Is`,
  `errors.As`, and `errors.Join` where appropriate. Avoid logging and returning
  the same error without adding distinct value.
- Design useful zero values when practical. Be deliberate about `nil` versus
  empty slices or maps at serialization boundaries and avoid hidden aliasing.
- Prefer the standard library and established repository helpers. Keep
  `defer`-managed lifetimes obvious and check terminal iterator errors such as
  `rows.Err()`.
- Use table-driven tests when they improve clarity, not by reflex. Avoid
  `time.Sleep` as synchronization.
