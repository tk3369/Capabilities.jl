"This is the top level capabilities (super power!)"
abstract type _Cap_defaults end
struct IncapableError <: Exception
    message::String
end
