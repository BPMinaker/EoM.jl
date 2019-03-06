function build_examples(;dir_examples="examples",verbose=false)

dir=joinpath(pwd(),dir_examples)
if(~isdir(dir))  ## If no examples folder exists
	verbose && println("Building examples folder...")
	mkdir(dir)  ## Create new local examples folder

	src=joinpath(dirname(dirname(pathof(EoM))),dir_examples)  ## Get name of examples folder
	list=readdir(src)  ## Get list of examples

	for i in list
		cp(joinpath(src,i),joinpath(dir,i))  ## Copy examples
	end
end

verbose && println("Including examples...")
list=readdir(dir)  ## Get list of local example files
for i in list
	Base.include(Main,joinpath(dir,i))  ## Include them all
end

end
