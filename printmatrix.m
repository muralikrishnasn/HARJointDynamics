function printmatrix(C)
    fprintf('np.array([')
    for i = 1: size(C,1)
        fprintf('[')
        for j = 1: size(C,2)
            if(j ~= size(C,2))
                fprintf('%d, ',C(i,j))
            else
                fprintf('%d',C(i,j))
            end
        end
          fprintf('],\n')
    end
    fprintf('])\n')
end
