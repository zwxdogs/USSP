classdef linear_3d_scan < scan
    % 扫描类，包括成像像素和波束角度
    
    % 参数
    properties (SetAccess = protected, GetAccess = public)
        lateral_grid            % 横向网格
        axial_grid              % 轴向网格
        N_lateral               % 横向像素数
        N_axial                 % 轴向像素数
        rotate_angle            % 旋转角度 （deg角度）
    end
    
    % constuctor
    methods
        function sca_3d = linear_3d_scan(lateral_grid, axial_grid, rotate_angle)
            [lateral, axial] = meshgrid(lateral_grid, axial_grid);
            scan_x = lateral(:) * cosd(rotate_angle);
            scan_y = lateral(:) * sind(rotate_angle);
            scan_z = axial(:);
            sca_3d = sca_3d@scan(scan_x, scan_y, scan_z, size(lateral));

            sca_3d.lateral_grid = lateral_grid;
            sca_3d.axial_grid = axial_grid;
            sca_3d.rotate_angle = rotate_angle;
            sca_3d.N_lateral = length(lateral_grid);
            sca_3d.N_axial = length(axial_grid);
            sca_3d.N_pixels = sca_3d.N_lateral * sca_3d.N_axial;
        end
    end

    % plot
    methods
        function b_mode_figure = plot_b_mode(sca_3d, figure_handle, data, range_db, color)
            if(~exist('range_db', 'var'))
                range_db = [-60, 0];
            end
            if(~exist('color', 'var'))
                color = 'gray';
            end
            % b-mode绘图
            envelope = abs(hilbert(data));
            envelope = db(envelope./max(envelope(:)));
            b_mode_figure = figure_handle;
            imagesc(sca_3d.lateral_grid*1000, sca_3d.axial_grid*1000, envelope);
            colormap(color);
            axis image;
            colorbar;
            caxis(range_db);
        
            title('B-mode');
            xlabel('lateral (mm)');
            ylabel('depth (mm)');
        end
        function I_figure = plot_I(sca_3d, figure_handle, data, range_db)
            % 声强绘图
            I_figure = figure_handle;
            imagesc(sca_3d.lateral_grid*1000, sca_3d.axial_grid*1000, data);
            colormap('hot');
            axis image;
            colorbar;
            caxis(range_db);
        
            title('Pressure');
            xlabel('lateral (mm)');
            ylabel('depth (mm)');
        end
    end
end

