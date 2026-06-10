function [SI1, SI2, contrast_val] = si_contrast(img, mask1, mask2)
% si_contrast
% img      : 2D reconstructed or phantom image
% mask1/2  : logical masks (same size as img)
% SI1,SI2  : mean signal intensity in each ROI
% contrast : absolute difference |SI1 - SI2|

if ~isequal(size(img), size(mask1)) || ~isequal(size(img), size(mask2))
    error('Image and masks must have the same size.');
end

SI1 = mean(img(mask1));
SI2 = mean(img(mask2));
contrast_val = abs(SI1 - SI2);
end
