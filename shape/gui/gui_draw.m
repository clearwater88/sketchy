function gui_draw(handles)

    H = handles.settings.H;
    W = handles.settings.W;

    output          = zeros(H*W, 3);
    brush           = handles.brush;
    mask            = handles.mask;
    ground          = handles.ground;
    pv              = handles.pv;
    
    % the masked parts of the image
    output(mask, 1) = 176/255*(0.35 + 0.65*pv(mask));
    output(mask, 2) = 227/255*(0.35 + 0.65*pv(mask));
    output(mask, 3) = 246/255*(0.35 + 0.65*pv(mask));
    
    % the unmasked parts of the image
    output(~mask, 1) = ground(~mask);
    output(~mask, 2) = ground(~mask);
    output(~mask, 3) = ground(~mask);
    
    % the brush
    if any(brush)
        
        switch handles.brush_type
            
            case 'white'
                output(brush, :) = 1;
                
            case 'black'
                output(brush, :) = 0;
                
            case 'cut'
               output(brush, 1) = 36/255; 
               output(brush, 2) = 144/255;
               output(brush, 3) = 184/255;
               
            case 'uncut'
               output(brush, :) = 0.6;
               
        end
        
    end
    
    % display
    imagesc(reshape(output, H, W, 3));
    axis image;
    axis off;
    
    % flush
    drawnow;

end