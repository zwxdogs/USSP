clear;clc;close all;


rca = rca_array(64, 0.3e-3, 0.03e-3, 4e6);
rca.is_RC = false;

pulse = pulse(rca);
pulse.excitation_type = "square";

% 发散波源 - H探头
w = wave(rca, pulse, 1500);
w.wave_type = "plane_wave";
w = w.rca_wave(-5, -5, 1, -10e-3);

sca = linear_3d_scan(linspace(-15e-3, 15e-3, 50), linspace(0, 30e-3, 70), 90);

simu = simu_us(rca, pulse, w, 1500, 1.45e6);
simu = simu.calc_I(sca);
I_data = simu.I_data;
% simu.calc_rf();

figure_1 = figure(1);
sca.plot_I(figure_1, I_data, [-60 0]);