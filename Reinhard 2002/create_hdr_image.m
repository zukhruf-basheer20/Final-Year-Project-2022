function [linear_result, global_result, durand_result] = create_hdr_image(lambda, a, dR, gamma, directory, extension)
    fprintf('\n## Creating HDR image: %s ##\n', directory);
    % Read in images and exposure times from directory.  Take the log of exposure time.
    [images, exposure_times] = read_images(directory, extension);
    ln_dt = log(exposure_times);

    % Sample the images appropriately, per color channel.
    [z_red, z_green, z_blue] = sample_rgb_images(images);

    % Compute the weighting function needed.
    weights = compute_weights();

    % Solve for the camera response for each color channel.
    fprintf('== Computing camera response for each channel ==\n');
    [g_red, ~] = gsolve(z_red, ln_dt, lambda, weights);
    [g_green, ~] = gsolve(z_green, ln_dt, lambda, weights);
    [g_blue, ~] = gsolve(z_blue, ln_dt, lambda, weights);
    
    % Plot response.
%     plot_responses(directory, g_red, g_green, g_blue);

    % Compute the HDR radiance map.
    hdr_map = compute_hdr_map(directory, images, g_red, g_green, g_blue, weights, ln_dt);

    % Apply baseline linear tone mapping.
    linear_result = apply_linear_tonemap(hdr_map);

    % Apply Reinhard's global tone mapping.
    global_result = apply_reinhard_global_tonemap(hdr_map, a);

    % Apply Durand's tone mapping scheme.
    durand_result = apply_durand_tonemap(directory, hdr_map, dR, gamma);
end

% plot_responses() is a helper function which plots response to intensity.
function plot_responses(directory, g_red, g_green, g_blue)
    pixel_range = 1:256;
    h = figure; plot(g_red, pixel_range, 'r', g_green, pixel_range, 'g', g_blue,pixel_range, 'b');
    title('Graph of Log Exposure to Pixel Value by Color Channel');
    xlabel('Log Exposure X');
    ylabel('Pixel Value Z');
    legend('Red Response', 'Green Response', 'Blue Response', 'Location', 'northwest');
    set(h,'PaperUnits','inches','PaperPosition',[0 0 5 3]);
    saveas(h, ['output/' directory '_response_plot.jpg']);
end