function phantom = make_rectangle_phantom(N, bg_mu, rect)
% make_rectangle_phantom
% N      : matrix size
% bg_mu  : background attenuation value
% rect   : struct with .x, .y, .width, .height, .mu (all in normalized coords)

if nargin < 2 || isempty(bg_mu)
    bg_mu = 0;
end
if nargin < 3 || isempty(rect)
    rect.x      = 0;
    rect.y      = 0;
    rect.width  = 1.0;  
    rect.height = 0.5;  
    rect.mu     = 1.0;
end

[x,y] = meshgrid(linspace(-1,1,N));
phantom = bg_mu * ones(N);

mask = abs(x - rect.x) <= rect.width/2 & abs(y - rect.y) <= rect.height/2;
phantom(mask) = rect.mu;
end
