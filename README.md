# VkComputeUtils.jl

Convenience utilities for running compute shaders with
[Vulkan.jl](https://github.com/JuliaGPU/Vulkan.jl).

| Build status | Documentation |
|:---:|:---:|
| ![CI status](https://github.com/LCSB-BioCore/VkComputeUtils.jl/workflows/CI/badge.svg?branch=master) | [![stable documentation](https://img.shields.io/badge/docs-stable-blue)](https://lcsb-biocore.github.io/VkComputeUtils.jl/stable) [![dev documentation](https://img.shields.io/badge/docs-dev-cyan)](https://lcsb-biocore.github.io/VkComputeUtils.jl/dev) |

Vulkan API is an extremely powerful and portable way to run code on a wide
range of GPUs, unfortunately it comes with a large amount of boilerplate that
the programmers need to go through before becoming productive. This package
provides a small library of functions that implement a large portion of the
required boilerplate.

Most importantly, there are convenience functions for:
- reasonable discovery of suitable physical devices, queue families and memory
  types
- easy compilation of compute shader code into working pipelines
- simplified work with specialization and push constants

The package will be extended by need when developing other projects, more
functionality may appear.

## Acknowledgements

`VkComputeUtils.jl` was developed at the Luxembourg Centre for Systems
Biomedicine of the University of Luxembourg
([uni.lu/lcsb](https://www.uni.lu/lcsb)). The development
was supported by European Union's Horizon 2020 Programme under PerMedCoE
project ([permedcoe.eu](https://www.permedcoe.eu/)) agreement no. 951773.

<img src="docs/src/assets/unilu.svg" alt="Uni.lu logo" height="64px">   <img src="docs/src/assets/lcsb.svg" alt="LCSB logo" height="64px">   <img src="docs/src/assets/permedcoe.svg" alt="PerMedCoE logo" height="64px">
