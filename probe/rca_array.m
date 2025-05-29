classdef rca_array < probe
    % rca阵列探头类

    % MBeautifierDirective:Format:Off
    % 探头参数
    properties (Access = public)
        N_RC                                    % 行列方向阵元个数
        is_RC = true                            % rca收发情况
        pitch                                   % 阵元间距
        kerf                                    % 阵元间隙
    end
    % MBeautifierDirective:Format:On

    % constructor
    methods
        function rca = rca_array(para, N_RC, pitch, kerf, f0)
            % probe参数
            N_el = N_RC * 2;
            el_width = pitch - kerf;
            el_height = (pitch * N_RC - kerf) + ...
                (pitch * N_RC - kerf) / 3; % 加上滚降区域
            rca = rca@probe(para, N_el, el_width, el_height, f0);
            rca.probe_type = probe_types.rca_array;

            % rca参数
            rca.N_RC = N_RC;
            rca.pitch = pitch;
            rca.kerf = kerf;
        end
    end

    % update
    methods
        function rca = update(rca)
            % 判断是否所有属性已构造
            if isempty(rca.N_RC) || isempty(rca.pitch) || isempty(rca.kerf)
                return
            end

            rca.N_el = rca.N_RC * 2;
            % 阵元尺寸
            rca.el_width = rca.pitch - rca.kerf;
            rca.el_height = (rca.pitch * rca.N_RC - rca.kerf) + ...
                (rca.pitch * rca.N_RC - rca.kerf) / 3; % 加入滚降区域
            % 行阵元坐标 - 基于探头几何中心在原点的情况
            R_x_ele = (-(rca.N_RC / 2 - 0.5) * rca.pitch):rca.pitch:(rca.N_RC / 2 - 0.5) * rca.pitch;
            R_y_ele = zeros(1, length(R_x_ele));
            R_z_ele = zeros(1, length(R_x_ele));
            % 列阵元坐标
            C_y_ele = (-(rca.N_RC / 2 - 0.5) * rca.pitch):rca.pitch:(rca.N_RC / 2 - 0.5) * rca.pitch;
            C_x_ele = zeros(1, length(C_y_ele));
            C_z_ele = zeros(1, length(C_y_ele));
            % 整体坐标
            rca.x = [R_x_ele'; C_x_ele'];
            rca.y = [R_y_ele'; C_y_ele'];
            rca.z = [R_z_ele'; C_z_ele'];
            rca.xyz = [rca.x, rca.y, rca.z];
        end
    end

    % set
    methods
        function rca = set.pitch(rca, pitch)
            rca.pitch = pitch;
            rca = rca.update();
        end
        function rca = set.kerf(rca, kerf)
            rca.kerf = kerf;
            rca = rca.update();
        end
        function rca = set.N_RC(rca, N_RC)
            rca.N_RC = N_RC;
            rca = rca.update;
        end
        function rca = set.is_RC(rca, is_RC)
            rca.is_RC = is_RC;
        end
    end

    % simulation
    methods
        function I_field = calc_I(rca, wave, global_para, scan)
            I_field = I_rca_simu(rca, wave, global_para, scan);
        end
        function simu_data = calc_rf(rca, global_para, wave, phantom)
            data = rf_rca_simu(rca, global_para, wave, phantom);
            iq_data = rf2iq(data, rca, global_para);
            simu_data = iq_data;
        end
    end

    % post_process
    methods
        function beamformed_data = das(rca, simu_data, global_para, wave, scan)
            ToF = calc_ToF_rca(wave, rca, simu_data.delay_t, scan, global_para.c0);
            beamformed_data = das_rca(simu_data, rca, global_para, wave, scan, ToF);
        end
        function velocity_data = calc_color_doppler(rca, global_para, wave, phantom, scan, lag, M)
            N_frame = length(phantom);
            iq_b_data = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame);
            disp('计算多帧数据');
            disp('---------------------------------------------');
            for n = 1:N_frame
                disp(['计算第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
                pha = phantom{n};
                simu_data = rca.calc_rf(global_para, wave, pha);
                if(~exist('ToF_tr', 'var'))
                    ToF_tr = calc_ToF_rca(wave, rca, simu_data.delay_t, scan, global_para.c0) + simu_data.delay_t;
                end
                ToF = ToF_tr - simu_data.delay_t;
                % ToF = calc_ToF_rca(wave, rca, simu_data.delay_t, scan, global_para.c0);
                beamformed_data = das_rca(simu_data, rca, global_para, wave, scan, ToF);
                comp_data = wave_compounded(beamformed_data, scan);
                iq_b_data(:, :, n) = comp_data;
                disp('---------------------------------------------');
            end
            velocity_data = iq2doppler(iq_b_data, global_para, rca, lag, M);
            velocity_data.doppler_data = iq_b_data;
        end
        % function velocity_data = calc_velocity(rca, global_para, wave, phatom, scan, lag, M)
        % 
        % end
    end
end
