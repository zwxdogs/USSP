clear;
clc;
close all;

para = global_para(100e6, 1500, 1.45e6, 2e3);
% 探头
rca = rca_array(para, 128, 0.3e-3, 0.03e-3, 4e6);
rca.is_RC = false;
% 散射体
point_position(1, :) = [0, 0, 15e-3];
point_position(2, :) = [0, 0, 20e-3];
point_position(3, :) = [0, -3e-3, 10e-3];
point_position(4, :) = [0, 3e-3, 10e-3];
point_position(5, :) = [0, 0, 10e-3];
point_amplitudes = ones(size(point_position, 1), 1);
pha = phantom();
pha = pha.pha_pos(point_position, point_amplitudes);
% 波角度
wave = rca_pw(-10, 10, 21);
% 模拟
simu_data = rca.calc_rf(para, wave, pha);
sca = linear_3d_scan(linspace(-5e-3, 5e-3, 200), linspace(0, 30e-3, 200), 90);
% sca = linear_xy_scan(linspace(-5e-3, 5e-3, 200), linspace(-5e-3, 5e-3, 200), 15e-3);
% 波束成形
b_data = rca.das(simu_data, para, wave, sca);
% 复合
comp_data = wave_compounded(b_data, sca);
% 绘图
figure_1 = figure(1);
% subplot(121);
sca.plot_b_mode(figure_1, comp_data, [-60, 0], 'gray');

% test_ToF;
