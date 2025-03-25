function lambda = solve_lcp(A, b, lambda)
    LD = tril(A);
    U  = triu(A,1);
    
    for i=1:100    
        lambda = -LD\(U*lambda + b);
        lambda = max(0,lambda); 
%         y   = abs( A*lambda + b );   % Abs is used to fix problem with negative y-values.
%         err = lambda'*y;
%         if err < 1e-15
%             disp(i)
%             break;
%         end
    end

     
end
