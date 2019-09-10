function build_examples(;dir_examples="examples",verbose=false)

dir=joinpath(pwd(),dir_examples)
if ~isdir(dir)  ## If no examples folder exists
	verbose && println("Building examples folder...")
	mkdir(dir)  ## Create new local examples folder
end

src=joinpath(dirname(dirname(pathof(EoM))),dir_examples)  ## Get name of examples folder
list=readdir(src)  ## Get list of examples

for i in list
	if ~isfile(joinpath(dir,i))
		verbose && println("Copying ",i)
		cp(joinpath(src,i),joinpath(dir,i))  ## Copy examples
	else
		verbose && println(i," already exists.  Skipping...")
	end
end

end

# verbose && println("Including examples...")

# list=readdir(dir)  ## Get list of local example files
# for i in list
# 	Base.include(Main,joinpath(dir,i))  ## Include them all
# end
