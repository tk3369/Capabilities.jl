# Define some standard, useful capabilities.

#=
Privacy can be respected when data is restricted from being read/written.

For example, a function without `io_write` is safe to call without worrying
about user data being leaked to a database used for unintended purposes.
Likewise, a function without `io_read` is safe to call without worrying
that it might have ingested data from a sensitive data store.

I can imagine that someone defines sub-capability types further, for example:
```
@defcap io_marketing <: io
@defcap io_user_profile <: io
```

Then, a function having `io_user_profile` would not be able to call a function
that writes data to a marketing database.
=#
@defcap io <: defaults
@defcap io_read <: io
@defcap io_write <: io

# This is mostly an example.
@defcap rand <: defaults

