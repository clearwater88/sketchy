function res = meshgridRaster(y,x)
% res = meshgridRaster(y,x)
%
% Applies meshgrid to given input vectors y,x, except result returns pixel
% coordinates in raster-scan (column-major) order.
% inputs:
%   y: vector of y-coordinates to call meshgrid with
%   x: vector of x-coordinates to call meshgrid with
% outputs:
%   res: coordinates of points, in raster-scan (column-major) order

    [a,b] = meshgrid(x,y);
    res = [b(:),a(:)];
end

