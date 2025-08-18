function [index_a, index_b] = get2DIndices(num_ages, age_a, age_b, eth_a, eth_b)

% Function to return the indices in an extended matrix for a specified pair
% of age-ethnicity combinations
% The age indices should be between 1 and nAges
% The ethnicity indices be between 1 and nEthnicities
% The output indixes will be between 1 and (nAges*nEthnicities)


    index_a = age_a + num_ages*(eth_a-1);
    index_b = age_b + num_ages*(eth_b-1);
end