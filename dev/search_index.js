var documenterSearchIndex = {"docs":
[{"location":"functions/#Data-types","page":"Reference","title":"Data types","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [VkComputeUtils]\nPages = [\"structs.jl\"]","category":"page"},{"location":"functions/#VkComputeUtils.ComputeShaderPipeline","page":"Reference","title":"VkComputeUtils.ComputeShaderPipeline","text":"struct ComputeShaderPipeline{PushConstsT, NBuffers}\n\nAn overarching structure that holds everything needed to run a single compute-only pipeline: the shader, descriptor set and pipeline layouts, the pipeline, a single small descriptor pool, and the descriptor sets.\n\n\n\n\n\n","category":"type"},{"location":"functions/#VkComputeUtils.PushConstantsHolder","page":"Reference","title":"VkComputeUtils.PushConstantsHolder","text":"struct PushConstantsHolder{PushConstsT}\n\nA holder for the push-constants value that holds it static while being pointed to by command buffer functions.\n\n\n\n\n\n","category":"type"},{"location":"functions/#Facility-discovery","page":"Reference","title":"Facility discovery","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [VkComputeUtils]\nPages = [\"find.jl\"]","category":"page"},{"location":"functions/#VkComputeUtils.find_memory_type_idx-Tuple{Any}","page":"Reference","title":"VkComputeUtils.find_memory_type_idx","text":"find_memory_type_idx(physical_device; check::Function=(_,_)->true, score::Function=(_,_)->0)\n\nFind a memory type index (numbered from 0) for a physical device that satisfies some given properties. The arguments check and score behave as with find_scored_idx, but take 2 arguments with types MemoryType and MemoryHeap.\n\nExample\n\n# Find a host visible and device local memory type with largest heap\nfind_memory_type_idx(physical_device,\n    check=(mt, heap) -> hasbits(mt.property_flags, MEMORY_PROPERTY_HOST_VISIBLE_BIT|MEMORY_PROPERTY_DEVICE_LOCAL_BIT),\n    score=(mt, heap) -> heap.size,\n)\n\n\n\n\n\n","category":"method"},{"location":"functions/#VkComputeUtils.find_physical_device-Tuple{Any}","page":"Reference","title":"VkComputeUtils.find_physical_device","text":"find_physical_device(instance; args...)\n\nFind a physical device within the instance that satisfies some given properties; arguments are forwarded to find_scored_idx.\n\nExample\n\nphysical_device = find_physical_device(instance, check=props->contains(props.device_name, \"MyFavVendor\"))\n\n\n\n\n\n","category":"method"},{"location":"functions/#VkComputeUtils.find_queue_family_idx-Tuple{Any}","page":"Reference","title":"VkComputeUtils.find_queue_family_idx","text":"find_queue_family_idx(physical_device; args...)\n\nFind a queue family index (numbered from 0) for a physical device that satisfies some given properties; arguments are forwarded to find_scored_idx.\n\nExample\n\n# Find a queue family with most queues that supports compute and transfer operations.\nfind_queue_family_idx(physical_device, \n    check=qfp->hasbits(qfp.queue_flags, QUEUE_TRANSFER_BIT | QUEUE_COMPUTE_BIT),\n    score=qfp->qfp.queue_count,\n)\n\n\n\n\n\n","category":"method"},{"location":"functions/#VkComputeUtils.find_scored_idx-Tuple{Any, String}","page":"Reference","title":"VkComputeUtils.find_scored_idx","text":"find_scored_idx(collection, what::String; check::Function=_->true, score::Function=_->0)\n\nA helper function that runs through a collection and select an item that satisfies the predicate check with best score computed by score. If no suitable item is found, an error is thrown referring to the item type as what.\n\n\n\n\n\n","category":"method"},{"location":"functions/#Compute-shader-pipelines","page":"Reference","title":"Compute shader pipelines","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [VkComputeUtils]\nPages = [\"csp.jl\"]","category":"page"},{"location":"functions/#VkComputeUtils.ComputeShaderPipeline-Tuple{Any, Any, Any, Tuple, Type}","page":"Reference","title":"VkComputeUtils.ComputeShaderPipeline","text":"ComputeShaderPipeline(device, shader_code, n_buffers, spec_consts, push_constant_type::Type)\n\nCreate a ComputeShaderPipeline wrapper around the required tooling around the shader on the device. shader_code is compiled to SPIR-V using glslang and specialized using spec_consts to make a pipeline with a prepared descriptor sets and layouts for n_buffers storage buffers, accepting push constants of push_constant_type.\n\n\n\n\n\n","category":"method"},{"location":"functions/#VkComputeUtils.cmd_bind_dispatch-Union{Tuple{NBuffers}, Tuple{PushConstsT}, Tuple{Any, ComputeShaderPipeline{PushConstsT, NBuffers}, PushConstantsHolder{PushConstsT}, Int64, Int64, Int64}} where {PushConstsT, NBuffers}","page":"Reference","title":"VkComputeUtils.cmd_bind_dispatch","text":"function cmd_bind_dispatch(\n    cmd_buffer,\n    csp::ComputeShaderPipeline{PushConstsT,NBuffers},\n    push_constants::PushConstantsHolder{PushConstsT},\n    x::Int,\n    y::Int,\n    z::Int,\n) where {PushConstsT,NBuffers}\n\nWrite commands that properly push the constants, bind the descriptor sets and dispatch the shader over the workgroup of dimensions (x,y,z) to the command buffer cmd_buffer.\n\n\n\n\n\n","category":"method"},{"location":"functions/#VkComputeUtils.hold_push_constants-Union{Tuple{NBuffers}, Tuple{PushConstsT}, Tuple{ComputeShaderPipeline{PushConstsT, NBuffers}, Vararg{Any}}} where {PushConstsT, NBuffers}","page":"Reference","title":"VkComputeUtils.hold_push_constants","text":"hold_push_constants(t::T, args...)\nhold_push_constants(csp::ComputeShaderPipeline{PushConstsT, NBuffers}, args...) where{PushConstsT, NBuffers}\n\nA simple helper to create a \"holding\" structure for the push constants.\n\n\n\n\n\n","category":"method"},{"location":"functions/#VkComputeUtils.write_descriptor_set_buffers-Union{Tuple{NBuffers}, Tuple{PushConstsT}, Tuple{Any, ComputeShaderPipeline{PushConstsT, NBuffers}, Vector{Vulkan.Buffer}}} where {PushConstsT, NBuffers}","page":"Reference","title":"VkComputeUtils.write_descriptor_set_buffers","text":"write_descriptor_set_buffers(device, csp::ComputeShaderPipeline{PushConstsT, NBuffers}, buffers::Vector{Buffer}) where {PushConstsT,NBuffers}\n\nWrite a set of Vulkan Buffers to the descriptor set stored in csp.\n\n\n\n\n\n","category":"method"},{"location":"functions/#Utilities","page":"Reference","title":"Utilities","text":"","category":"section"},{"location":"functions/","page":"Reference","title":"Reference","text":"Modules = [VkComputeUtils]\nPages = [\"utils.jl\"]","category":"page"},{"location":"functions/#VkComputeUtils.hasbits-Tuple{Any, Any}","page":"Reference","title":"VkComputeUtils.hasbits","text":"hasbits(flags, required)\n\nCheck that all required bits are present in flags. Non-shortcut for in.\n\n\n\n\n\n","category":"method"},{"location":"functions/#VkComputeUtils.hasbits-Tuple{Any}","page":"Reference","title":"VkComputeUtils.hasbits","text":"hasbits(required)\n\nConvenience function that checks if something has the required bits. Uses the other methods of hasbits.\n\n\n\n\n\n","category":"method"},{"location":"functions/#VkComputeUtils.n_blocks","page":"Reference","title":"VkComputeUtils.n_blocks","text":"n_blocks(x,bs)\n\nHow many blocks of size bs are needed to process x items? Shortcut for div with RoundUp aka cld.\n\n\n\n\n\n","category":"function"},{"location":"#VkComputeUtils.jl","page":"Home","title":"VkComputeUtils.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package simplifies the work with some most basic and repetitive boilerplate-ish coding that is required to run \"pure\" Vulkan compute apps.","category":"page"},{"location":"","page":"Home","title":"Home","text":"We attempt not to impose any kind of framework for the computation, instead providing a library of small helpers that automate the boring parts. The use is best documented by the examples in the test suite, for example the simple shader test that reproduces the \"minimal working compute\" tutorial from Vulkan.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Here, we highlight the main parts.","category":"page"},{"location":"#Choosing-suitable-facilities","page":"Home","title":"Choosing suitable facilities","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Finding of vital choices of hardware and queues is implemented using functions that take a predicate and a scoring function and return the best-scoring match that satisfies the predicate. This way, you can e.g. select a \"physical GPU with most memory available\", etc.","category":"page"},{"location":"#Finding-a-good-physical-device","page":"Home","title":"Finding a good physical device","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To find a good physical device, use find_physical_device. This example will return the first physical device that contains the name of your favorite vendor in the device name:","category":"page"},{"location":"","page":"Home","title":"Home","text":"physical_device = find_physical_device(\n    instance,\n    check = props -> contains(props.device_name, \"MyFavoriteVendor\"),\n)","category":"page"},{"location":"#Finding-a-queue-family-index","page":"Home","title":"Finding a queue family index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Similarly, find_queue_family_idx is used to find suitable queue families. This example finds a compute queue family with greatest amount of queues:","category":"page"},{"location":"","page":"Home","title":"Home","text":"qfam_idx = find_queue_family_idx(\n    physical_device,\n    check = qfp -> hasbits(qfp.queue_flags, QUEUE_COMPUTE_BIT),\n    score = qfp -> qfp.queue_count,\n)","category":"page"},{"location":"#Finding-a-memory-type","page":"Home","title":"Finding a memory type","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Once more, the same scheme is used for finding suitable memory types, except the predicate and scoring functions may also examine the memory heap properties. This finds a device-local memory type with the largest heap:","category":"page"},{"location":"","page":"Home","title":"Home","text":"memorytype_local_visible = find_memory_type_idx(\n    physical_device,\n    check = (mt, heap) -> hasbits(\n        mt.property_flags,\n        MEMORY_PROPERTY_DEVICE_LOCAL_BIT,\n    ),\n    score = (mt, heap) -> heap.size,\n)","category":"page"},{"location":"#Compiling-compute-shaders-into-pipelines","page":"Home","title":"Compiling compute shaders into pipelines","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The framework around the compute shader (pipeline layout, descriptor set layout, pipeline, descriptor pool, descriptor set) is grouped within a ComputeShaderPipeline structure. To create one, use the constructor as follows:","category":"page"},{"location":"","page":"Home","title":"Home","text":"example_shader = \"\"\"\nlayout (local_size_x = 1024) in;\n\nlayout (push_constant) uniform Params\n{\n  uint n;\n} params;\n\nlayout(std430, binding=0) buffer databuf\n{\n  float data[];\n};\n\nvoid main()\n{\n  uint i = gl_GlobalInvocationID.x;\n  if(i < params.n) data[i] = 123456;\n}\n\"\"\"\n\nshader = ComputeShaderPipeline(\n    device, # created by create_device\n    example_shader, # the shader code, will be compiled with glslangValidator\n    1, # there's 1 buffer binding\n    (), # there are no specialization constants\n    UInt32, # this is the type of the push constants in the shader\n)","category":"page"},{"location":"#Using-the-compiled-shader","page":"Home","title":"Using the compiled shader","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"You can now easily bind your buffers with allocated memory to the shader pipeline:","category":"page"},{"location":"","page":"Home","title":"Home","text":"write_descriptor_set_buffers(device, shader, [mybuffer])","category":"page"},{"location":"","page":"Home","title":"Home","text":"Later, you may easily add the command buffer entries for binding the pipeline, pushing the constants, binding the descriptor sets, and dispatching the pipeline in one call:","category":"page"},{"location":"","page":"Home","title":"Home","text":"consts = hold_push_constants(shader, my_n_items) # materializes the push constants (this should not be GC'd)\n\ncmd_bind_dispatch(\n    command_buffer, # created with allocate_command_buffers and \"started\" with begin_command_buffer\n    shader, # created with ComputeShaderPipeline, as above\n    consts, # push constants data\n    n_blocks(my_n_items, 1024), # number of workgroups (\"threadblocks\") in x direction\n    1, # same for y\n    1, # z\n)","category":"page"},{"location":"#Viewing-the-host-accessible-memory","page":"Home","title":"Viewing the host-accessible memory","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The mapped Vulkan memory can be viewed through Julia vectors, using some minor unsafe assumptions. map_memory_as_vector manages the conversion using properly \"typed\" offsets and sizes:","category":"page"},{"location":"","page":"Home","title":"Home","text":"my_vector = map_memory_as_vector(device, someMemory, 0, 100, Float32)\n\nlength(my_vector) == 100\neltype(my_vector) == Float32\n\nmy_vector .= 0 #zero out the Vulkan memory","category":"page"}]
}
