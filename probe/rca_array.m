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
end
