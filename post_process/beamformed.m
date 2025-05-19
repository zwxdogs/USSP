classdef beamformed
    % 波束成形类

    % MBeautifierDirective:Format:Off
    % 属性
    properties (GetAccess = public, SetAccess = protected)
        scan                                        % 扫描区域
        beamformed_data                             % 波束合成数据
        rf_data                                     % 原始数据
        delay_t                                     % 延迟时间
        wave                                        % 波束
        ToF_total                                   % 飞行时间
    end
    properties (Access = public)
        beamformed_type = beamformed_types.DAS      % 波束合成方法
    end
    % MBeautifierDirective:Format:On

    % 构造函数
    methods
        function beamf = beamformed(wave, scan, rf_data, delay_t)
            beamf.wave = wave;
            beamf.scan = scan;
            beamf.rf_data = rf_data;
            beamf.delay_t = delay_t;
        end
    end

    % 计算
    methods
        function beamf = calc(beamf, probe)
            switch beamf.beamformed_type
                case beamformed_types.DAS
                    [beamf.beamformed_data, beamf.ToF_total] = beamf.calc_DAS(probe);
            end
        end
        function [b_data, ToF] = calc_DAS(beamf, probe)
            b_data = zeros(length(beamf.scan.scan_x), beamf.wave.N_theta);
            dt = 1 / beamf.wave.pulse.fs;
            channel_times = (0:size(beamf.rf_data, 1) - 1) * dt;

            if probe.probe_type == probe_types.rca_array
                % 变迹
                apo_channel = apodization(probe.N_RC);
                apo_channel.apodization_type = 'hanning';

                disp('开始波束合成');
                wb = waitbar(0, '波束合成');
                ToF = zeros(length(beamf.scan.scan_x), probe.N_RC, beamf.wave.N_theta);
                for n = 1:beamf.wave.N_theta
                    disp(['合成第', num2str(n), '个波束（一共', num2str(beamf.wave.N_theta), '个）']);
                    for c = 1:probe.N_RC
                        str = ['波束合成中 --- ', num2str(round(100*c/probe.N_RC)), '%'];
                        waitbar(c/probe.N_RC, wb, str);
    
                        data = beamf.rf_data(:, c, n);
                        % ToF计算
                        ToF(:, c, n) = beamf.calc_ToF_rca(probe, c, n);
                        % 波束成形插值
                        temp = interp1(channel_times, data, ToF(:, c, n), 'spline', 0);
                        b_data(:, n) = b_data(:, n) + apo_channel.apodization_data(c) .* temp;
                    end
                end
            else
                % 待编写其他探头的计算
            end
            close(wb);
        end
    end
    % 不同探头的ToF计算
    methods
        function ToF = calc_ToF_rca(beamf, probe, channel, wave)
            switch beamf.wave.wave_type
                case wave_types.diverge_wave
                    % 发射延迟
                    ori2source = p2l_rca([0, 0, 0], ...
                        beamf.wave.source_p_min(wave, :), beamf.wave.source_p_max(wave, :));
                    source2point = zeros(length(beamf.scan.scan_x), 1);
                    for i = 1:length(beamf.scan.scan_x)
                        source2point(i) = p2l_rca(beamf.scan.scan_xyz(i, :), ...
                            beamf.wave.source_p_min(wave, :), beamf.wave.source_p_max(wave, :));
                    end
                    transmit = source2point - ori2source;
                case wave_types.plane_wave
                    if probe.is_RC
                        transmit = beamf.scan.scan_z * cos(beamf.wave.theta_az(wave)) + ...
                            beamf.scan.scan_x * sin(beamf.wave.theta_az(wave));
                    else
                        transmit = beamf.scan.scan_z * cos(beamf.wave.theta_az(wave)) + ...
                            beamf.scan.scan_y * sin(beamf.wave.theta_az(wave));
                    end
            end
            % 接收延迟
            if probe.is_RC
                Rh_y_ele = probe.y(probe.N_RC+1:probe.N_RC*2);
                r_p_min = [repmat(-probe.el_height/2, probe.N_RC, 1), Rh_y_ele, zeros(probe.N_RC, 1)];
                r_p_max = [repmat(probe.el_height/2, probe.N_RC, 1), Rh_y_ele, zeros(probe.N_RC, 1)];

                receive = zeros(length(beamf.scan.scan_x), 1);
                for i = 1:length(beamf.scan.scan_x)
                    receive(i) = p2l_rca(beamf.scan.scan_xyz(i, :), ...
                        r_p_min(channel, :), r_p_max(channel, :));
                end
            else
                Rh_x_ele = probe.x(1:probe.N_RC);
                r_p_min = [Rh_x_ele, repmat(-probe.el_height/2, probe.N_RC, 1), zeros(probe.N_RC, 1)];
                r_p_max = [Rh_x_ele, repmat(probe.el_height/2, probe.N_RC, 1), zeros(probe.N_RC, 1)];

                receive = zeros(length(beamf.scan.scan_x), 1);
                for i = 1:length(beamf.scan.scan_x)
                    receive(i) = p2l_rca(beamf.scan.scan_xyz(i, :), ...
                        r_p_min(channel, :), r_p_max(channel, :));
                end
            end
            ToF = (transmit + receive) / beamf.wave.c0 - beamf.delay_t(wave);
        end
    end

    % set
    methods
        function beamf = set.beamformed_type(beamf, beamf_type)
            beamf.beamformed_type = beamf_type;
        end
    end
end
