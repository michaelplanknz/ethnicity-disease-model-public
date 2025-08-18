function [popCountMatrix, ethnicityLabels] = getPopData(fName, nAgeGroups, nEthnicities)

% Return a population count matrix where columns represent the ethnicities
% named in ethnicityLabels and the rows are 5-year age groups

opts = detectImportOptions(fName);
opts = setvartype(opts, {'Age', 'Asian', 'EuropeanorOther', 'Maori', 'PacificPeoples', 'Various' , 'Total'}, 'double');

% Read data from file
popData = readtable(fName, opts);

% Exclude 'Total' row from data table
popData(isnan(popData.Age), :) = [];

if nEthnicities == 4
    popCountMatrix = [popData.EuropeanorOther, popData.Maori, popData.PacificPeoples, popData.Asian];
    ethnicityLabels = ["European", "Maori", "Pacific", "Asian"];
elseif nEthnicities == 1
    popCountMatrix = popData.Total;
    ethnicityLabels = "Total population";
else
    error('nEthnicities must be either 1 or 4');
end

% Aggregae last age group and remove any additional age groups as required
popCountMatrix(nAgeGroups, :) = sum(popCountMatrix(nAgeGroups:end, :));
popCountMatrix = popCountMatrix(1:nAgeGroups, :);


