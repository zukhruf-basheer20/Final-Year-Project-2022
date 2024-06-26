function result = apply_linear_tonemap(hdr_map)
    fprintf('== Applying Baseline Linear Tonemap ==\n');
    % Compute linear tonemap from the luminance map.
    luminance_map = compute_luminance_map(hdr_map);
    display_luminance = luminance_map / max(max(luminance_map));

    % Apply the tonemap.
    result = apply_tonemap(hdr_map, luminance_map, display_luminance);
end