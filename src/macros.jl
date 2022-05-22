# To run the capability-constrained function, make sure that its specified
# capabilities is a subtype of the current capabilities. Always throw exception
# when the check failed. Returns nothing.
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

function _resolve_cap_type(m::Module, x::Symbol)
    # @info "Resolving" m x
    @eval(m, $(_cap_type_symbol(x)))
end

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
macro cap(spec, ex::Expr)
    # First argument of the macro must be written like a vector
    if !(spec isa Expr) || spec.head !== :vect
        throw(ArgumentError("Invalid capabilities spec: $spec. It must be written like a vector e.g. [rand]"))
    end
    # Make a union type that includes all specified capabilities
    syms = Any[_cap_type_symbol(x) for x in spec.args]
    pushfirst!(syms, :Union)
    captype = Expr(:curly, syms...)
    # Compose function definition
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
    newdef = esc(combinedef(def))
    # Referencing captype in the definition helps validate the existance of the type
    return Expr(:block, esc(captype), newdef)
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
macro defcap(name, parent=Capabilities.Capability)
    name isa Symbol || error("Syntax error: @defcap <name>")
    cap_name = _cap_type_symbol(name)
    if parent isa Symbol
        parent = _resolve_cap_type(__module__, parent)
    end
    return esc(quote
        abstract type $cap_name <: $parent end
    end)
end

#=
Here's the AST for using statement:

julia> :(using Foo: bar, baz) |> dump
Expr
  head: Symbol using
  args: Array{Any}((1,))
    1: Expr
      head: Symbol :
      args: Array{Any}((3,))
        1: Expr
          head: Symbol .
          args: Array{Any}((1,))
            1: Symbol Foo
        2: Expr
          head: Symbol .
          args: Array{Any}((1,))
            1: Symbol bar
        3: Expr
          head: Symbol .
          args: Array{Any}((1,))
            1: Symbol baz
=#
macro importcap(mod, names)
    names = _cap_type_symbol.(names.args)
    args = Any[Expr(:(.), name) for name in names]
    pushfirst!(args, Expr(:(.), mod))
    return Expr(:using, Expr(:(:), args...))
end