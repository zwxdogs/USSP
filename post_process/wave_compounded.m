function compounded_data = wave_compounded(beamformed_data, scan)
    
% 变迹
apo_wave = apodization(size(beamformed_data, 2));
apo_wave.apodization_type = 'hanning';
apo_data = apo_wave.apodization_data';
apo_data = repmat(apo_data, size(beamformed_data, 1), 1);
temp_comp = apo_data .* beamformed_data;
% 复合
temp_comp = reshape(sum(temp_comp, 2), scan.ori_shape);
compounded_data = temp_comp;

end

