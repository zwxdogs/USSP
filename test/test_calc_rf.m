clear;
clc;
close all;
% 探头
rca = rca_array(64, 0.3e-3, 0.03e-3, 4e6);
% rca.is_RC = false;
% 脉冲
pulse = pulse(rca);
pulse.excitation_type = "square";
% 散射体
point_position(1, :) = [0, 0, 15e-3];
point_position(2, :) = [0, 0, 10e-3];
point_position(3, :) = [0, -3e-3, 12e-3];
point_position(4, :) = [0, 3e-3, 12e-3];
point_amplitudes = ones(size(point_position, 1), 1);
pha = phantom();
pha = pha.pha_pos(point_position, point_amplitudes);
% 发散波角度
w = wave(rca, pulse, 1500);
w = w.rca_wave(-5, 5, 11, -10e-3);
% 模拟
simu = simu_us(rca, pulse, w, 1500, 1.45e6);
simu = simu.calc_rf(pha);
sca = linear_3d_scan(linspace(-6e-3, 6e-3, 400), linspace(0, 20e-3, 500), 0);
% sca = linear_xy_scan(linspace(-6e-3, 6e-3, 400), linspace(-10e-3, 10e-3, 400), 15e-3);
% 波束成形
beam = beamformed(w, sca, simu.rf_data, simu.delay_t);
beam = beam.calc(rca);
% 复合
comp = compounded();
comp = comp.wave_compounded(beam.beamformed_data, sca);
% 图像绘制
figure_1 = figure(1);
% subplot(121);
sca.plot_b_mode(figure_1, comp.compounded_data, [-60, 0]);

% sca_2 = linear_3d_scan(linspace(-6e-3, 6e-3, 400), linspace(0, 20e-3, 300), 90);
% 
% beam = beamformed(w, sca_2, simu.rf_data, simu.delay_t);
% beam = beam.calc(rca);
% 
% comp = compounded(beam.beamformed_data);
% comp = comp.wave_compounded(sca_2);
% 
% subplot(122);