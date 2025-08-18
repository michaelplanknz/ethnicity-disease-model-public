function rates = calcRates(baseRate, OR)

% Calculate a set of rates from a base rate and a set of ORs

rates = OR./(OR + (1-baseRate)/baseRate);

