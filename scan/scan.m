classdef scan
    % 扫描类，包括成像像素和波束角度
    
    % 参数
    properties (SetAccess = protected, GetAccess = public)
        N_pixels                % 像素数
        ori_shape               % 网格形状
        scan_x                  % 网格x坐标
        scan_y                  % 网格y坐标
        scan_z                  % 网格z坐标
        scan_xyz
    end
    
    % constuctor
    methods
        function sca = scan(scan_x, scan_y, scan_z, ori_shape)
            sca.ori_shape = ori_shape;
            sca.scan_x = scan_x;
            sca.scan_y = scan_y;
            sca.scan_z = scan_z;
            sca.scan_xyz = [scan_x, scan_y, scan_z];
        end
    end

    % plot
    methods
        function figure_handle = plot(sca, figure_handle_in, title_in)
            if (nargin>1) && ~isempty(figure_handle_in)
                figure_handle = figure(figure_handle_in); hold on;
            else
                figure_handle=figure();
                title('Probe');
            end
            
            plot3(sca.scan_x*1e3, sca.scan_y*1e3, sca.scan_z*1e3,'k.');
            xlabel('x[mm]'); ylabel('y[mm]'); zlabel('z[mm]');
            set(gca,'ZDir','Reverse');
            set(gca,'fontsize',14);
            
            if nargin>2
                title(title_in);
            end
        end
    end
    methods (Abstract)
        plot_b_mode(figure_handle, data, sca, range_db);
    end
end

