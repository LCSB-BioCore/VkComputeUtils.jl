
# VkComputeUtils.jl

This package simplifies the work with some most basic and repetitive
boilerplate-ish coding that is required to run "pure" Vulkan compute apps.

We attempt not to impose any kind of framework for the computation, instead
providing a library of small helpers that automate the boring parts. The use is
best documented by the examples in the test suite, for example [the simple
shader
test](https://github.com/LCSB-BioCore/VkComputeUtils.jl/blob/master/test/simple_shader.jl)
that reproduces the ["minimal working compute"
tutorial](https://juliagpu.github.io/Vulkan.jl/stable/tutorial/minimal_working_compute/)
from Vulkan.jl.

Here, we highlight the main parts.

## Choosing suitable facilities

Finding of vital choices of hardware and queues is implemented using functions
that take a predicate and a scoring function and return the best-scoring match
that satisfies the predicate. This way, you can e.g. select a "physical GPU
with most memory available", etc.

### Finding a good physical device

To find a good physical device, use [`find_physical_device`](@ref). This
example will return the first physical device that contains the name of your
favorite vendor in the device name:

```julia
physical_device = find_physical_device(
instance,
check = props -> contains(props.device_name, "MyFavoriteVendor"),
)
```

### Finding a queue family index

Similarly, [`find_queue_family_idx`](@ref) is used to find suitable queue
families. This example finds a compute queue family with greatest amount of
queues:

```julia
qfam_idx = find_queue_family_idx(
    physical_device,
    check = qfp -> hasbits(qfp.queue_flags, QUEUE_COMPUTE_BIT),
    score = qfp -> qfp.queue_count,
)
```

### Finding a memory type

Once more, the same scheme is used for finding suitable memory types, except
the predicate and scoring functions may also examine the memory heap
properties. This finds a device-local memory type with the largest heap:

```julia
    memorytype_local_visible = find_memory_type_idx(
        physical_device,
        check = (mt, heap) -> hasbits(
            mt.property_flags,
            MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
        ),
        score = (mt, heap) -> heap.size,
    )
```

### Compiling compute shaders into pipelines

The framework around the compute shader (pipeline layout, descriptor set
layout, pipeline, descriptor pool, descriptor set) is grouped within a
[`ComputeShaderPipeline`](@ref) structure. To create one, use the constructor as follows:

```julia
example_shader = """
layout (local_size_x = 1024) in;

layout (push_constant) uniform Params
{
  uint n;
} params;

layout(std430, binding=0) buffer databuf
{
  float data[];
};

void main()
{
  uint i = gl_GlobalInvocationID.x;
  if(i < params.n) data[i] = 123456;
}
"""

shader = ComputeShaderPipeline(
    device, # created by create_device
    example_shader, # the shader code, will be compiled with glslangValidator
    1, # there's 1 buffer binding
    (), # there are no specialization constants
    UInt32, # this is the type of the push constants in the shader
)
```

You can now easily bind your buffers with allocated memory to the shader pipeline:

```julia
write_descriptor_set_buffers(device, shader, [mybuffer])
```

Later, you may easily add the commandbuffer entries for binding the pipeline,
pushing the constants, binding the descriptor sets, and dispatching the
pipeline in one call:

```julia
    cmd_bind_dispatch(
        command_buffer, # created with allocate_command_buffers and "started" with begin_command_buffer
        shader, # created with ComputeShaderPipeline, as above
        UInt32(my_n_items), # the contents of push constants (size of your buffer)
        n_blocks(my_n_items, 1024), # number of workgroups ("threadblocks") in x direction
        1, # same for y
        1, # z
    )
```
