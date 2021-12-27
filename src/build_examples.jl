function build_examples(verb::Bool = false; dir_examples::String = "examples")

    ## Copyright (C) 2020, Bruce Minaker
    ## build_examples.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## build_examples.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

#    verbose = any(args .== :verbose)

    dir = joinpath(pwd(), dir_examples)
    if ~isdir(dir)  ## If no examples folder exists
        println("Building examples folder...")
        mkdir(dir)  ## Create new local examples folder
    else
        println("Examples folder already exists...")
    end

    src = joinpath(dirname(dirname(pathof(EoM))), dir_examples)  ## Get name of examples folder
    list = readdir(src)  ## Get list of examples

    for i in list
        if ~isfile(joinpath(dir, i))
            verb && println("Copying ", i, "...")
            cp(joinpath(src, i), joinpath(dir, i))  ## Copy examples
        else
            verb && println(i, " already exists.  Skipping...")
        end
    end
end
