[![Build Status](https://github.com/tk3369/Capabilities.jl/workflows/CI/badge.svg)](https://github.com/tk3369/Capabilities.jl/actions?query=workflow%3ACI)
[![codecov.io](http://codecov.io/github/tk3369/Capabilities.jl/coverage.svg?branch=master)](http://codecov.io/github/tk3369/Capabilities.jl?branch=master)
![Project Status](https://img.shields.io/badge/status-experimental-red)

# Capabilities

This is an experimental package that allows one to declare capabilities for functions.

# Demo

```julia
# Call a function with a subset of capabilities
@cap [rand, io] foo() = bar()
@cap [rand] bar() = rand()
@test_nowarn foo()

# The same thing works for anonymous functions.
f = @cap([rand, io], () -> bar())
@test_nowarn f()
```

Negative cases:
```julia
# Not allowed to call a function with a different set of capabilities.
@cap [rand] baz() = wat()
@cap [secret] wat() = 2
@test_throws IncapableError baz()

# Not allowed to call a funciton with more capabilities
@cap [super_secret] ss() = wat()
@test_throws IncapableError ss()Z
```

# Some diagrams
https://excalidraw.com/#room=b87c9504db957a6daa32,5eN5TXo2vQRfk3hOo8sLMw
