function head = generate_head_phantom(N)
% generate_head_phantom
% Replacement for MATLAB phantom(N) that does NOT require Image Processing
% Toolbox. Generates a Shepp-Logan-like head phantom.
%
% N : image size (NxN)

if nargin < 1 || isempty(N)
    N = 256;
end

head = shepp_logan_phantom(N);

end


function P = shepp_logan_phantom(N)

ellipses = [ ...
    2   .69 .92   0      0      0;    
   -0.98 .6624 .8740  0   -.0184  0;  
   -0.02 .1100 .3100  .22 0      -18;
   -0.02 .1600 .4100 -.22 0       18;
    0.01 .2100 .2500  0    .35    0;
    0.01 .2100 .2500  0   -.35    0;
    0.01 .0460 .0460  .0   .1     0;
    0.01 .0460 .0460  .0  -.1     0;
    0.01 .0460 .0230 -.08 -.605   0;
    0.01 .0230 .0230  .0  -.606   0];


[x, y] = meshgrid(linspace(-1,1,N));

P = zeros(N);

for k = 1:size(ellipses,1)
    A   = ellipses(k,1);  
    a   = ellipses(k,2);  
    b   = ellipses(k,3);  
    x0  = ellipses(k,4);   
    y0  = ellipses(k,5);   
    phi = ellipses(k,6)*pi/180; 


    x_shift = x - x0;
    y_shift = y - y0;

 
    x_rot =  x_shift*cos(phi) + y_shift*sin(phi);
    y_rot = -x_shift*sin(phi) + y_shift*cos(phi);


    mask = (x_rot./a).^2 + (y_rot./b).^2 <= 1;

    P(mask) = P(mask) + A;
end


P = P - min(P(:));
P = P ./ max(P(:) + eps);

end
