abstract type _Cap_Capability end

struct IncapableError <: Exception
    message::String
end
