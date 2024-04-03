using MFSimUtilities
using Plots

path = "/media/ophir/WDBLUE1/Interpolação_RTS/"
probeTop = "output/probe_points/surf00001_sonda00001.dat"

newProbe = "/home/ophir/MFLab/MFSim-cases/dev/cavidade_termica/cavidade_termica_interpolacao/testes_yucel/3a_rodada/radiatingThermalCavity"

amr3 = "Ra5e6_Pl0p02_tau1_w0_2D_48_32_AMR3_1p/"
patches2 = "Ra5e6_Pl0p02_tau1_w0_2D_48_48_1n_2p/"
niveis2 = "Ra5e6_Pl0p02_tau1_w0_2D_48_48_2n_2p/"
cfdmaior = "Ra5e6_Pl0p02_tau1_w0_2D_64_32_1n_1p/"
cfdmenor = "Ra5e6_Pl0p02_tau1_w0_2D_64_80_1n_1p/"

probeNew = Probe(newProbe * "/" * probeTop)

probeamr = Probe(path * amr3 * probeTop)
probepatches = Probe(path * patches2 * probeTop)
probeniveis = Probe(path * niveis2 * probeTop)
probemaior = Probe(path * cfdmaior * probeTop)
probemenor = Probe(path * cfdmenor * probeTop)


function plot_probe(probe)
    pu = plot(probe.df[:,"t"], probe.df[:,"u"], title = "U")
    pt = plot(probe.df[:,"t"], probe.df[:,"temp"], title = "Temp")
    display(plot(pu, pt, layout = (1,2), legend = false))
end

# for name in [patches2, niveis2, cfdmaior, cfdmenor]
#     @show "exporting $name"
#     export_case_output(path * name * "output", path * name[1:end-1] * ".tar.xz")
# end

live_plot_probe!(probeNew, plot_probe, 90)


# while true
#     a = plot(probeTop.df[!, "t"], probeTop.df[!, "u"], show=true)
#     display(a)
#     sleep(30)
#     update_probe_df!(probeTop)
# end
