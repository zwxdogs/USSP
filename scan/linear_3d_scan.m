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
            is_iq = ~isreal(data);
            if is_iq
                envelope = abs(data);
            else
                envelope = abs(hilbert(data));
            end
            
            envelope = db(envelope./max(envelope(:)));
            b_mode_figure = figure_handle;
            imagesc(sca_3d.lateral_grid*1000, sca_3d.axial_grid*1000, envelope);
            colormap(color);
            axis image;
            colorbar;
            clim(range_db);
        
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
            clim(range_db);
        
            title('Pressure');
            xlabel('lateral (mm)');
            ylabel('depth (mm)');
        end
        function doppler_figure = plot_doppler(sca_3d, figure_handle, data, min_p_db)
            doppler_figure = figure_handle;
            sub_1 = subplot(131);
            imagesc(sca_3d.lateral_grid*1000, sca_3d.axial_grid*1000, data.velocity);
            colorbar;
            colormap(sub_1, dopplermap);
            clim([-1 1]*max(abs(data.velocity(:))));
            axis equal ij tight
            title('Color Doppler');
            xlabel('lateral (mm)');
            ylabel('depth (mm)');
            
            sub_2 = subplot(132);
            imagesc(sca_3d.lateral_grid*1000, sca_3d.axial_grid*1000, data.P_db);
            clim([min_p_db 0]);
            colorbar;
            colormap(sub_2, hot);
            axis equal ij tight
            title('Power Doppler');
            xlabel('lateral (mm)');
            ylabel('depth (mm)');
            
            idx = data.P_db > min_p_db;
            Vd = data.velocity.*idx / sind(40);
            sub_3 = subplot(133);
            imagesc(sca_3d.lateral_grid*1000, sca_3d.axial_grid*1000, Vd);
            colorbar;
            colormap(sub_3, dopplermap);
            clim([-1 1]*max(abs(Vd(:))));
            axis equal ij tight
            title('Color Doppler (mask by Power Doppler)');
            xlabel('lateral (mm)');
            ylabel('depth (mm)');
        end
        function p_doppler_figure = plot_p_doppler(sca_3d, figure_handle, data, min_p_db)
            p_doppler_figure = figure_handle;
            imagesc(sca_3d.lateral_grid*1000, sca_3d.axial_grid*1000, data);
            clim([min_p_db, 0])
            colorbar;
            colormap('hot');
            axis equal ij tight
            title('XDoppler');
            xlabel('lateral (mm)');
            ylabel('depth (mm)');
        end
        function velocity_figure = plot_velocity(sca_3d, figure_handle, data, p_db, min_p_db, scale, sample, color)
            velocity_figure = figure_handle;
            % ------------------------------功率多普勒掩码------------------------------
            ax1 = subplot(121);
            imagesc(sca_3d.lateral_grid*1000, sca_3d.axial_grid*1000, p_db);
            clim([min_p_db, 0])
            colorbar;
            colormap(ax1, 'hot');
            axis equal ij tight
            title('XDoppler');
            xlabel('lateral (mm)');
            ylabel('depth (mm)');
            % ------------------------------绘制矢量图------------------------------
            idx = p_db > min_p_db;
            v_z_RC = data.RC(:, :, 1) .* idx;
            v_x = data.RC(:, :, 2) .* idx;
            v_z_CR = data.CR(:, :, 1) .* idx;
            v_y = data.CR(:, :, 2) .* idx;
            [lateral, axial] = meshgrid(sca_3d.lateral_grid(1:sample:end), sca_3d.axial_grid(1:sample:end));
            ax2 = subplot(122);
            plot_quiver(lateral*1000, axial*1000, v_x((1:sample:end), (1:sample:end)), ...
                v_z_RC((1:sample:end), (1:sample:end)), scale, color, 'RC');
            % subplot(122);
            % plot_quiver(lateral*1000, axial*1000, v_y((1:sample:end), (1:sample:end)), ...
            %     v_z_CR((1:sample:end), (1:sample:end)), scale, color, 'CR');
        end
    end
end

