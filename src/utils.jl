
"""
    n_blocks(x,bs)

How many blocks of size `bs` are needed to process `x` items? Shortcut for
`div` with `RoundUp`.
"""
n_blocks(x, bs) = div(x, bs, RoundUp)

"""
    hasbits(flags, required) 

Check that all `required` bits are present in `flags`.
"""
hasbits(x, y) = (x & y) == y
