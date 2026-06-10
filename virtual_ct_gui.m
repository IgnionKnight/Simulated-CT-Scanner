function virtual_ct_gui()
% VIRTUAL_CT_GUI
    thisDir = fileparts(mfilename('fullpath'));
    addpath(fullfile(thisDir, 'ProjectFunctions'));

    % ------- MAIN FIGURE -------
    fig = uifigure('Name','Virtual CT Scanner','Position',[100 100 1200 600]);

    % ------- STATE -------
    data.phantom     = [];
    data.sinogram    = [];
    data.theta       = [];
    data.recon       = [];
    guidata(fig, data);

    % ------- CONTROL PANEL -------
    pnl = uipanel(fig,'Title','Controls','Position',[10 10 280 580]);
    
    % Phantom type
    uilabel(pnl,'Position',[10 540 100 20],'Text','Phantom type:');
    ddPhantom = uidropdown(pnl, ...
        'Position',[120 540 140 22], ...
        'Items',{'Circles','Rectangle','Head (MATLAB phantom)'}, ...
        'Value','Circles');
    
    % Matrix size
    uilabel(pnl,'Position',[10 510 100 20],'Text','Matrix size N:');
    edtN = uieditfield(pnl,'numeric','Position',[120 510 80 22],'Value',256);
    
    % Angle step
    uilabel(pnl,'Position',[10 480 100 20],'Text','Angle step (deg):');
    edtTheta = uieditfield(pnl,'numeric','Position',[120 480 80 22],'Value',2);
    
    % Number of detectors
    uilabel(pnl,'Position',[10 450 120 20],'Text','# Detectors:');
    edtDet = uieditfield(pnl,'numeric','Position',[120 450 80 22],'Value',200);
    
    % Detector spacing
    uilabel(pnl,'Position',[10 420 120 20],'Text','Detector spacing:');
    edtDetSpacing = uieditfield(pnl,'numeric','Position',[120 420 80 22],'Value',1.0);
    
    % Detector array type
    uilabel(pnl,'Position',[10 390 120 20],'Text','Detector type:');
    ddDetType = uidropdown(pnl,'Position',[120 390 140 22], ...
        'Items',{'Linear','Arc'}, ...
        'Value','Linear');
    
    % Source distance
    uilabel(pnl,'Position',[10 360 120 20],'Text','Source distance:');
    edtSourceDist = uieditfield(pnl,'numeric','Position',[120 360 80 22],'Value',2.0);
    
    % Acquisition time
    uilabel(pnl,'Position',[10 330 120 20],'Text','Acq. time (s):');
    edtAcqTime = uieditfield(pnl,'numeric','Position',[120 330 80 22],'Value',1.0);
    
    % Filter type
    uilabel(pnl,'Position',[10 300 100 20],'Text','Filter:');
    ddFilter = uidropdown(pnl,'Position',[120 300 140 22], ...
        'Items',{'Ram-Lak','Shepp-Logan','Cosine','Hann','Hamming','None'}, ...
        'Value','None');
    
    % Buttons
    btnPhantom = uibutton(pnl,'push', ...
        'Text','1) Generate Phantom', ...
        'Position',[30 260 220 30], ...
        'ButtonPushedFcn',@onGeneratePhantom);
    
    btnAcquire = uibutton(pnl,'push', ...
        'Text','2) Acquire Sinogram', ...
        'Position',[30 220 220 30], ...
        'ButtonPushedFcn',@onAcquire);
    
    btnRecon = uibutton(pnl,'push', ...
        'Text','3) Reconstruct Image', ...
        'Position',[30 180 220 30], ...
        'ButtonPushedFcn',@onReconstruct);
    
    btnAnalyze = uibutton(pnl,'push', ...
        'Text','4) Analyze (Diff + Profiles)', ...
        'Position',[30 140 220 30], ...
        'ButtonPushedFcn',@onAnalyze);
    
    % --- SI/Contrast Display Area ---
    uilabel(pnl,'Position',[10 100 260 20],'Text','Signal Intensity & Contrast:', ...
        'FontWeight','bold');
    
    txtSI = uitextarea(pnl,'Position',[10 20 260 75], ...
        'Value',{'Click Analyze to compute','SI and Contrast values'}, ...
        'Editable','off');

    % ------- AXES FOR DISPLAY -------
    ax1 = uiaxes(fig,'Position',[310 310 260 260]); title(ax1,'Phantom');
    ax2 = uiaxes(fig,'Position',[580 310 260 260]); title(ax2,'Sinogram');
    ax3 = uiaxes(fig,'Position',[850 310 260 260]); title(ax3,'Reconstruction');
    ax4 = uiaxes(fig,'Position',[310 20 520 260]);  title(ax4,'Profiles');
    ax5 = uiaxes(fig,'Position',[850 20 260 260]);  title(ax5,'Difference');

    % ------------- CALLBACKS -------------

    function onGeneratePhantom(~,~)
        data = guidata(fig);
        N = round(edtN.Value);
        if N <= 0, uialert(fig,'N must be > 0','Error'); return; end

        switch ddPhantom.Value
            case 'Circles'
                bg_mu = 0;
                c1 = struct('x',0,'y',0,'r',0.8,'mu',0.5);
                c2 = struct('x',-0.3,'y',0.2,'r',0.15,'mu',1.0);
                c3 = struct('x',0.4,'y',-0.1,'r',0.1,'mu',0.9);
                data.phantom = make_circle_phantom(N, bg_mu, [c1,c2,c3]);

            case 'Rectangle'
                bg_mu = 0;
                rect.x      = 0;
                rect.y      = 0;
                rect.width  = 1.0;
                rect.height = 0.5;
                rect.mu     = 1.0;
                data.phantom = make_rectangle_phantom(N, bg_mu, rect);

            case 'Head (MATLAB phantom)'
                data.phantom = generate_head_phantom(N);
        end

        imagesc(ax1, data.phantom); colormap(ax1,'gray');
        axis(ax1,'image'); colorbar(ax1); title(ax1,'Phantom');

        % Clear downstream results
        data.sinogram = [];
        data.theta    = [];
        data.recon    = [];
        cla(ax2); cla(ax3); cla(ax4); cla(ax5);
        title(ax2,'Sinogram'); title(ax3,'Reconstruction');
        title(ax4,'Profiles'); title(ax5,'Difference');

        guidata(fig, data);
    end

    function onAcquire(~,~)
        data = guidata(fig);
        if isempty(data.phantom)
            uialert(fig,'Generate a phantom first.','Error'); return;
        end
    
        theta_step   = edtTheta.Value;
        num_det      = round(edtDet.Value);
        det_spacing  = edtDetSpacing.Value;      
        det_type     = ddDetType.Value;          
        source_dist  = edtSourceDist.Value;
        acq_time     = edtAcqTime.Value;  
        
        % Simulate acquisition with pause (demonstrates time effect)
        pause(acq_time);  
    
        [sino, theta, tvec] = ct_forward_project(data.phantom, theta_step, num_det, ...
                                                   det_spacing, det_type, source_dist);
        

        
        data.sinogram = sino;
        data.theta    = theta;
    
        imagesc(ax2, theta, tvec, sino);
        colormap(ax2,'gray'); colorbar(ax2);
        xlabel(ax2,'\theta (deg)'); ylabel(ax2,'Detector pos');
        title(ax2,sprintf('Sinogram (t=%.1fs, spacing=%.2f, %s, src=%.1f)', ...
                          acq_time, det_spacing, det_type, source_dist));
    
        data.recon = [];
        cla(ax3); cla(ax4); cla(ax5);
        title(ax3,'Reconstruction'); title(ax4,'Profiles'); title(ax5,'Difference');
    
        guidata(fig, data);
    end

    function onReconstruct(~,~)
        data = guidata(fig);
        if isempty(data.sinogram)
            uialert(fig,'Acquire sinogram first.','Error'); return;
        end

        N = size(data.phantom,1);
        filter_type = ddFilter.Value;

        data.recon = ct_reconstruct(data.sinogram, data.theta, N, filter_type);

        imagesc(ax3, data.recon); colormap(ax3,'gray');
        axis(ax3,'image'); colorbar(ax3);
        title(ax3,sprintf('Reconstruction (%s)',filter_type));

        guidata(fig, data);
    end

    function onAnalyze(~,~)
        data = guidata(fig);
        if isempty(data.recon) || isempty(data.phantom)
            uialert(fig,'Need phantom and reconstruction first.','Error'); return;
        end
    
        % --- Difference image
        diff_img = image_difference(data.recon, data.phantom);
        imagesc(ax5, diff_img); colormap(ax5,'gray');
        axis(ax5,'image'); colorbar(ax5);
        title(ax5,'|Reconstruction - Phantom|');
    
        % --- Profiles through center column
        Np = size(data.phantom,1);
        [pos, profP] = profile_along_line(data.phantom,'col',round(Np/2));
    
        Nr = size(data.recon,1);
        [~,   profR] = profile_along_line(data.recon,'col',round(Nr/2));
    
        L = min(length(profP), length(profR));
        profP = profP(1:L);
        profR = profR(1:L);
        pos   = pos(1:L);
    
        cla(ax4);
        plot(ax4, pos, profP,'LineWidth',1.5); hold(ax4,'on');
        plot(ax4, pos, profR,'--','LineWidth',1.5);
        xlabel(ax4,'Position'); ylabel(ax4,'Signal Intensity');
        legend(ax4,{'Phantom','Reconstruction'});
        title(ax4,'Signal Intensity Profiles (Center Column)');
        
   
        N = size(data.recon, 1);
        center = round(N/2);
        roi_size = round(N/10);
        
        mask1 = false(N);
        mask1(center-roi_size:center+roi_size, center-roi_size:center+roi_size) = true;
        
        mask2 = false(N);
        mask2(10:10+roi_size, 10:10+roi_size) = true;
        
        [SI1_p, SI2_p, contrast_p] = si_contrast(data.phantom, mask1, mask2);
        [SI1_r, SI2_r, contrast_r] = si_contrast(data.recon, mask1, mask2);
        
        results = {
            '=== PHANTOM ==='
            sprintf('  ROI 1: %.4f', SI1_p)
            sprintf('  ROI 2: %.4f', SI2_p)
            sprintf('  Contrast: %.4f', contrast_p)
            ''
            '=== RECONSTRUCTION ==='
            sprintf('  ROI 1: %.4f', SI1_r)
            sprintf('  ROI 2: %.4f', SI2_r)
            sprintf('  Contrast: %.4f', contrast_r)
            ''
            sprintf('Error: %.4f', abs(contrast_r - contrast_p))
        };
        txtSI.Value = results;
    end

end
