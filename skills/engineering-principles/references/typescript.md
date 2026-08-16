# TypeScript and React

- Treat `any` as an escape hatch. Accept `unknown` at uncertain boundaries,
  then validate or narrow it before exposing a precise type.
- Prefer inference for clear locals and return values. Add annotations at public
  boundaries or where they prevent widening and drift.
- Derive types from runtime constants, schemas, and function signatures rather
  than maintaining duplicate declarations.
- Model variants with discriminated unions and exhaustive checks. Avoid bags of
  optional properties that permit contradictory states.
- Prefer `satisfies`, schema validation, and real type guards over assertions.
  Do not hide mismatches behind `as` or a one-line casting helper.
- Keep React state minimal and derive values that can be derived. Respect hook
  lifecycles, cache ownership, server/client boundaries, and established
  component patterns.
- Preserve the repository's package manager, build system, framework, state,
  and validation choices unless changing one is the task.
- Handle rejected promises and cancellation explicitly. Do not start async work
  whose lifecycle has no owner.
