function contactMatrix = calcContactMatrix(C, popCountMatrix, assort, totalContactFreq)

% Calculate generalise contact matrix between age-ethnicity combinations

num_ages = size(popCountMatrix, 1); % useful variable to have
num_eth = size(popCountMatrix, 2); % useful variable to have

if num_eth == 1 % just one population

    contactMatrix = 0.5*(C + (popCountMatrix.')./(popCountMatrix) .* (C.')); % usual calculation

else % multiple ethnicities

    % First, make symmetrical contact matrix without ethnicities
    popByAge = sum(popCountMatrix, 2); % this is a column vector
    contactMatrixOverall = 0.5*(C + (popByAge.')./(popByAge) .* (C.')); % usual calculation

    % pre-allocate matrices for the proportion mixing (PM) and seggregated
    % mixing (SM) cases
    contactMatrix_PM = zeros(numel(popCountMatrix), numel(popCountMatrix)); 
    contactMatrix_SM = zeros(numel(popCountMatrix), numel(popCountMatrix)); 


    % Check totalContactFreq has num_eth elements
    if numel(totalContactFreq) ~= num_eth
        error('Total contact frequency is not a vector with the number of ethnicities, please check.')
    end


    % Calculate denominator matrices in the definition of C (summing
    % over ethnicities, so these matrices are just num_ages x num_ages)
    denominator_matrix_PM = zeros(num_ages, num_ages);
    denominator_matrix_SM = zeros(num_ages, num_ages);
    for age_a = 1:num_ages
        for age_b = 1:num_ages
            for eth_a = 1:num_eth
                for eth_b = 1:num_eth
                    denominator_matrix_PM(age_a, age_b) = denominator_matrix_PM(age_a, age_b) + ...
                        popCountMatrix(age_a, eth_a)*popCountMatrix(age_b, eth_b)*...
                        totalContactFreq(eth_a)*totalContactFreq(eth_b);
                end
                denominator_matrix_SM(age_a, age_b) = denominator_matrix_SM(age_a, age_b) + popCountMatrix(age_a, eth_a)*popCountMatrix(age_b, eth_a)*totalContactFreq(eth_a)/sum(popCountMatrix(:, eth_a));
            end
        end
    end




    for age_a = 1:num_ages % go through age groups of individual a
        for age_b = 1:num_ages % go through age groups of individual b
            for eth_a = 1:num_eth % go through ethnicity groups of individual a
                for eth_b = 1:num_eth % go through ethnicity groups of individual b
                    [index_a, index_b] = get2DIndices(num_ages, age_a, age_b, eth_a, eth_b); % get indices of matrix
                    contactMatrix_PM(index_a, index_b) = ...
                        contactMatrixOverall(age_a, age_b)*...
                        sum(popCountMatrix(age_a, :))*popCountMatrix(age_b, eth_b)*...
                        totalContactFreq(eth_a)*totalContactFreq(eth_b)/ ...
                        denominator_matrix_PM(age_a, age_b); 
                    % SM matrix is only non-zero within ethnicity groups
                    if eth_a == eth_b
                     contactMatrix_SM(index_a, index_b) = ...
                        contactMatrixOverall(age_a, age_b)*...
                        sum(popCountMatrix(age_a, :))*popCountMatrix(age_b, eth_b)*...
                        totalContactFreq(eth_a)/sum(popCountMatrix(:, eth_a)) /denominator_matrix_SM(age_a, age_b);  
                    end
                end
            end
        end
    end

    contactMatrix = (1-assort)*contactMatrix_PM + assort*contactMatrix_SM;


end

end

