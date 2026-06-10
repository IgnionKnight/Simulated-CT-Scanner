function run_virtual_ct_demo()
% RUN_VIRTUAL_CT_DEMO
% Quick non-GUI test: phantom -> sinogram -> reconstruction -> analysis

%% Parameters
N            = 256;
bg_mu        = 0;
theta_step   = 2;      % degrees
num_det      = 200;    % number of detectors
filter_type  = 'Ram-Lak';

%% 1. Generate circular phantom
c1 = struct('x',0,'y',0,'r',0.8,'mu',0.5);
c2 = struct('x',-0.3,'y',0.2,'r',0.15,'mu',1.0);
c3 = struct('x',0.4,'y',-0.1,'r',0.1,'mu',0.9);
phantom = make_circle_phantom(N, bg_mu, [c1,c2,c3]);

figure; imagesc(phantom); colormap gray; axis image; colorbar;
title('Original Circular Phantom');

%% 2. Scanner: forward projection
[sinogram, theta, tvec] = ct_forward_project(phantom, theta_step, num_det);

figure; imagesc(theta, tvec, sinogram); colormap gray; colorbar;
xlabel('\theta (deg)'); ylabel('Detector position'); title('Sinogram');

%% 3. Reconstruction
recon = ct_reconstruct(sinogram, theta, N, filter_type);

figure; imagesc(recon); colormap gray; axis image; colorbar;
title(sprintf('Reconstructed Image (%s, step=%g°)',filter_type,theta_step));

%% 4. Image Difference
diff_img = image_difference(recon, phantom);
figure; imagesc(diff_img); colormap gray; axis image; colorbar;
title('Absolute Difference |Reconstruction - Phantom|');

%% 5. Profiles through center column
[px, prof_phantom] = profile_along_line(phantom, 'col', round(N/2));
[~,  prof_recon]   = profile_along_line(recon,   'col', round(N/2));

figure; plot(px, prof_phantom, 'LineWidth',1.5); hold on;
plot(px, prof_recon, '--', 'LineWidth',1.5);
legend('Phantom','Reconstruction'); xlabel('Position');
ylabel('Signal Intensity');
title('Signal Intensity Profiles (Center Column)');

end
