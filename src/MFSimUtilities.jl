module MFSimUtilities

export ResultFile, update_lines!, live_read_file!, create_probe_df!, update_probe_df!, live_plot_probe!, read_file, Probe, export_case_output, export_full_case

using DataFrames, Tar, CodecXz

"Represents a MFSim file with post-processing data."
mutable struct ResultFile
    path::String
    read_until::Integer
    nlines::Integer

    function ResultFile(path::String)
        open(path, "r") do f
            nlines = countlines(f)
            new(path, 1, nlines)
        end
    end
end

"Represents a MFSim probe."
mutable struct Probe
    file::ResultFile
    df::DataFrame

    function Probe(path::String)
        file = ResultFile(path)
        df = create_probe_df!(file)
        new(file, df)
    end
end

"Reads a text file located in path from the specified line to the end of the file.
 Returns lines as vectors."
read_file(path::String, from::Integer, to::Integer) = read_file(path)[from:to]

"Reads each line of a text file and returns them as a vector."
function read_file(path::String)
    open(path, "r") do f
        text = readlines(f)
        return text
    end
end

"Updates the number of lines of a ResultFile."
function update_lines!(file::ResultFile)
    open(file.path, "r") do f
        file.nlines = countlines(f)
    end
end

"Returns the new lines from a ResultFile."
function live_read_file!(file::ResultFile)
    update_lines!(file)
    text = read_file(file.path, file.read_until, file.nlines)
    file.read_until = file.nlines
    return text
end

"Creates a data frame for a probe."
function create_probe_df!(file::ResultFile)
    f = open(file.path, "r")
        header = readline(f)
        variables = strip.(split(header, ','))
        file.read_until += 1
    close(f)

    data = live_read_file!(file)
    entries = [parse.(Float64, split(line)) for line in data] |> x -> reduce(vcat, transpose.(x))

    probe = DataFrame(entries, variables)
end

"Updates a probe data frame by reading its new lines and appending them."
function update_probe_df!(probe::Probe)
    data = live_read_file!(probe.file)
    entries = [parse.(Float64, split(line)) for line in data] |> x -> reduce(vcat, transpose.(x))
    for entry in eachrow(entries)
        push!(probe.df, entry)
    end
end


function live_plot_probe!(probe::Probe, plot_function, time::Integer = 30)
    while true
        plot_function(probe)
        update_probe_df!(probe)
        sleep(time)
    end
end

################################################################################################


function tarball_maker(CompressorStream, output_path::String)

    function dir_processor(input_path::String)
        tarball = open(output_path, "w") |> CompressorStream
        Tar.create(input_path, tarball)
        close(tarball)
    end

end

function list_output_files_for_export(output_path::String, nhdf5s::Integer, include_header::Bool)
    files = readdir(output_path)
    
    hdf5s = files[endswith.(files, r".hdf5")] |> sort
    header_hdf5s = hdf5s[1:2]
    hdf5s = hdf5s[3:end]
    
    non_hdf5s = files[.!endswith.(files, r".hdf5")]
    
    case_hdf5s = length(hdf5s)
    indices = nhdf5s == 1 ? [case_hdf5s] : range(1, case_hdf5s, length=nhdf5s) |> collect .|> floor .|> Int64


   files_list = [hdf5s[indices]; non_hdf5s]

   if include_header
        files_list = [files_list; header_hdf5s]
   end

   files_list
end

"Gets a case output's folder first and last time step and the other files inside of it, and exports to a .tar.xz file."
function export_case_output(output_path::String, export_path::String, nhdf5s::Integer, include_header::Bool, CompressorStream = XzCompressorStream)
    files = list_output_files_for_export(output_path, nhdf5s, include_header)
    
    mktempdir() do temp_dir
        for file in files
            file_path = output_path * "/" * file
            cp(file_path, temp_dir * "/" * file)
        end
        tarball_maker(CompressorStream, export_path)(temp_dir)
    end

end


function export_full_case(case_path::String, export_path::String, nhdf5s::Integer, include_header::Bool, CompressorStream = XzCompressorStream)
    files = "output/" .* list_output_files_for_export("$case_path/output", nhdf5s, include_header)
    files = [files; "input"; "geo"; "probes"; "restart"]

    @show files

    mktempdir() do temp_dir

        for (root, dirs, files) in walkdir(case_path)
            for dir in dirs
                 mkpath(joinpath(temp_dir, dir))
            end
       end

        for file in files
            file_path = case_path * "/" * file
            cp(file_path, temp_dir * "/" * file)
        end
        tarball_maker(CompressorStream, export_path)(temp_dir)
    end

end

#################################################################################################################

"Writes down correct paths to case directory in the cfg file."
function adjust_cfg_file!(cfg_path::String, case_path::String)
    cfg_template = 
    """input_path: \"$case_path/input\"
    geo_path: \"$case_path/geo\"
    output_path: \"$case_path/output\"
    restart_path: \"$case_path/restart\"
    probes_path: \"$case_path/probes\"\n\n"""

    cfg = open(cfg_path, "r")
        old_cfg = read(cfg, String)
    close(cfg)
    new_cfg = cfg_template * old_cfg
    open(cfg_path, "w") do cfg
        write(cfg, new_cfg)
    end
end


# function live_plot_probe(file::ResultFile, x, y, timeout = 1)
#     probe = create_probe_df!(file)

#     while true
#         plot(probe[:, x], probe[:, y])
#         wait(timeout)
#         update_probe_df!(file, probe)
#     end
# end

# function plot_probes()

#     for i in 1:3
#         f = open("output/probe_points/surf00001_sonda0000$i.dat")
#             lines = readlines(f)
#         close(f)

#         variables = strip.(split(lines[1][12:end], ','))
#         entries = [parse.(Float64, split(line)) for line in lines[2:end]] |> x -> reduce(vcat, transpose.(x))
        
#         plott = plot(entries[:,2], entries[:,7])
#         display(plott)
#     end

# end

# function plot_nusselt()
#     f = open("output/nus_m    0.dat")
#         lines = readlines(f)
#     close(f)

#     variables = strip.(split(lines[1][12:end], ','))
#     entries = [parse.(Float64, split(line)) for line in lines[2:end]] |> x -> reduce(vcat, transpose.(x))

#     plott = plot(entries[:,1], entries[:,3])
#     display(plott)
# end

# plot_nusselt()

end
