
using Test
using VkComputeUtils
using Vulkan
import SwiftShader_jll

if !haskey(ENV, "VKCOMPUTEUTILS_RUN_ON_GPU")
    @set_driver :SwiftShader
end

@testset "VkComputeUtils tests" begin
    include("simple_shader.jl")
end
