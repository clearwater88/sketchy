function gabors = gaborBank()

    % gabors: [y,x,#psi,#lambda,#theta]

    sz = 27;
    bandwidth = 0.5;
    gamma = 1;
    psi = [0:pi/4:2*pi];
    lambda= [5,10,15];
    theta = [0:pi/4:pi];

    %gabors = zeros([sz,sz,numel(psi)*numel(lambda)*numel(theta)]);
    gabors = zeros([sz,sz,numel(psi),numel(lambda),numel(theta)]);

    
    for (i_psi = 1:numel(psi))
        for (i_lambda = 1:numel(lambda))
            for (i_theta = 1:numel(theta))
                gabors(:,:,i_psi,i_lambda,i_theta) = ...
                    getGabor(bandwidth, ...
                    gamma, ...
                    psi(i_psi), ...
                    lambda(i_lambda), ...
                    theta(i_theta), ...
                    sz);
            end
        end
    end
end

