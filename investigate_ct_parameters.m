function phantom = make_circle_phantom(N, bg_mu, circles)
% make_circle_phantom
% N      : matrix size (N x N)
% bg_mu  : background attenuation value
% circles: struct array with fields .x, .y, .r, .mu
%          coordinates in normalized units [-1,1]x[-1,1]

if nargin < 2 || isempty(bg_mu)
    bg_mu = 0;
end
if nargin < 3
    circles = struct('x',0,'y',0,'r',0.8,'mu',1.0);
end

[x,y] = meshgrid(linspace(-1,1,N));
phantom = bg_mu * ones(N);

for k = 1:numel(circles)
    mask = (x - circles(k).x).^2 + (y - circles(k).y).^2 <= circles(k).r^2;
    phantom(mask) = circles(k).mu;
end
end
