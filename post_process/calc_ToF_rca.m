function ToF = calc_ToF_rca(wave, rca_probe, delay_t, scan, wave_index, channel_index, c0)

switch wave.type
    case wave_types.diverge_wave
        % 发射延迟
        ori2source = p2l_rca([0, 0, 0], ...
            wave.source_p_min(wave_index, :), wave.source_p_max(wave_index, :));
        source2point = zeros(length(scan.scan_x), 1);
        for i = 1:length(scan.scan_x)
            source2point(i) = p2l_rca(scan.scan_xyz(i, :), ...
                wave.source_p_min(wave_index, :), wave.source_p_max(wave_index, :));
        end
        transmit = source2point - ori2source;
    case wave_types.plane_wave
        if rca_probe.is_RC
            transmit = scan.scan_z * cos(wave.theta(wave_index)) + ...
                scan.scan_x * sin(wave.theta(wave_index));
        else
            transmit = scan.scan_z * cos(wave.theta(wave_index)) + ...
                scan.scan_y * sin(wave.theta(wave_index));
        end
end
% 接收延迟
if rca_probe.is_RC
    Rh_y_ele = rca_probe.y(rca_probe.N_RC+1:rca_probe.N_RC*2);
    r_p_min = [repmat(-rca_probe.el_height/2, rca_probe.N_RC, 1), Rh_y_ele, zeros(rca_probe.N_RC, 1)];
    r_p_max = [repmat(rca_probe.el_height/2, rca_probe.N_RC, 1), Rh_y_ele, zeros(rca_probe.N_RC, 1)];

    receive = zeros(length(scan.scan_x), 1);
    for i = 1:length(scan.scan_x)
        receive(i) = p2l_rca(scan.scan_xyz(i, :), ...
            r_p_min(channel_index, :), r_p_max(channel_index, :));
    end
else
    Rh_x_ele = rca_probe.x(1:rca_probe.N_RC);
    r_p_min = [Rh_x_ele, repmat(-rca_probe.el_height/2, rca_probe.N_RC, 1), zeros(rca_probe.N_RC, 1)];
    r_p_max = [Rh_x_ele, repmat(rca_probe.el_height/2, rca_probe.N_RC, 1), zeros(rca_probe.N_RC, 1)];

    receive = zeros(length(scan.scan_x), 1);
    for i = 1:length(scan.scan_x)
        receive(i) = p2l_rca(scan.scan_xyz(i, :), ...
            r_p_min(channel_index, :), r_p_max(channel_index, :));
    end
end
ToF = (transmit + receive) / c0 - delay_t(wave_index);

end

