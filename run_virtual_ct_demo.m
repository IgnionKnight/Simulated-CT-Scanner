function investigate_ct_parameters()
% INVESTIGATE_CT_PARAMETERS - Requirement 7 Investigation
% Systematic study of CT scanner parameter effects on image quality

close all;
fprintf('\n========================================\n');
fprintf('CT SCANNER PARAMETER INVESTIGATION\n');
fprintf('Requirement 7 Analysis\n');
fprintf('========================================\n\n');

%% Setup: Create test phantoms
N = 256;

% Phantom 1: Circles
bg_mu = 0;
c1 = struct('x',0,'y',0,'r',0.8,'mu',0.5);
c2 = struct('x',-0.3,'y',0.2,'r',0.15,'mu',1.0);
c3 = struct('x',0.4,'y',-0.1,'r',0.1,'mu',0.9);
phantom_circles = make_circle_phantom(N, bg_mu, [c1,c2,c3]);

% Phantom 2: Rectangle
rect.x = 0; rect.y = 0; rect.width = 1.0; rect.height = 0.5; rect.mu = 1.0;
phantom_rect = make_rectangle_phantom(N, 0, rect);

%% =====================================================================
%% INVESTIGATION 1: Effect of Rotation Angle Step
%% =====================================================================
fprintf('INVESTIGATION 1: Effect of Rotation Angle Step\n');
fprintf('----------------------------------------------\n');

angle_steps = [1, 2, 5, 10, 20];
figure('Name','Investigation 1: Angle Step Effect','Position',[100 100 1400 400]);

for i = 1:length(angle_steps)
    theta_step = angle_steps(i);
    
    [sino, theta, ~] = ct_forward_project(phantom_circles, theta_step, 200);
    recon = ct_reconstruct(sino, theta, N, 'None');
    
    diff_img = image_difference(recon, phantom_circles);
    mse = mean(diff_img(:).^2);
    
    fprintf('  Angle step = %2d°:  MSE = %.6f,  Projections = %d\n', ...
            theta_step, mse, length(theta));
    
    subplot(2, 5, i);
    imagesc(recon); axis image; colormap gray;
    title(sprintf('Step=%d°', theta_step));
    
    subplot(2, 5, i+5);
    imagesc(diff_img); axis image; colormap gray;
    title(sprintf('Error (MSE=%.4f)', mse));
end

fprintf('\n');

%% =====================================================================
%% INVESTIGATION 2: Effect of Number of Detectors
%% =====================================================================
fprintf('INVESTIGATION 2: Effect of Number of Detectors\n');
fprintf('----------------------------------------------\n');

num_detectors = [50, 100, 150, 200, 300];
figure('Name','Investigation 2: Number of Detectors','Position',[100 150 1400 400]);

for i = 1:length(num_detectors)
    num_det = num_detectors(i);
    
    [sino, theta, ~] = ct_forward_project(phantom_circles, 2, num_det);
    recon = ct_reconstruct(sino, theta, N, 'None');
    
    diff_img = image_difference(recon, phantom_circles);
    mse = mean(diff_img(:).^2);
    
    fprintf('  Detectors = %3d:  MSE = %.6f\n', num_det, mse);
    
    subplot(2, 5, i);
    imagesc(recon); axis image; colormap gray;
    title(sprintf('%d Detectors', num_det));
    
    subplot(2, 5, i+5);
    imagesc(diff_img); axis image; colormap gray;
    title(sprintf('Error (MSE=%.4f)', mse));
end

fprintf('\n');

%% =====================================================================
%% INVESTIGATION 3: Effect on Circular Structures (Small Features)
%% =====================================================================
fprintf('INVESTIGATION 3: Effect on Small Circular Structures\n');
fprintf('----------------------------------------------\n');

configs = [
    struct('theta', 1, 'det', 300, 'label', 'Best: 1° + 300 det')
    struct('theta', 2, 'det', 200, 'label', 'Good: 2° + 200 det')
    struct('theta', 5, 'det', 150, 'label', 'Medium: 5° + 150 det')
    struct('theta', 10, 'det', 100, 'label', 'Poor: 10° + 100 det')
];

figure('Name','Investigation 3: Small Circle Visibility','Position',[100 200 1200 300]);

