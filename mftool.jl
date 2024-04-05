#julia

using MFSimUtilities
using Plots
using Match

function print_instructions(message)

"MFTool - A MFSim case management tool by Ophir Neto
Release version 05/04/2024 

$(message)

Usage:

\$ julia mftool.jl <COMMAND> [ARGS]

Available commands:

- plot_probe <probe_path> <update_interval>

- export_case <case_path> <path_to_tarball> <number_of_hdf5s> <include first and second hdf5?> [compressor] [MFSim-cmake_path]

- adjust_cfg <cfg_path> <case_path>

- record_mfsim <mfsim_path> <case_path>
" |> print

end

function run_command(command_func, args)
    try 
        command_func(args)
    catch e
        if typeof(e) == BoundsError
            print_instructions("ERROR: Possible lack of arguments for command \nFull report: $e")
        else
            print_instructions("ERROR: Issue running command \nFull report: $e")
        end
    end
end

##########################################################################################################################

function probePlot(probe)
    pu = plot(probe.df[:,"t"], probe.df[:,"u"], title = "U")
    pt = plot(probe.df[:,"t"], probe.df[:,"temp"], title = "Temp")
    display(plot(pu, pt, layout = (1,2), legend = false))
end

function plot_probe(args)
    probe = Probe(args[1])
    time = parse(Int64, args[2])
    live_plot_probe!(probe, probePlot, time)
end

function export_case(args)
    print("Exporting output from case $(args[1])")
    nhdf5s = parse(Int64, args[3])
    include_header = parse(Bool, args[4])
    @match length(args) begin
        4 => export_full_case(args[1], args[2], nhdf5s, include_header) # base case
        5 => export_full_case(args[1], args[2], nhdf5s, include_header, args[5]) # specify compressor
        _ => print_instructions("ERROR: Too many or too little arguments for export_case command")
    end
end

function adjust_cfg(args)
    print("Adjusting cfg file $args[1] for case directory $args[2]")
    adjust_cfg_file!(args[1], args[2])
end

function record_mfsim(args)
    print_message("record_mfsim command still in development.")
end

##########################################################################################################################

if length(ARGS) == 0
    print_instructions("")
    return
else
    @match ARGS[1] begin
        "plot_probe"   => run_command(plot_probe, ARGS[2:end])
        "export_case"  => run_command(export_case, ARGS[2:end])
        "adjust_cfg"   => run_command(adjust_cfg, ARGS[2:end])
        "record_mfsim" => run_command(record_mfsim, ARGS[2:end])
        "help"         => print_instructions("")
        _              => print_instructions("ERROR: Unrecognized command")
    end
end