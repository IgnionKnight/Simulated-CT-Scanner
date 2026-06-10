function recon = ct_reconstruct(sinogram, theta_deg, N, filter_type)
% ct_reconstruct - Filtered backprojection reconstruction
% 
% sinogram   : [num_detectors x num_angles]
% theta_deg  : vector of projection angles in degrees
% N          : output image size (N x N)
% filter_type: 'Ram-Lak', 'Shepp-Logan', 'Cosine', 'Hann', 'Hamming', 'None'

if nargin < 3 || isempty(N)
    N = 256;
end
if nargin < 4 || isempty(filter_type)
    filter_type = 'Ram-Lak';
end

[num_detectors, num_angles] = size(sinogram);


s_max = sqrt(2);
s_centers = linspace(-s_max, s_max, num_detectors);


if ~strcmpi(filter_type, 'None')
    sinogram = apply_ramp_filter(sinogram, filter_type);
end


[x, y] = meshgrid(linspace(-1,1,N));
recon = zeros(N);
theta_rad = theta_deg * pi/180;

% Backprojection loop
for ia = 1:num_angles
    th = theta_rad(ia);
    

    s = x*cos(th) + y*sin(th);      % N x N
    

    proj = sinogram(:, ia);       
    

    vals = interp1(s_centers, proj, s(:), 'linear', 0);
    vals = reshape(vals, N, N);
    

    recon = recon + vals;
end


if num_angles > 1
    dtheta = abs(theta_rad(2) - theta_rad(1));
else
    dtheta = pi/num_angles;
end
recon = recon * dtheta;

end