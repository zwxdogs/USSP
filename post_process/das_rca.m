function beamformed_data = das_rca(simu_data, rca_probe, global_para, wave, scan)

b_data = zeros(length(scan.scan_x), wave.N_theta);
dt = 1 / global_para.fs;
channel_times = (0:size(simu_data.rf_data, 1) - 1) * dt;

% 变迹
apo_channel = apodization(rca_probe.N_RC);
apo_channel.apodization_type = 'hanning';

disp('开始波束合成');
ToF = zeros(length(scan.scan_x), rca_probe.N_RC, wave.N_theta);
for n = 1:wave.N_theta
    disp(['合成第', num2str(n), '个波束（一共', num2str(wave.N_theta), '个）']);
    for c = 1:rca_probe.N_RC

        data = simu_data.rf_data(:, c, n);
        % ToF计算
        ToF(:, c, n) = calc_ToF_rca(wave, rca_probe, simu_data.delay_t, scan, n, c, global_para.c0);
        % 波束成形插值
        temp = interp1(channel_times, data, ToF(:, c, n), 'spline', 0);
        b_data(:, n) = b_data(:, n) + apo_channel.apodization_data(c) .* temp;
    end
end
beamformed_data = b_data;

end
