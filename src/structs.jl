
"""
    struct ComputeShaderPipeline{PushConstsT, NBuffers}

An overarching structure that holds everything needed to run a single
compute-only pipeline: the shader, descriptor set and pipeline layouts, the
pipeline, a single small descriptor pool, and the descriptor sets.
"""
struct ComputeShaderPipeline{PushConstsT,NBuffers}
    shader::ShaderModule
    descriptor_set_layout::DescriptorSetLayout
    pipeline_layout::PipelineLayout
    pipeline::Pipeline
    descriptor_pool::DescriptorPool
    descriptor_sets::Vector{DescriptorSet}
end

"""
    struct PushConstantsHolder{PushConstsT}

A holder for the push-constants value that holds it static while being pointed to by command buffer functions.
"""
struct PushConstantsHolder{PushConstsT}
    x::Ref{PushConstsT}
end
