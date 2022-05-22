abstract type Capability end

struct IncapableError <: Exception
    message::String
end
