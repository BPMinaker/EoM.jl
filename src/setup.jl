function setup(; folder::String = "output", data::String = "data")

    if ~isdir(folder)  # if no output folder exists
        mkdir(folder)  # create new empty output folder
    end

    # record the date and time for the output filenames, ISO format
    dtstr = Dates.format(now(), "yyyy-mm-dd")
    dir_date = joinpath(folder, dtstr)
    if ~isdir(dir_date)  # if no dated output folder exists
        mkdir(dir_date)  # create new empty dated output folder
    end

    dir = joinpath(dir_date, "figures")
    if ~isdir(dir)  # if no figures folder exists
        mkdir(dir)  # create new empty system folder
        src = joinpath(dirname(dirname(pathof(EoM))), "images", "eom_logo.png")  # get name of logo
        cp(src, joinpath(dir, "eom_logo.png"))
    end

    dir = joinpath(dir_date, data)
    if ~isdir(dir)  # if no system folder exists
        mkdir(dir)  # create new empty system folder
    end

    tmstr = Dates.format(now(), "HH-MM-SS-s")
    dir_output = joinpath(dir, tmstr)
    if ~isdir(dir_output)
        mkdir(dir_output)  # create new empty timed output folder
    end
    dir_time = joinpath(data, tmstr)

    dir_date, dir_time

end  ## Leave