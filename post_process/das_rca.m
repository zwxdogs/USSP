function beamformed_data = das_rca(simu_data, rca_probe, global_para, wave, scan)

is_iq = ~isreal(simu_data.data);
b_data = zeros(length(scan.scan_x), wave.N_theta);
dt = 1 / global_para.fs;
channel_times = (0:size(simu_data.data, 1) - 1) * dt;

% 变迹
apo_channel = apodization(rca_probe.N_RC);
apo_channel.apodization_type = 'hanning';

disp('开始波束合成');
ToF = calc_ToF_rca(wave, rca_probe, simu_data.delay_t, scan, global_para.c0);
for n = 1:wave.N_theta
    disp(['合成第', num2str(n), '个波束（一共', num2str(wave.N_theta), '个）']);
    for c = 1:rca_probe.N_RC

        data = simu_data.data(:, c, n);
        % ToF计算
        ToF_this = ToF(:, c, n);
        % 波束成形插值
        temp = interp1(channel_times, data, ToF_this, 'spline', 0);
        if is_iq
            phase_rotate = is_iq * exp(1i*2*pi*rca_probe.f0*ToF_this);
            temp_apo = apo_channel.apodization_data(c) .* temp;
            b_data(:, n) = b_data(:, n) + temp_apo .* phase_rotate;
        else
            b_data(:, n) = b_data(:, n) + apo_channel.apodization_data(c) .* temp;
        end
    end
end
beamformed_data = b_data;

end
