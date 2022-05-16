allow user packages to define their own capabilities
  => DONE

allow user to use their own naming convention for capabilities?
currently it's hardcoded to "_Cap_" prefix.

allow a type hierarchy for capabilities.
currently, `@defcap` makes a flat, single-level hierarchy.

how to deal with multiple dispatch?
It seems that `@cap` must be used in each method definition, not the generic one.

how to make it efficient?
  maybe not have to push/pop when caller/callee caps are same

