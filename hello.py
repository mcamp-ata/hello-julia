from juliacall import Main as jl
import os
current_dir = os.path.dirname(os.path.abspath(__file__))
julia_file_path = os.path.join(current_dir, "hello.jl")

jl.include(julia_file_path)

def main():
    result = jl.hello("Python! I am coming to you live from Julia!!")
    print(result)

if __name__ == "__main__":
    main()
