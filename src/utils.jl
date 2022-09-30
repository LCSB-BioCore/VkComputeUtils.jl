
"""
    n_blocks(x,bs)

How many blocks of size `bs` are needed to process `x` items? Shortcut for
`div` with `RoundUp` aka `cld`.
"""
const n_blocks = cld

"""
    hasbits(flags, required) 

Check that all `required` bits are present in `flags`. Non-shortcut for `in`.
"""
hasbits(flags, required) = required in flags

"""
    hasbits(required)

Convenience function that checks if something has the `required` bits. Uses the other methods of [`hasbits`](@ref).
"""
hasbits(required) = flags -> hasbits(flags, required)
