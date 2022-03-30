using Documenter
using VkComputeUtils

makedocs(
    sitename = "VkComputeUtils.jl",
    format = Documenter.HTML(),
    modules = [VkComputeUtils],
    authors = "The developers of VkComputeUtils.jl",
    pages = ["Home" => "index.md", "Reference" => "functions.md"],
)

deploydocs(
    repo = "github.com/LCSB-BioCore/VkComputeUtils.jl.git",
    target = "build",
    branch = "gh-pages",
    push_preview = true,
)
