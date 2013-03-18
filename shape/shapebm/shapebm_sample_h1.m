function [sh1, ph1] = shapebm_sample_h1(params, sv, sh2)
    
    n = size(sv, 1);
    raw = zeros(n, params.num_hidden1);

    for p=1:4

        stride_h1  = params.num_hidden1 / 4;
        indices_h1 = (p-1)*stride_h1+1:p*stride_h1;
        indices_v  = params.grid.patches(p, :);

        raw(:, indices_h1) = sv(:, indices_v) * params.W1';

    end
    
    raw = raw + sh2 * params.W2 + repmat_fast(params.b1', n);

    ph1 = sigmoid(raw);
    sh1 = draw_bernoulli(ph1);

end