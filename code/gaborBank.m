function gabors = gaborBank()
    sz = 51;
    bandwidth = 0.5;
    gamma = 1;
    psi = [0:pi/8:2*pi];
    lambda= [2,5,10,15,30,50];
    theta = [0:pi/8:pi];

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

