clear;clc;close all;

para = global_para(100e6, 1500, 1.45e6, 2e3);
% 探头
rca = rca_array(para, 64, 0.3e-3, 0.03e-3, 4e6);
rca.is_RC = false;
% 流动散射体
pha = mk_circle_pha(5000, 8e-3, [0, 0, 25e-3], 0.1, 10, para);
% 波角度
wave = rca_pw(0, 0, 1);
% 扫描区域
sca = linear_3d_scan(linspace(-10e-3, 10e-3, 600), linspace(0, 40e-3, 600), 0);
% 模拟
velocity_data = rca.calc_doppler(para, wave, pha, sca, 1, [1, 1]);
% 绘制
figure_1 = figure(1);
sca.plot_doppler(figure_1, velocity_data, -80);

