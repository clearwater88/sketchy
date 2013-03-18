function gui_init(hObject, handles, reset_only)

    if nargin == 2
        reset_only = false;
    end

    info_string = 'Model structure:  ';
    info_string = [info_string '(' num2str(handles.active_dataset.H) 'x' num2str(handles.active_dataset.W) ')'];
    info_string = [info_string '-(' num2str(handles.active_params.num_hidden1) ')-(' num2str(handles.active_params.num_hidden2) ')'];
    
    info_string = [info_string 10];
    info_string = [info_string num2str(handles.settings.gibbs_skip) ' Gibbs iterations / frame.'];
    
    set(handles.pushbutton1, 'Enable', 'on');
    set(handles.pushbutton2, 'Enable', 'off');
    set(handles.pushbutton3, 'Enable', 'on');
    set(handles.pushbutton4, 'Enable', 'on');    
    set(handles.text1, 'String', info_string);
    
    if ~reset_only
        
        if ~isfield(handles, 'active_image_id')
            handles.active_image_id = ceil(rand*handles.active_dataset.n);
        end
        
        old_id = handles.active_image_id;
        
        while old_id == handles.active_image_id
            
            handles.active_image_id = ceil(rand*handles.active_dataset.n);
            handles.active_image    = double(handles.active_dataset.images(handles.active_image_id, :) > 0.5);
            
        end
        
    end
    
    handles.ground          = handles.active_image;
    handles.brush           = zeros(1, handles.settings.H*handles.settings.W) > 0;
    handles.pv              = zeros(1, handles.settings.H*handles.settings.W) > 0;   
    handles.brush_type      = 'cut';
    handles.is_painting     = false;
    
    mask = zeros(handles.settings.H, handles.settings.W);
    
    y1 = 0;
    y2 = 0;

    while y2 <= y1 || y2 - y1 <= handles.settings.H/2
        y1 = ceil(rand*handles.settings.H);
        y2 = ceil(rand*handles.settings.H);
    end

    x1 = 0;
    x2 = 0;

    while x2 <= x1 || x2 - x1 <= handles.settings.H/2
        x1 = ceil(rand*handles.settings.H);
        x2 = ceil(rand*handles.settings.H);
    end
    
    mask(y1:y2, x1:x2)      = 1;
    handles.mask            = reshape(mask, 1, handles.settings.H*handles.settings.W) > 0;
    
    guidata(hObject, handles);
    gui_draw(handles);

end