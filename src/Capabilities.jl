module Capabilities

export Capabilities
export @cap, @defcap, @importcap
export IncapableError

using ExprTools

# This global variable maintains a stack of capabilities. It grows whenever
# a capability-constrained function is called.
# TODO: use task local storage to support async or multi-threaded apps
const CAP_STACK = Any[Any]

include("types.jl")
include("macros.jl")
include("standard.jl")

end #module
