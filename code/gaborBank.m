function gabors = gaborBank()
    sz = 27;
    bandwidth = 0.5;
    gamma = 1;
    psi = [0:pi/4:2*pi];
    lambda= [5,10,15];
    theta = [0:pi/4:pi];

    gabors = zeros([sz,sz,numel(psi)*numel(lambda)*numel(theta)]);
    
    count = 1;
    for (i_psi = 1:numel(psi))
        for (i_lambda = 1:numel(lambda))
            for (i_theta = 1:numel(theta))
                gabors(:,:,count) = getGabor(bandwidth, ...
                                             gamma, ...
                                             psi(i_psi), ...
                                             lambda(i_lambda), ...
                                             theta(i_theta), ...
                                             sz);
                count = count+1;
            end
        end
    end
end

