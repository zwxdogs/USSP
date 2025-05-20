clear;clc;close all;

para = global_para(100e6, 1500, 1.45e6);
rca = rca_array(para, 32, 0.3e-3, 0.03e-3, 4e6);
rca.excitation_type = "square";
% rca.is_RC = false;
% 发散波源 - H探头
% w = rca_dw(rca, -5, -5, 1, -10e-3);
wave = rca_pw(10, 10, 1);

sca = linear_3d_scan(linspace(-20e-3, 20e-3, 70), linspace(0, 60e-3, 100), 0);
% I_field = I_rca_simu(rca, wave, para, sca);
I_field = rca.calc_I(wave, para, sca);

figure_1 = figure(1);
sca.plot_I(figure_1, I_field, [-60 0]);