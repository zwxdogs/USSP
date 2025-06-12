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
        function p_doppler_data = calc_p_doppler(rca, global_para, wave, phantom, scan, svd_filt, s_index)
            % xdoppler复合功率多普勒
            % RC发射和CR发射
            rca_RC = rca;
            rca_RC.is_RC = true;
            rca_CR = rca;
            rca_CR.is_RC = false;
            % ------------------------------模拟数据------------------------------
            % % RC
            N_frame = length(phantom);
            dt = 1 / global_para.fs;
            max_deepth = max(scan.scan_z);
            cropat = round(2*max_deepth/global_para.c0/dt);
            delay_t_RC = zeros(wave.N_theta, N_frame);
            iq_data_RC = zeros(cropat, rca_RC.N_RC, wave.N_theta, N_frame);
            disp('计算多角度多帧原始数据 - RC');
            disp('---------------------------------------------');
            for n = 1:N_frame
                disp(['计算第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
                pha = phantom{n};
                simu_data = rca_RC.calc_rf(global_para, wave, pha);
                iq_data_RC(1:size(simu_data.data, 1), :, :, n) = simu_data.data;
                delay_t_RC(:, n) = simu_data.delay_t;
                disp('---------------------------------------------');
            end
            p_doppler_data.iq_data_RC = iq_data_RC;
            % CR
            delay_t_CR = zeros(wave.N_theta, N_frame);
            iq_data_CR = zeros(cropat, rca_CR.N_RC, wave.N_theta, N_frame);
            disp('计算多角度多帧原始数据 - CR');
            disp('---------------------------------------------');
            for n = 1:N_frame
                disp(['计算第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
                pha = phantom{n};
                simu_data = rca_CR.calc_rf(global_para, wave, pha);
                iq_data_CR(1:size(simu_data.data, 1), :, :, n) = simu_data.data;
                delay_t_CR(:, n) = simu_data.delay_t;
                disp('---------------------------------------------');
            end
            p_doppler_data.iq_data_CR = iq_data_CR;
            % ------------------------------SVD滤波------------------------------
            % 暂不考虑SVD滤波，需要去除低频静态数据时考虑。
            if svd_filt
                % % RC
                % disp('SVD滤波 - RC');
                % disp('---------------------------------------------');
                % iq_data_filt_RC = zeros(cropat, rca_RC.N_RC, wave.N_theta, N_frame);
                % for w = 1:wave.N_theta
                %     disp(['滤波第', num2str(w), '个角度（一共', num2str(wave.N_theta), '个）']);
                %     data = iq_data_RC(:, :, w, :);
                %     casorati_M = reshape(data, [cropat * rca_RC.N_RC, N_frame]);
                %     [U, S, V] = svd(casorati_M);
                %     singular = diag(S);
                %     selected_s = singular > singular(s_index+1);
                %     S_filt = S;
                %     S_filt(selected_s, selected_s) = 0;
                %     filt_data = U * S_filt * V';
                %     iq_data_filt_RC(:, :, w, :) = reshape(filt_data, size(data));
                %     disp('---------------------------------------------');
                % end
                % p_doppler_data.iq_data_filt_RC = iq_data_filt_RC;
                % % CR
                % disp('SVD滤波 - CR');
                % disp('---------------------------------------------');
                % iq_data_filt_CR = zeros(cropat, rca_CR.N_RC, wave.N_theta, N_frame);
                % for w = 1:wave.N_theta
                %     disp(['滤波第', num2str(w), '个角度（一共', num2str(wave.N_theta), '个）']);
                %     data = iq_data_CR(:, :, w, :);
                %     casorati_M = reshape(data, [cropat * rca_CR.N_RC, N_frame]);
                %     [U, S, V] = svd(casorati_M);
                %     singular = diag(S);
                %     selected_s = singular > singular(s_index+1);
                %     S_filt = S;
                %     S_filt(selected_s, selected_s) = 0;
                %     filt_data = U * S_filt * V';
                %     iq_data_filt_CR(:, :, w, :) = reshape(filt_data, size(data));
                %     disp('---------------------------------------------');
                % end
                % p_doppler_data.iq_data_filt_CR = iq_data_filt_CR;
            else
                iq_data_filt_RC = iq_data_RC;
                iq_data_filt_CR = iq_data_CR;
            end
            % ------------------------------波束成形------------------------------
            % RC
            disp('波束成形 - RC');
            disp('---------------------------------------------');
            iq_b_data_RC = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame);
            for n = 1:N_frame
                disp(['波束成形第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
                filt_data_RC.data = iq_data_filt_RC(:, :, :, n);
                if (~exist('ToF_tr_RC', 'var'))
                    ToF_tr_RC = calc_ToF_rca(wave, rca_RC, delay_t_RC(:, n), scan, global_para.c0);
                    for i = 1:wave.N_theta
                        ToF_tr_RC(:, :, i) = ToF_tr_RC(:, :, i) + delay_t_RC(i, n);
                    end
                end
                ToF_RC = zeros(size(ToF_tr_RC));
                for i = 1:wave.N_theta
                    ToF_RC(:, :, i) = ToF_tr_RC(:, :, i) - delay_t_RC(i, n);
                end
                beamformed_data_RC = das_rca(filt_data_RC, rca_RC, global_para, wave, scan, ToF_RC);
                comp_data_RC = wave_compounded(beamformed_data_RC, scan);
                iq_b_data_RC(:, :, n) = comp_data_RC;
                disp('---------------------------------------------');
            end
            p_doppler_data.iq_b_data_RC = iq_b_data_RC;
            % CR
            disp('波束成形 - CR');
            disp('---------------------------------------------');
            iq_b_data_CR = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame);
            for n = 1:N_frame
                disp(['波束成形第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
                filt_data_CR.data = iq_data_filt_CR(:, :, :, n);
                if (~exist('ToF_tr_CR', 'var'))
                    ToF_tr_CR = calc_ToF_rca(wave, rca_CR, delay_t_CR(:, n), scan, global_para.c0);
                    for i = 1:wave.N_theta
                        ToF_tr_CR(:, :, i) = ToF_tr_CR(:, :, i) + delay_t_CR(i, n);
                    end
                end
                ToF_CR = zeros(size(ToF_tr_CR));
                for i = 1:wave.N_theta
                    ToF_CR(:, :, i) = ToF_tr_CR(:, :, i) - delay_t_CR(i, n);
                end
                beamformed_data_CR = das_rca(filt_data_CR, rca_CR, global_para, wave, scan, ToF_CR);
                comp_data_CR = wave_compounded(beamformed_data_CR, scan);
                iq_b_data_CR(:, :, n) = comp_data_CR;
                disp('---------------------------------------------');
            end
            p_doppler_data.iq_b_data_CR = iq_b_data_CR;
            % ------------------------------功率多普勒------------------------------
            % xdoppler方法（论文：XDoppler: Cross-Correlation of Orthogonal Apertures for 3D Blood Flow Imaging）
            p_doppler = sum(iq_b_data_RC.*conj(iq_b_data_CR)+conj(iq_b_data_RC).*iq_b_data_CR, 3) / N_frame;
            p_doppler = abs(p_doppler);
            p_doppler_data.P_db = 20 * log10(p_doppler/max(p_doppler(:)));
        end
        function velocity_data = calc_velocity(rca, global_para, wave, phantom, scan, lag, M, min_p_db)
            % RCA探头多普勒速度矢量测量
            % RC发射和CR发射
            rca_RC = rca;
            rca_RC.is_RC = true;
            rca_CR = rca;
            rca_CR.is_RC = false;
            % ------------------------------模拟数据和波束成形------------------------------
            N_frame = length(phantom);
            UVD_blocks = cell(N_frame, 1);
            % RC
            disp('计算多角度多帧原始数据 - RC');
            disp('---------------------------------------------');
            for n = 1:N_frame
                disp(['计算RC第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
                pha = phantom{n};
                simu_data_RC = rca_RC.calc_rf(global_para, wave, pha);
                % 飞行时间
                if (~exist('ToF_tr_RC', 'var'))
                    ToF_tr_RC = calc_ToF_rca(wave, rca_RC, simu_data_RC.delay_t, scan, global_para.c0);
                    for i = 1:wave.N_theta
                        ToF_tr_RC(:, :, i) = ToF_tr_RC(:, :, i) + simu_data_RC.delay_t(i);
                    end
                end
                ToF_RC = zeros(size(ToF_tr_RC));
                for i = 1:wave.N_theta
                    ToF_RC(:, :, i) = ToF_tr_RC(:, :, i) - simu_data_RC.delay_t(i);
                end
                % 波束成形
                beamformed_data_RC = das_rca(simu_data_RC, rca_RC, global_para, wave, scan, ToF_RC);
                UVD_blocks{n}.RC(:, :, :) = reshape(beamformed_data_RC, [scan.ori_shape(1), scan.ori_shape(2), wave.N_theta]);
                disp('---------------------------------------------');
            end
            % CR
            disp('计算多角度多帧原始数据 - CR');
            disp('---------------------------------------------');
            for n = 1:N_frame
                disp(['计算CR第', num2str(n), '帧的数据（一共', num2str(N_frame), '帧）']);
                pha = phantom{n};
                simu_data_CR = rca_CR.calc_rf(global_para, wave, pha);
                % 飞行时间
                if (~exist('ToF_tr_CR', 'var'))
                    ToF_tr_CR = calc_ToF_rca(wave, rca_CR, simu_data_CR.delay_t, scan, global_para.c0);
                    for i = 1:wave.N_theta
                        ToF_tr_CR(:, :, i) = ToF_tr_CR(:, :, i) + simu_data_CR.delay_t(i);
                    end
                end
                ToF_CR = zeros(size(ToF_tr_CR));
                for i = 1:wave.N_theta
                    ToF_CR(:, :, i) = ToF_tr_CR(:, :, i) - simu_data_CR.delay_t(i);
                end
                % 波束成形
                beamformed_data_CR = das_rca(simu_data_CR, rca_CR, global_para, wave, scan, ToF_CR);
                UVD_blocks{n}.CR(:, :, :) = reshape(beamformed_data_CR, [scan.ori_shape(1), scan.ori_shape(2), wave.N_theta]);
                disp('---------------------------------------------');
            end
            velocity_data.UVD_blocks = UVD_blocks;
            % ------------------------------SVD滤波------------------------------
            % 暂不考虑SVD滤波，需要去除低频静态数据时考虑。
            % ------------------------------功率多普勒掩码------------------------------
            disp('计算功率多普勒');
            data4p_RC = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame);
            data4p_CR = zeros(scan.ori_shape(1), scan.ori_shape(2), N_frame);
            for n = 1:size(UVD_blocks, 1)
                RC_data = reshape(UVD_blocks{n}.RC, [scan.N_pixels, wave.N_theta]);
                CR_data = reshape(UVD_blocks{n}.CR, [scan.N_pixels, wave.N_theta]);
                comp_RC_data = wave_compounded(RC_data, scan);
                comp_CR_data = wave_compounded(CR_data, scan);
                data4p_RC(:, :, n) = comp_RC_data;
                data4p_CR(:, :, n) = comp_CR_data;
            end
            p_doppler = sum(data4p_RC.*conj(data4p_CR)+conj(data4p_RC).*data4p_CR, 3) / N_frame;
            p_doppler = abs(p_doppler);
            velocity_data.P_db = 20 * log10(p_doppler/max(p_doppler(:)));
        end
    end
end
