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

Strong typing for passing lambdas?
Hack language has strong typing and so you can define a function that takes a lambda
argument, and in that declaration, you can say what capabilities the lambda
function should require. Julia functions are not exactly typed -- it has a flat
structure where all functions are unique and they all subtypes from the Function
type. Further, we must define capabilities at the method level. This is going
to be difficult to implement without compiler support.