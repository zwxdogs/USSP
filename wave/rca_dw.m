function wave = rca_dw(rca_probe, theta_min, theta_max, N_theta, source_z)
    theta = deg2rad(linspace(theta_min, theta_max, N_theta))';
    wave.theta = theta;
    wave.N_theta = N_theta;
    if rca_probe.is_RC
        wave.source_p_min = [source_z * tan(theta), repmat(-rca_probe.el_height/2, N_theta, 1), repmat(source_z, N_theta, 1)];
        wave.source_p_max = [source_z * tan(theta), repmat(rca_probe.el_height/2, N_theta, 1), repmat(source_z, N_theta, 1)];
        wave.source = [source_z * tan(theta), zeros(N_theta, 1), repmat(source_z, N_theta, 1)]; 
        % wave.source_line = source_p_max - source_p_min;
    else
        wave.source_p_min = [repmat(-rca_probe.el_height/2, N_theta, 1), source_z * tan(wave.theta), repmat(source_z, N_theta, 1)];
        wave.source_p_max = [repmat(rca_probe.el_height/2, N_theta, 1), source_z * tan(wave.theta), repmat(source_z, N_theta, 1)];
        wave.source = [zeros(N_theta, 1), source_z * tan(wave.theta), repmat(source_z, N_theta, 1)]; 
        % source_line = source_p_max - source_p_min;
    end
    wave.type = wave_types.diverge_wave;
end

