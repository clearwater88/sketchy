function gui_chain(hObject, handles)
        
    params      = handles.active_params;
    mask        = handles.mask;
    sv_clamp    = handles.ground;
    
    sv          = sv_clamp;
    sh1         = rand(1, params.num_hidden1) > 0.5;
    sh2         = rand(1, params.num_hidden2) > 0.5;
    
    count       = handles.settings.gibbs_skip;

    while equals(get(handles.pushbutton1, 'Enable'), 'off')
               
        % sample
        sh1 = shapebm_sample_h1(params, sv, sh2);
        sh2 = shapebm_sample_h2(params, sh1);
        sh1 = shapebm_sample_h1(params, sv, sh2);
        [sv, pv] = shapebm_sample_v(params, sh1);
        
        % store
        handles.pv = pv;
                
        % clamp
        sv(~mask) = sv_clamp(~mask);
        
        % skip iterations
        if count > handles.settings.gibbs_skip
            gui_draw(handles);
            count = 1;
        else
            count = count + 1;
        end
        
        guidata(hObject, handles);
        
    end

end