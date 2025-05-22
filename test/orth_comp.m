clear;
clc;
close all;
% --------------------------------------------------------------------
% 扫描区域
% sca = linear_3d_scan(linspace(-6e-3, 6e-3, 400), linspace(0, 20e-3, 300), 0);
sca = linear_xy_scan(linspace(-5e-3, 5e-3, 201), linspace(-5e-3, 5e-3, 201), 15e-3);
% 散射体
point_position(1, :) = [0, 0, 15e-3];
point_amplitudes = ones(size(point_position, 1), 1);
pha = phantom();
pha = pha.pha_pos(point_position, point_amplitudes);
% 波角度
wave = rca_pw(-5, 5, 11);
% 全局参数
para = global_para(100e6, 1500, 1.45e6);
% RC发射模拟 ---------------------------------------------------------
% 探头
rca_1 = rca_array(para, 64, 0.3e-3, 0.03e-3, 4e6);
% rca_1.is_RC = false;
% 模拟
simu_data_1 = rca_1.calc_rf(para, wave, pha);
% 波束成形
b_data_1 = rca_1.das(simu_data_1, para, wave, sca);
% 复合
comp_data_1 = wave_compounded(b_data_1, sca);
% CR发射模拟 ---------------------------------------------------------
% 探头
rca_2 = rca_array(para, 64, 0.3e-3, 0.03e-3, 4e6);
rca_2.is_RC = false;
% 模拟
simu_data_2 = rca_2.calc_rf(para, wave, pha);
% 波束成形
b_data_2 = rca_2.das(simu_data_2, para, wave, sca);
% 复合
comp_data_2 = wave_compounded(b_data_2, sca);
% 后处理 -------------------------------------------------------------
% 正交复合
orth_data = comp_data_1 + comp_data_2;
% 绘图
figure_1 = figure(1);
% subplot(121);
sca.plot_b_mode(figure_1, orth_data, [-60, 0], 'gray');
