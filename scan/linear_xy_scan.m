classdef linear_xy_scan < scan
    
    % 属性
    properties (SetAccess = protected, GetAccess = public)
        x_grid              % x轴方向网格
        y_grid              % y轴方向网格
        N_x_grid            % x轴方向网格数量
        N_y_grid            % y轴方向网格数量
        depth               % 深度
    end

    % constructor
    methods
        function sca_xy = linear_xy_scan(x_grid, y_grid, depth)
            [x, y] = meshgrid(x_grid, y_grid);
            scan_x = x(:);
            scan_y = y(:);
            scan_z = ones(length(scan_x), 1) * depth;
            sca_xy = sca_xy@scan(scan_x, scan_y, scan_z, size(x));

            sca_xy.x_grid = x_grid;
            sca_xy.y_grid = y_grid;
            sca_xy.N_x_grid = length(x_grid);
            sca_xy.N_y_grid = length(y_grid);
            sca_xy.depth = depth;
            sca_xy.N_pixels = sca_xy.N_x_grid * sca_xy.N_y_grid;
        end
    end

    % plot
    methods
        function b_mode_figure = plot_b_mode(sca_xy, figure_handle, data, range_db, color)
            if(~exist('range_db', 'var'))
                range_db = [-60, 0];
            end
            if(~exist('color', 'var'))
                color = 'gray';
            end
            % b-mode绘图
            is_iq = ~isreal(data);
            if is_iq
                envelope = abs(data);
            else
                envelope = abs(hilbert(data));
            end
            
            envelope = db(envelope./max(envelope(:)));
            b_mode_figure = figure_handle;
            imagesc(sca_xy.x_grid*1000, sca_xy.y_grid*1000, envelope);
            colormap(color);
            axis image;
            colorbar;
            clim(range_db);
        
            title('B-mode');
            xlabel('x (mm)');
            ylabel('y (mm)');
        end
    end
   
end

