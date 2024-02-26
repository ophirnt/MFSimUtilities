using MFSimUtilities
using Plots

cd("/home/ophir/MFLab/MFSim-cases/dev/cavidade_termica/cavidade_termica_interpolacao/2a_rodada/Ra5e6_Pl0p02_noRad_2D_48_48_1n_1p")

probeTop = Probe("output/probe_points/surf00001_sonda00001.dat")

function plot_probe(probe)
    pu = plot(probe.df[:,"t"], probe.df[:,"u"], title = "U")
    pt = plot(probe.df[:,"t"], probe.df[:,"temp"], title = "Temp")
    plot(pu, pt, layout = (1,2), legend = false)
end


# while true
#     a = plot(probeTop.df[!, "t"], probeTop.df[!, "u"], show=true)
#     display(a)
#     sleep(30)
#     update_probe_df!(probeTop)
# end