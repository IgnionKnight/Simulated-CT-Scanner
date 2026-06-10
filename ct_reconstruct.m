function [pos, prof] = profile_along_line(img, orientation, idx)
% profile_along_line
% img        : 2D image
% orientation: 'row' or 'col'
% idx        : row or column index to sample

[H,W] = size(img);

if strcmpi(orientation, 'row')
    idx = max(min(idx, H), 1);
    prof = img(idx, :);
    pos  = 1:W;
elseif strcmpi(orientation, 'col')
    idx = max(min(idx, W), 1);
    prof = img(:, idx);
    pos  = 1:H;
else
    error('orientation must be ''row'' or ''col''.');
end
end
