
"""
    ComputeShaderPipeline(device, shader_code, n_buffers, spec_consts, push_constant_type::Type)

Create a [`ComputeShaderPipeline`](@ref) wrapper around the required tooling
around the shader on the `device`. `shader_code` is compiled to SPIR-V using
glslang and specialized using `spec_consts` to make a pipeline with a prepared
descriptor sets and layouts for `n_buffers` storage buffers, accepting push
constants of `push_constant_type`.
"""
function ComputeShaderPipeline(
    device,
    shader_code,
    n_buffers,
    spec_consts::Tuple,
    push_constant_type::Type,
)
    glslang = glslangValidator(
        bin -> open(
            `$bin -V --quiet --stdin -S comp -o /dev/stdout `,
            read = true,
            write = true,
        ),
    )
    write(glslang, shader_code)
    close(glslang.in)
    shader_bcode = collect(reinterpret(UInt32, read(glslang)))
    close(glslang)
    glslang.exitcode == 0 ||
        error("Shader compilation failed (glslangValidator status: $(glslang.exitcode))")

    # the constant in the next line really hurt a lot
    shader = ShaderModule(device, 4 * length(shader_bcode), shader_bcode)

    dsl = DescriptorSetLayout(
        device,
        DescriptorSetLayoutBinding.(
            0:(n_buffers-1),
            DESCRIPTOR_TYPE_STORAGE_BUFFER,
            1,
            SHADER_STAGE_COMPUTE_BIT,
            Ref(Sampler[]),
        ),
    )

    pl = PipelineLayout(
        device,
        [dsl],
        [PushConstantRange(SHADER_STAGE_COMPUTE_BIT, 0, sizeof(push_constant_type))],
    )

    consts = [spec_consts]
    const_sizes = collect(sizeof.(spec_consts))
    spec_entries =
        SpecializationMapEntry.(
            0:length(spec_consts)-1,
            vcat([0], cumsum(const_sizes))[begin:end-1],
            const_sizes,
        )
    pcis = [
        ComputePipelineCreateInfo(
            PipelineShaderStageCreateInfo(
                SHADER_STAGE_COMPUTE_BIT,
                shader,
                "main",
                specialization_info = SpecializationInfo(
                    spec_entries,
                    UInt64(sizeof(spec_consts)),
                    Ptr{UInt8}(pointer(consts)),
                ),
            ),
            pl,
            -1,
        ),
    ]

    p = first(first(unwrap(create_compute_pipelines(device, pcis))))

    dpool = DescriptorPool(
        device,
        1,
        [DescriptorPoolSize(DESCRIPTOR_TYPE_STORAGE_BUFFER, n_buffers)],
    )

    dsets =
        unwrap(allocate_descriptor_sets(device, DescriptorSetAllocateInfo(dpool, [dsl])))

    return ComputeShaderPipeline{push_constant_type,n_buffers}(
        shader,
        dsl,
        pl,
        p,
        dpool,
        dsets,
    )
end

"""
    write_descriptor_set_buffers(device, csp::ComputeShaderPipeline{PushConstsT, NBuffers}, buffers::Vector{Buffer}) where {PushConstsT,NBuffers}

Write a set of Vulkan Buffers to the descriptor set stored in `csp`.
"""
function write_descriptor_set_buffers(
    device,
    csp::ComputeShaderPipeline{PushConstsT,NBuffers},
    buffers::Vector{Buffer},
) where {PushConstsT,NBuffers}
    length(buffers) == NBuffers || throw(DomainError(buffers, "Wrong number of buffers"))
    update_descriptor_sets(
        device,
        [
            WriteDescriptorSet(
                first(csp.descriptor_sets),
                0,
                0,
                DESCRIPTOR_TYPE_STORAGE_BUFFER,
                [],
                [DescriptorBufferInfo(buffer, 0, WHOLE_SIZE) for buffer in buffers],
                [],
            ),
        ],
        [],
    )
end

"""
    hold_push_constants(t::T, args...)
    hold_push_constants(csp::ComputeShaderPipeline{PushConstsT, NBuffers}, args...) where{PushConstsT, NBuffers}

A simple helper to create a "holding" structure for the push constants.
"""
hold_push_constants(
    csp::ComputeShaderPipeline{PushConstsT,NBuffers},
    args...,
) where {PushConstsT,NBuffers} = PushConstantsHolder{PushConstsT}([PushConstsT(args...)])

"""
    cmd_bind_dispatch(cmd_buffer, csp::ComputeShaderPipeline{PushConstsT, NBuffers}, push_constants::PushConstsT, x::Int, y::Int, z::Int) where{PushConstsT, NBuffers}

Write commands that properly push the constants, bind the descriptor sets and
dispatch the shader over the workgroup of dimensions `(x,y,z)` to the command
buffer `cmd_buffer`.
"""
function cmd_bind_dispatch(
    cmd_buffer,
    csp::ComputeShaderPipeline{PushConstsT,NBuffers},
    push_constants::PushConstantsHolder{PushConstsT},
    x::Int,
    y::Int,
    z::Int,
) where {PushConstsT,NBuffers}
    cmd_bind_pipeline(cmd_buffer, PIPELINE_BIND_POINT_COMPUTE, csp.pipeline)
    cmd_push_constants(
        cmd_buffer,
        csp.pipeline_layout,
        SHADER_STAGE_COMPUTE_BIT,
        0,
        sizeof(PushConstsT),
        Ptr{Nothing}(pointer(push_constants.x)),
    )
    cmd_bind_descriptor_sets(
        cmd_buffer,
        PIPELINE_BIND_POINT_COMPUTE,
        csp.pipeline_layout,
        0,
        csp.descriptor_sets,
        [],
    )
    cmd_dispatch(cmd_buffer, x, y, z)
end
