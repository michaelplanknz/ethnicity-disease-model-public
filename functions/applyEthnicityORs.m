function rates = applyEthnicityORs(ratesAll, popCountMatrix, OR)

% Applies group-specific odds ratios (OR) to produce ethnicity group-specific rates
% (for e.g. IFR or IHR) such that the average rate within each age group is
% as specified by the input rate_all 
%
% ratesAll should be a n x 1 vector where n is the number of age groups
% OR should be a 1 x m vector where m is the number of ethnicity groups
% popCountMatrix is a n x m matrix of population sizes 
%
% Ethnicities are assumed to be ordered as:
% ["European", "Maori", "Pacific", "Asian"]
% and is it assumed that odds ratios in OR are relative to the European
% group, so OR(1) should always equal 1

nEthnicities = length(OR);
nAges = length(ratesAll);
rates = zeros(nAges, nEthnicities);

% opts = optimoptions('fsolve', 'Display', 'none');

% Do one age group at a a time
for iAge = 1:nAges
    % Proportion in each ethnicity group for this age group:
    p = popCountMatrix(iAge, :)/sum(popCountMatrix(iAge, :));

    % A function that equals zero when x is equal to the correct base rate
    % (i.e. the base rate that when combined with the ORs and pop
    % distribution produces the correct overall rate)
    myFn = @(x)( sum(p.*calcRates(x, OR)) - ratesAll(iAge) );

    % Solve for the correct base rate numerically, initialising the root-finding algorithm at the
    % overall rate:
    % baseRate = fsolve(myFn, ratesAll(iAge), opts);
    baseRate = fzero(myFn, ratesAll(iAge));

    % Calculate the ethnicity-specific rates from the base rate and the
    % specified ORs
    rates(iAge, :) = calcRates(baseRate, OR);
end




