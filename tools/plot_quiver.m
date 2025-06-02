function [] = plot_quiver(X, Y, U, V)

% 绘图
M = sqrt(U.^2+V.^2); % 计算模量
colorlist = jet; % 加载色条，也可以更换别的，cool ,winter等
M_min = min(M(:));
M_max = max(M(:));
Mlist = linspace(M_min, M_max, 256);
scaler1 = M_max ./ M; % 长度调节因子
U = U .* scaler1; % 每个分量进行调节
V = V .* scaler1; % 每个分量进行调节
scaler2 = 2; % 重新调节长度 以适应绘图
U = U * scaler2;
V = V * scaler2; 
[m, n] = size(X);
for i = 1:m
    for j = 1:n
        Mtemp = abs(M(i, j)-Mlist);
        index = Mtemp == min(Mtemp);
        colorarrow = colorlist(index, :);
        q = quiver(X(i, j), Y(i, j), U(i, j), V(i, j), 'MaxHeadSize', 100); % 每一个单独画，调节箭头大小
        q.LineWidth = 1;
        q.Color = colorarrow;
        hold on
    end
end
hc = colorbar;
colormap(jet)
hc.TickLabels = linspace(M_min, M_max, 11);
axis equal ij tight
xlabel('lateral (mm)');
ylabel('depth (mm)');

end