for i = 1:length(configs)
    [sino, theta, ~] = ct_forward_project(phantom_circles, configs(i).theta, configs(i).det);
    recon = ct_reconstruct(sino, theta, N, 'None');
    

    cx = round(N/2 + (-0.3)*N/2);
    cy = round(N/2 - (0.2)*N/2);
    crop_size = 30;
    crop = recon(cy-crop_size:cy+crop_size, cx-crop_size:cx+crop_size);
    
    subplot(1, 4, i);
    imagesc(crop); axis image; colormap gray; colorbar;
    title(configs(i).label);
    
    fprintf('  %s\n', configs(i).label);
end

fprintf('\n');

%% =====================================================================
%% INVESTIGATION 4: Rectangle Edges (Artifact Study)
%% =====================================================================
fprintf('INVESTIGATION 4: Rectangle Edge Appearance\n');
fprintf('----------------------------------------------\n');

configs = [
    struct('theta', 1, 'det', 300)
    struct('theta', 5, 'det', 200)
    struct('theta', 10, 'det', 100)
];

figure('Name','Investigation 4: Rectangle Edges','Position',[100 250 1400 600]);

for i = 1:length(configs)
    [sino, theta, ~] = ct_forward_project(phantom_rect, configs(i).theta, configs(i).det);
    recon = ct_reconstruct(sino, theta, N, 'None');
    

    [pos, prof_phantom] = profile_along_line(phantom_rect, 'row', round(N/2));
    [~, prof_recon] = profile_along_line(recon, 'row', round(N/2));
    
    subplot(2, 3, i);
    imagesc(recon); axis image; colormap gray;
    title(sprintf('θ=%d°, Det=%d', configs(i).theta, configs(i).det));
    
    subplot(2, 3, i+3);
    plot(pos, prof_phantom, 'b-', 'LineWidth', 1.5); hold on;
    plot(pos, prof_recon, 'r--', 'LineWidth', 1.5);
    legend('Phantom', 'Reconstruction');
    xlabel('Position'); ylabel('Intensity');
    title('Horizontal Profile');
    grid on;
    
    fprintf('  θ=%2d°, Det=%3d: Edge sharpness affected by sampling\n', ...
            configs(i).theta, configs(i).det);
end

fprintf('\n');

%% =====================================================================
%% INVESTIGATION 5: Best Parameter Combination
%% =====================================================================
fprintf('INVESTIGATION 5: Finding Best Parameters\n');
fprintf('----------------------------------------------\n');

theta_vals = [1, 2, 5];
det_vals = [200, 250, 300];

best_mse = inf;
best_config = struct();

for i = 1:length(theta_vals)
    for j = 1:length(det_vals)
        [sino, theta, ~] = ct_forward_project(phantom_circles, theta_vals(i), det_vals(j));
        recon = ct_reconstruct(sino, theta, N, 'None');
        
        diff_img = image_difference(recon, phantom_circles);
        mse = mean(diff_img(:).^2);
        
        fprintf('  θ=%d°, Det=%d:  MSE = %.6f\n', theta_vals(i), det_vals(j), mse);
        
        if mse < best_mse
            best_mse = mse;
            best_config.theta = theta_vals(i);
            best_config.det = det_vals(j);
        end
    end
end

fprintf('\n*** BEST CONFIG: θ=%d°, Detectors=%d (MSE=%.6f) ***\n\n', ...
        best_config.theta, best_config.det, best_mse);

%% =====================================================================
%% SUMMARY
%% =====================================================================
fprintf('========================================\n');
fprintf('SUMMARY OF FINDINGS\n');
fprintf('========================================\n\n');

fprintf('1. ANGLE STEP: Smaller steps (1-2°) give better quality\n');
fprintf('   - Large steps (>5°) cause streak artifacts\n\n');

fprintf('2. NUMBER OF DETECTORS: More detectors improve resolution\n');
fprintf('   - Minimum ~200 detectors recommended\n\n');

fprintf('3. CIRCULAR STRUCTURES: Small features need fine sampling\n');
fprintf('   - Best visibility with 1° steps + 300 detectors\n\n');

fprintf('4. RECTANGLE EDGES: Sharp edges show ringing artifacts\n');
fprintf('   - Artifacts reduced with finer angular sampling\n\n');

fprintf('5. BEST PARAMETERS:\n');
fprintf('   - Angle step: %d°\n', best_config.theta);
fprintf('   - Detectors: %d\n', best_config.det);
fprintf('   - MSE: %.6f\n\n', best_mse);

fprintf('========================================\n\n');
end