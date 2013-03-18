function gui_motion(hObject, handles)

    if equals(get(handles.pushbutton1, 'Enable'), 'off')
        return
    end

    H = handles.settings.H;
    W = handles.settings.W;

    position = get(handles.axes1, 'CurrentPoint');
    
    mouse_x = round(position(1, 1));
    mouse_y = round(position(1, 2));
    
    brush = zeros(H, W);
    brush_size_small = floor(0.9*H/32);
    brush_size_large = floor(3*H/32);
    
    switch handles.brush_type
            
        case {'white', 'black'}
            if mouse_x > -brush_size_small+1 && mouse_x < W+brush_size_small && mouse_y > -brush_size_small+1 && mouse_y < H+brush_size_small
                brush(min(H, max(1, mouse_y-brush_size_small:mouse_y+brush_size_small)), ...
                             min(H, max(1, mouse_x-brush_size_small:mouse_x+brush_size_small))) = 1;
            end
            
        case {'cut', 'uncut'}
            if mouse_x > -brush_size_large+1 && mouse_x < W+brush_size_large && mouse_y > -brush_size_large+1 && mouse_y < H+brush_size_large
                brush(min(H, max(1, mouse_y-brush_size_large:mouse_y+brush_size_large)), ...
                             min(H, max(1, mouse_x-brush_size_large:mouse_x+brush_size_large))) = 1;
            end
            
    end
    
    handles.brush = logical(reshape(brush, 1, H*W));

    if handles.is_painting
            
        switch handles.brush_type
    
            case 'white'
                handles.ground(handles.brush) = 1;
                handles.mask = handles.mask & ~handles.brush;
    
            case 'black'
                handles.ground(handles.brush) = 0;
                handles.mask = handles.mask & ~handles.brush;
    
            case 'cut'
                handles.mask = handles.mask | handles.brush;
    
            case 'uncut'
                handles.mask = handles.mask & ~handles.brush;
    
        end
    
    end
    
    guidata(hObject, handles);
    gui_draw(handles);
    
end