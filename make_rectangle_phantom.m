function filtered_sino = apply_ramp_filter(sinogram, filter_type)
% apply_ramp_filter - Apply frequency-domain ramp filter to sinogram
%
% sinogram    : [num_detectors x num_angles]
% filter_type : 'Ram-Lak', 'Shepp-Logan', 'Cosine', 'Hann', 'Hamming'

[num_detectors, num_angles] = size(sinogram);


n_fft = 2^nextpow2(2*num_detectors - 1);


freq = (0:n_fft-1) / n_fft;
freq(freq >= 0.5) = freq(freq >= 0.5) - 1;  


H = abs(freq);  

% Apply window function based on filter type
switch lower(filter_type)
    case 'ram-lak'
       
        
    case 'shepp-logan'
  
        w = sinc(2*freq);
        H = H .* w;
        
    case 'cosine'
  
        w = cos(pi * freq);
        H = H .* w;
        
    case 'hamming'
   
        w = 0.54 + 0.46 * cos(2*pi*freq);
        H = H .* w;
        
    case 'hann'
 
        w = 0.5 + 0.5 * cos(2*pi*freq);
        H = H .* w;
        
    otherwise
        error('Unknown filter type: %s', filter_type);
end


H = H(:);

% Filter each projection independently
filtered_sino = zeros(num_detectors, num_angles);
for ia = 1:num_angles

    proj_fft = fft(sinogram(:, ia), n_fft);
    

    proj_fft_filtered = proj_fft .* H;
    

    proj_filtered = real(ifft(proj_fft_filtered));
    filtered_sino(:, ia) = proj_filtered(1:num_detectors);
end

end