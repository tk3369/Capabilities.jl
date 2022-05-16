module Capabilities

using ExprTools

export @cap, @defcap

# This global variable maintains a stack of capabilities. It grows whenever
# a capability-constrained function is called.
# TODO: use task local storage to support async or multi-threaded apps
const CAP_STACK = [Any]

abstract type Capability end

abstract type _Cap_defaults <: Capability end
struct _Cap_rand <: _Cap_defaults end
struct _Cap_io <: _Cap_defaults end

struct IncapableError <: Exception
    message::String
end

# To run the capability-constrained function, make sure that its specified
# capabilities is a subtype of the current capabilities.
function _check_cap(func::Symbol, capabilities::Type)
    if !isempty(CAP_STACK)
        T = last(CAP_STACK)
        S = capabilities
        S <: T || throw(IncapableError("$func missing capability: $S not a subtype of $T"))
    end
end

# Make sure that `capabilities` becomes the current capabilities.
# Then, execute the function.
function _run(f::Function, capabilities::Type)
    try
        push!(CAP_STACK, capabilities)
        f()
    finally
        pop!(CAP_STACK)
    end
end

_cap_type_symbol(x::Symbol) = Symbol("_Cap_$x")

"""
    @cap [CapName1, CapName2, ...] <function-def>

Declare a function such that it requires the specified capabilities in the
list.

# Example
```
@cap [io] function writeData(x)
    open("rand.dat", "w") do io
        write(io, x)
    end
end

@cap [rand] rand10() = rand() * 10

@cap [rand, io] function writeRandomData()
    writeData(rand10())
end
```
"""
macro cap(vec::Expr, ex::Expr)
    # Make a union type that includes all specified capabilities
    syms = Any[_cap_type_symbol(x) for x in vec.args]
    pushfirst!(syms, :Union)
    captype = Expr(:curly, syms...)

    def = splitdef(ex)
    mycap = gensym()
    name = QuoteNode(get(def, :name, :anonymous))
    def[:body] = quote
        $mycap = $captype
        Capabilities._check_cap($name, $mycap)
        Capabilities._run($mycap) do
            $(def[:body])
        end
    end
    newdef = combinedef(def)
    return esc(newdef)
end

"""
    @defcap <CapName>

Defines a new capability with the provided name. After this, use `@cap`
macro to define functions that refer to the same capability.

# Example
```
@defcap secret
```
"""
macro defcap(name)
    name isa Symbol || error("Syntax error: @defcap <name>")
    cap_name = _cap_type_symbol(name)
    return quote
        struct $cap_name <: Capabilities.Capability end
    end
end

end
