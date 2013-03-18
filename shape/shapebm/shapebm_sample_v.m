function [sv, pv] = shapebm_sample_v(params, sh1)

    n = size(sh1, 1);
    raw = zeros(n, params.D);
    
    repeated_a = repmat_fast(params.a', n);
    
    for p=1:4

        stride_h1  = params.num_hidden1 / 4;
        indices_h1 = (p-1)*stride_h1+1:p*stride_h1;
        indices_v  = params.grid.patches(p, :);

        raw(:, indices_v) = raw(:, indices_v) + sh1(:, indices_h1) * params.W1;

    end

    raw = raw + repeated_a;
    
    pv = sigmoid(raw);
    sv = draw_bernoulli(pv);
    
end