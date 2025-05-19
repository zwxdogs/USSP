classdef wave
    % 波束类
    
    % 属性
    properties (Access = public)
        wave_type = wave_types.diverge_wave     % 波束类型    
    end
    properties (GetAccess = public, SetAccess = protected)
        source              % 波源
        theta_az            % 主扫描方向角度
        theta_el            % 仰角方向角度
        probe               % 探头
        pulse               % 脉冲
        N_theta             % 角度总数
        c0                  % 声速
    end
    % rca属性
    properties (GetAccess = public, SetAccess = protected)
        source_p_min        % rca焦线端点（主轴坐标最小）
        source_p_max        % rca焦线端点（主轴坐标最大）
        source_line         % 焦线矢量
    end

    % consturctor
    methods
        function w = wave(probe, pulse, c0)
            w.probe = probe; 
            w.pulse = pulse;
            w.c0 = c0;
        end
    end

    % define
    methods
        function w = rca_wave(w, theta_min, theta_max, N_theta, source_z)
            switch w.wave_type
                case wave_types.diverge_wave
                    w.theta_az = deg2rad(linspace(theta_min, theta_max, N_theta))';
                    w.N_theta = length(w.theta_az);
                    if w.probe.is_RC
                        w.source_p_min = [source_z * tan(w.theta_az), repmat(-w.probe.el_height/2, N_theta, 1), repmat(source_z, N_theta, 1)];
                        w.source_p_max = [source_z * tan(w.theta_az), repmat(w.probe.el_height/2, N_theta, 1), repmat(source_z, N_theta, 1)];
                        w.source = [source_z * tan(w.theta_az), zeros(N_theta, 1), repmat(source_z, N_theta, 1)]; 
                        w.source_line = w.source_p_max - w.source_p_min;
                    else
                        w.source_p_min = [repmat(-w.probe.el_height/2, N_theta, 1), source_z * tan(w.theta_az), repmat(source_z, N_theta, 1)];
                        w.source_p_max = [repmat(w.probe.el_height/2, N_theta, 1), source_z * tan(w.theta_az), repmat(source_z, N_theta, 1)];
                        w.source = [zeros(N_theta, 1), source_z * tan(w.theta_az), repmat(source_z, N_theta, 1)]; 
                        w.source_line = w.source_p_max - w.source_p_min;
                    end
                case wave_types.plane_wave
                    w.theta_az = deg2rad(linspace(theta_min, theta_max, N_theta));
                    w.N_theta = length(w.theta_az);
            end
        end
    end

    % set
    methods
        function w = set.wave_type(w, wave_type)
            w.wave_type = wave_type;
        end
    end
end

