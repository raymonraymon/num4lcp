function lambda = solve_lcp(A, b, lambda)
    LD = tril(A);
    U  = triu(A,1);
    for i=1:100    
        lambda = -LD\(U*lambda + b);
        lambda = max(0,lambda);       
    end
end
