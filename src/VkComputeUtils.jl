module VkComputeUtils

using Vulkan
using glslang_jll

include("structs.jl")
include("find.jl")
include("csp.jl")
include("utils.jl")

# export everything that isn't prefixed with _ (inspired by JuMP.jl, thanks!)
for sym in names(@__MODULE__, all = true)
    if sym in [Symbol(@__MODULE__), :eval, :include] || startswith(string(sym), ['_', '#'])
        continue
    end
    @eval export $sym
end

end # module
