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
% RC发射模拟 ---------------------------------------------------------
% 探头
rca_1 = rca_array(64, 0.3e-3, 0.03e-3, 4e6);
% rca.is_RC = false;
% 脉冲
pulse_1 = pulse(rca_1);
pulse_1.excitation_type = "square";
% 发散波角度
w_1 = wave(rca_1, pulse_1, 1500);
w_1.wave_type = "plane_wave";
w_1 = w_1.rca_wave(-5, 5, 11, -10e-3);
% 模拟
simu_1 = simu_us(rca_1, pulse_1, w_1, 1500, 1.45e6);
simu_1 = simu_1.calc_rf(pha);
% 波束成形
beam_1 = beamformed(w_1, sca, simu_1.rf_data, simu_1.delay_t);
beam_1 = beam_1.calc(rca_1);
% CR发射模拟 ---------------------------------------------------------
% 探头
rca_2 = rca_array(64, 0.3e-3, 0.03e-3, 4e6);
rca_2.is_RC = false;
% 脉冲
pulse_2 = pulse(rca_2);
pulse_2.excitation_type = "square";
% 发散波角度
w_2 = wave(rca_2, pulse_2, 1500);
w_2.wave_type = "plane_wave";
w_2 = w_2.rca_wave(-5, 5, 11, -10e-3);
% 模拟
simu_2 = simu_us(rca_2, pulse_2, w_2, 1500, 1.45e6);
simu_2 = simu_2.calc_rf(pha);
% 波束成形
beam_2 = beamformed(w_2, sca, simu_2.rf_data, simu_2.delay_t);
beam_2 = beam_2.calc(rca_2);
% 后处理 -------------------------------------------------------------
b_data_orth = beam_1.beamformed_data + beam_2.beamformed_data;
% 复合
comp = compounded();
comp = comp.wave_compounded(b_data_orth, sca);
% 绘图
figure_1 = figure(1);
% subplot(121);
sca.plot_b_mode(figure_1, comp.compounded_data, [-60, 0], 'gray');
