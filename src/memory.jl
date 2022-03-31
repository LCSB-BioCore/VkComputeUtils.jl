
"""
    map_memory_vector(device, memory, offset::Int, length::Int, T::Type)

Given a `memory` that contains `length` items of type `T` at the `offset`,
return a Julia vector that points to the chosen range of the memory.

Mapped memory may need to be manually invalidated (before reading) or flushed
(after writing).
"""
map_memory_as_vector(device, memory, offset::Int, length::Int, T::Type) = unsafe_wrap(
    Vector{T},
    convert(
        Ptr{T},
        unwrap(map_memory(device, memory, offset * sizeof(T), length * sizeof(T))),
    ),
    length,
    own = false,
)

# TODO with_mapped_memory :]
