using Capabilities: Capabilities, @defcap, @cap, IncapableError
using Capabilities: _Cap_io, _Cap_rand
using Test

@defcap secret
# @defcap rand
# @defcap io

@testset "Capabilities.jl" begin

    @testset "Positive tests" begin
        @cap [rand, io] foo() = bar()
        @cap [rand] bar() = rand()
        @test_nowarn foo()  # foo has more capabilities
    end

    @testset "Negative tests" begin
        @cap [rand] baz() = wat()
        @cap [secret] wat() = 2
        @test_throws IncapableError baz()
    end
end
