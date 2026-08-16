# C# and .NET

- Keep nullable reference types truthful. Narrow or validate uncertainty rather
  than suppressing it with `!`.
- Keep asynchronous I/O async end to end. Propagate `CancellationToken` and
  avoid `.Result`, `.Wait()`, and `.GetAwaiter().GetResult()`.
- Prefer immutable records or focused classes with explicit invariants over
  mutable property bags. Use `required` members and collection expressions when
  they clarify the model.
- Use `decimal` for money and make scale, currency, and rounding explicit at
  domain boundaries.
- Prefer dependency injection and typed, validated options over service
  location, static mutable state, or scattered environment access.
- Use `System.Text.Json` and established source-generated serialization
  contexts. Keep API and message contracts compatible through rolling
  deployments.
- Keep EF Core queries bounded and intentional: project needed data, use
  no-tracking reads when appropriate, avoid queries in loops, and pass
  cancellation tokens.
- Use structured logging and the repository's established source-generation
  pattern. Never log credentials, tokens, passwords, keys, or personal data.
- Prefer current language and framework features when they simplify real code;
  avoid syntax-only modernization churn.
