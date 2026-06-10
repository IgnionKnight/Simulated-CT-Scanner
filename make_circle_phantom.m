function [sinogram, theta_used, s_centers] = ct_forward_project(img, theta_step, num_detectors, det_spacing, det_type, source_dist)

if nargin < 2 || isempty(theta_step)
    theta_step = 2;
end
if nargin < 3 || isempty(num_detectors)
    num_detectors = size(img,1);
end
if nargin < 4 || isempty(det_spacing)
    det_spacing = 1.0;
end
if nargin < 5 || isempty(det_type)
    det_type = 'Linear';
end
if nargin < 6 || isempty(source_dist)
    source_dist = 2.0;  
end

theta_used = 0:theta_step:179;
num_angles = numel(theta_used);


[Nx, Ny] = size(img);
if Nx ~= Ny
    error('Image must be square.');
end
N = Nx;


[x, y] = meshgrid(linspace(-1,1,N));
pixel_vals = img(:);


s_max = sqrt(2) * det_spacing;

if strcmpi(det_type, 'Arc')
    max_angle = atan(s_max / source_dist);
    angles = linspace(-max_angle, max_angle, num_detectors+1);
    s_edges = source_dist * tan(angles); 
else
    s_edges = linspace(-s_max, s_max, num_detectors+1);
end

s_centers = (s_edges(1:end-1) + s_edges(2:end))/2;

sinogram = zeros(num_detectors, num_angles);

for ia = 1:num_angles
    th = theta_used(ia)*pi/180;
    

    s = x*cos(th) + y*sin(th);
    s_vec = s(:);

    bin_idx = discretize(s_vec, s_edges);
    

    proj = accumarray(bin_idx(~isnan(bin_idx)), ...
                      pixel_vals(~isnan(bin_idx)), ...
                      [num_detectors 1], @sum, 0);
    
    sinogram(:, ia) = proj;
end
end