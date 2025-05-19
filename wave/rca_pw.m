function wave = rca_pw(theta_min, theta_max, N_theta)
    wave.theta = deg2rad(linspace(theta_min, theta_max, N_theta));
    wave.N_theta = N_theta;
    wave.type = wave_types.plane_wave;
end

