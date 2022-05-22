using Capabilities: Capabilities, @defcap, @cap, @importcap, IncapableError
using Test

@importcap Capabilities [rand, io]
@defcap secret

@testset "Capabilities.jl" begin

    @testset "Positive tests" begin
        @cap [rand, io] foo() = bar()
        @cap [rand] bar() = rand()
        @test_nowarn foo()  # foo has more capabilities

        # anon function
        lambda = @cap([rand, io], () -> rand())
        @test_nowarn lambda()
    end

    @testset "Negative tests" begin
        @cap [rand] baz() = wat()
        @cap [secret] wat() = 2
        @test_throws IncapableError baz()
    end
end
