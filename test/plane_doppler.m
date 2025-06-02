clear;clc;close all;

para = global_para(100e6, 1500, 1.45e6, 2e3);
% 探头
rca = rca_array(para, 64, 0.2e-3, 0.02e-3, 6.25e6);
rca.bw = 0.6;
rca.is_RC = false;
% 流动散射体
pha = mk_circle_pha_xy(1000, 8e-3, [0, 0, 15e-3], 0.1, 8, para);
% figure_1 = figure(1);
% pha{1}.plot_pha(figure_1);
% 波角度
wave = rca_pw(-10, 10, 21);
% 扫描区域
% sca = linear_3d_scan(linspace(-10e-3, 10e-3, 600), linspace(0, 40e-3, 600), 0);
sca = linear_xy_scan(linspace(-10e-3, 10e-3, 600), linspace(-10e-3, 10e-3, 600), 15e-3);
% 模拟
velocity_data = rca.calc_color_doppler(para, wave, pha, sca, 1, [1, 1]);
% 绘制
figure_1 = figure(1);
sca.plot_doppler(figure_1, velocity_data, -80);

