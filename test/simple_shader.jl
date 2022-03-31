
@testset "Simple shader execution" begin
    instance = Instance([], [])

    physical_device = find_physical_device(
        instance,
        check = props ->
            contains(props.device_name, get(ENV, "VKCOMPUTEUTILS_GPU", "SwiftShader")),
    )

    @test physical_device isa PhysicalDevice

    @test_throws ErrorException find_queue_family_idx(physical_device, check = _ -> false)

    qfam_idx = find_queue_family_idx(
        physical_device,
        check = qfp -> hasbits(qfp.queue_flags, QUEUE_TRANSFER_BIT | QUEUE_COMPUTE_BIT),
        score = qfp -> qfp.queue_count,
    )

    device = Device(physical_device, [DeviceQueueCreateInfo(qfam_idx, [1.0])], [], [])

    @test device isa Device

    memorytype_local_visible = find_memory_type_idx(
        physical_device,
        check = (mt, _) -> hasbits(
            mt.property_flags,
            MEMORY_PROPERTY_HOST_VISIBLE_BIT | MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
        ),
        score = (_, heap) -> heap.size,
    )

    items = 100
    mem_size = sizeof(Float32) * items

    buffer = Buffer(
        device,
        mem_size,
        BUFFER_USAGE_STORAGE_BUFFER_BIT,
        SHARING_MODE_EXCLUSIVE,
        [qfam_idx],
    )
    @test buffer isa Buffer

    mem = DeviceMemory(device, mem_size, memorytype_local_visible)
    @test mem isa DeviceMemory

    data = map_memory_as_vector(device, mem, 0, items, Float32)
    data .= 0
    unwrap(flush_mapped_memory_ranges(device, [MappedMemoryRange(mem, 0, mem_size)]))

    bind_buffer_memory(device, buffer, mem, 0)

    struct shader_push_consts
        val::Float32
        n::UInt32
    end

    shader_code = """
    #version 430

    layout (local_size_x_id = 0) in;
    layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

    layout(constant_id = 0) const uint blocksize = 1; // copy of local_size_x

    layout (push_constant) uniform Params
    {
        float val;
        uint n;
    } params;

    layout(std430, binding=0) buffer databuf
    {
        float data[];
    };

    void
    main()
    {
        uint i = gl_GlobalInvocationID.x;
        if(i < params.n) data[i] = params.val * i;
    }
    """

    const_local_size_x = UInt32(32)
    csp = ComputeShaderPipeline(
        device,
        shader_code,
        1,
        (const_local_size_x,),
        shader_push_consts,
    )
    @test csp isa ComputeShaderPipeline{shader_push_consts,1}

    cmdpool = CommandPool(device, qfam_idx)
    cbufs = unwrap(
        allocate_command_buffers(
            device,
            CommandBufferAllocateInfo(cmdpool, COMMAND_BUFFER_LEVEL_PRIMARY, 1),
        ),
    )
    cbuf = first(cbufs)

    compute_q = get_device_queue(device, qfam_idx, 0)

    write_descriptor_set_buffers(device, csp, [buffer])

    begin_command_buffer(
        cbuf,
        CommandBufferBeginInfo(flags = COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT),
    )

    some_val = 1.2345
    push_consts = hold_push_constants(csp, some_val, items)

    cmd_bind_dispatch(cbuf, csp, push_consts, n_blocks(items, const_local_size_x), 1, 1)
    end_command_buffer(cbuf)

    queue_submit(compute_q, [SubmitInfo([], [], [cbuf], [])])
    GC.@preserve csp push_consts cbuf begin
        unwrap(queue_wait_idle(compute_q))
    end

    unwrap(invalidate_mapped_memory_ranges(device, [MappedMemoryRange(mem, 0, mem_size)]))

    @test isapprox(data, some_val .* (0:items-1))
end
