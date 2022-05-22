using Capabilities: Capabilities, @defcap, @cap, @importcap, IncapableError
using Test

@importcap Capabilities [rand, io]
@defcap secret
@defcap super_secret secret

@testset "Capabilities.jl" begin

    @testset "Positive tests" begin
        # Call a function with a subset of capabilities
        @cap [rand, io] foo() = bar()
        @cap [rand] bar() = rand()
        @test_nowarn foo()

        # The same thing works for anonymous functions.
        f = @cap([rand, io], () -> bar())
        @test_nowarn f()
    end

    @testset "Negative tests" begin
        # Not allowed to call a function with a different set of capabilities.
        @cap [rand] baz() = wat()
        @cap [secret] wat() = 2
        @test_throws IncapableError baz()

        # Not allowed to call a funciton with more capabilities
        @cap [super_secret] ss() = wat()
        @test_throws IncapableError ss()
    end
end
