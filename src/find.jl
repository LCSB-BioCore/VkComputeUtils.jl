
"""
    find_scored_idx(collection, what::String; check::Function=_->true, score::Function=_->0)

A helper function that runs through a `collection` and select an item that
satisfies the predicate `check` with best score computed by `score`. If no
suitable item is found, an error is thrown referring to the item type as
`what`.
"""
function find_scored_idx(
    collection,
    what::String;
    check::Function = _ -> true,
    score::Function = _ -> 0,
)
    found = 0
    found_score = -Inf
    for (idx, obj) in enumerate(collection)
        if check(obj)
            s = score(obj)
            if s > found_score
                found = idx
                found_score = s
            end
        end
    end
    found > 0 || error("No suitable $what found")
    return found
end

"""
    find_physical_device(instance; args...)

Find a physical device within the instance that satisfies some given
properties; arguments are forwarded to [`find_scored_idx`](@ref).

# Example

    physical_device = find_physical_device(instance, check=props->contains(props.device_name, "MyFavVendor"))
"""
function find_physical_device(instance; args...)
    devs = unwrap(enumerate_physical_devices(instance))
    return devs[find_scored_idx(
        get_physical_device_properties.(devs),
        "physical device";
        args...,
    )]
end

"""
    find_queue_family_idx(physical_device; args...)

Find a queue family index (numbered from 0) for a physical device that
satisfies some given properties; arguments are forwarded to
[`find_scored_idx`](@ref).

# Example

    # Find a queue family with most queues that supports compute and transfer operations.
    find_queue_family_idx(physical_device, 
        check=qfp->hasbits(qfp.queue_flags, QUEUE_TRANSFER_BIT | QUEUE_COMPUTE_BIT),
        score=qfp->qfp.queue_count,
    )
"""
find_queue_family_idx(physical_device; args...) =
    find_scored_idx(
        get_physical_device_queue_family_properties(physical_device),
        "queue family";
        args...,
    ) - 1

"""
    find_memory_type_idx(physical_device; check::Function=(_,_)->true, score::Function=(_,_)->0)

Find a memory type index (numbered from 0) for a physical device that satisfies
some given properties. The arguments `check` and `score` behave as with
[`find_scored_idx`](@ref), but take 2 arguments with types `MemoryType` and
`MemoryHeap`.

# Example

    # Find a host visible and device local memory type with largest heap
    find_memory_type_idx(physical_device,
        check=(mt, heap) -> hasbits(mt.property_flags, MEMORY_PROPERTY_HOST_VISIBLE_BIT|MEMORY_PROPERTY_DEVICE_LOCAL_BIT),
        score=(mt, heap) -> heap.size,
    )
    
"""
function find_memory_type_idx(
    physical_device;
    check::Function = (_, _) -> true,
    score::Function = (_, _) -> 0,
)
    props = get_physical_device_memory_properties(physical_device)
    return find_scored_idx(
        props.memory_types[1:props.memory_type_count],
        "memory type";
        check = mt -> check(mt, props.memory_heaps[mt.heap_index+1]),
        score = mt -> score(mt, props.memory_heaps[mt.heap_index+1]),
    ) - 1
end
