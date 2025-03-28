push!(LOAD_PATH,"../src/")

using Documenter
using EmergentEcology

makedocs(
    sitename = "EmergentEcology",
    format = Documenter.HTML(),
    modules = [EmergentEcology]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
