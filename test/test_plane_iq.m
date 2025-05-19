clear;
clc;
close all;
% 探头
rca = rca_array(64, 0.3e-3, 0.03e-3, 4e6);
rca.is_RC = false;
% 脉冲
pulse = pulse(rca);
pulse.excitation_type = "square";
% 散射体
point_position(1, :) = [0, 0, 15e-3];
point_position(2, :) = [0, 0, 10e-3];
point_position(3, :) = [-3e-3, 0, 12e-3];
point_position(4, :) = [3e-3, 0, 12e-3];
% point_position(5, :) = [5e-3, 0, 20e-3];
% point_position(6, :) = [-5e-3, 0, 20e-3];
% point_position(7, :) = [5e-3, 0, 20e-3];
% point_position(8, :) = [-5e-3, 0, 20e-3];
% point_position(9, :) = [7e-3, 0, 25e-3];
% point_position(10, :) = [-7e-3, 0, 25e-3];
point_amplitudes = ones(size(point_position, 1), 1);
pha = phantom();
pha = pha.pha_pos(point_position, point_amplitudes);
% 波角度
w = wave(rca, pulse, 1500);
w.wave_type = "plane_wave";
w = w.rca_wave(-5, 5, 11, -10e-3);
% 模拟
simu = simu_us(rca, pulse, w, 1500, 1.45e6);
simu = simu.calc_rf(pha);
simu = simu.rf2iq();
sca = linear_3d_scan(linspace(-5e-3, 5e-3, 200), linspace(0, 30e-3, 600), 0);
% sca = linear_xy_scan(linspace(-5e-3, 5e-3, 201), linspace(-5e-3, 5e-3, 201), 15e-3);
% 波束成形
beam = beamformed(w, sca, simu.rf_data, simu.delay_t);
beam = beam.calc(rca);
% 复合
comp = compounded();
comp = comp.wave_compounded(beam.beamformed_data, sca);
% 绘图
figure_1 = figure(1);
% subplot(121);
sca.plot_b_mode(figure_1, comp.compounded_data, [-60, 0], 'gray');

% test_ToF;
