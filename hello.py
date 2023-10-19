from juliacall import Main as jl
jl.include("./hello.jl")
result = jl.hello("Python! I am coming to you live from Julia!!")
print(result)
