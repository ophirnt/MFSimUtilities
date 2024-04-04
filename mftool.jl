using MFSimUtilities
using Plots
using Match

function probePlot(probe)
    pu = plot(probe.df[:,"t"], probe.df[:,"u"], title = "U")
    pt = plot(probe.df[:,"t"], probe.df[:,"temp"], title = "Temp")
    display(plot(pu, pt, layout = (1,2), legend = false))
end

function print_instructions()

"MFTool - A MFSim case management tool by Ophir Neto - Release version 04/04/2024 

Usage:

\$ julia mftool.jl <COMMAND> [ARGS]

Available commands:

plot_probe <probe_path> <update_interval>
export_case <case_output_path> <path_to_tarball> <number_of_hdf5s> <include first and second hdf5?>
" |> print

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
    export_case_output(args[1], args[2], nhdf5s, include_header)
end

@match ARGS[1] begin
    "plot_probe"  => plot_probe(ARGS[2:end])
    "export_case" => export_case(ARGS[2:end])
    _             => print_instructions()
end

#function_call()