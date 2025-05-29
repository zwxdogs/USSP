classdef phantom
    % 散射体类
    
    % 散射体参数
    properties (SetAccess = protected, GetAccess = public)
        positions
        amplitudes
    end
    
    % constructor
    methods
        function pha = phantom()
        end
    end
    
    % define
    methods
        function pha = pha_pos(pha, positions, amplitudes)
            pha.positions = positions;
            pha.amplitudes = amplitudes;
        end
    end

    % 绘制
    methods
        function pha_figure = plot_pha(pha, figure_handle)
            pha_figure = figure_handle;
            scatter3(pha.positions(:, 1)*1000, pha.positions(:, 2)*1000, pha.positions(:, 3)*1000, 5, 'filled');
            xlim([min(pha.positions(:, 1))*1000-3, max(pha.positions(:, 1))*1000+3]);
            ylim([min(pha.positions(:, 2))*1000-3, max(pha.positions(:, 2))*1000+3]);
            zlim([min(pha.positions(:, 3))*1000-3, max(pha.positions(:, 3))*1000+3]);
            xlabel('x (mm)')
            ylabel('y (mm)')
            zlabel('z (mm)')
            title('Phantom')
        end
    end
end

