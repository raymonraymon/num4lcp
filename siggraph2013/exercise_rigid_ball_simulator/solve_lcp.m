function lambda = solve_lcp(A, b, lambda)

LD = tril(A);
U  = triu(A,1);

for i=1:100
    
    lambda = -LD\(U*lambda + b);
    lambda = max(0,lambda);
    
    w = (LD*(U*lambda)) + b;
    H = min(w,lambda);
    theta = H'*H;
    
    if theta < 0.0001
        return
    end
end
end
