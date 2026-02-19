function [outTab, outTabAge, cumData, cumDataAge] = cumulativeMetricsByModel(t, bandsData, tData, realData, finalDate, scenario_names, eth_names)

% Function that outputs a table of plots (infections, cases, hospital
% admissions, hospital occupancy, and deaths), which includes best fit
% lines, confidence bands and real data.

% INPUTS:
% t, bandsData, tData, realData, - outputs from function summariseScenarioRuns()
% finalDate - calculate cumulative outcomes up to this date
% scenario_names - labels for each scenario
% eth_names - labels for each ethnicity

% OUTPUTS:
% outTab - table of age-aggregated outcomes (median, lower and upper) for each scenario x ethnicity combination 
% outTabAge - table of outcomes (median, lower and upper) for each scenario x ethnicity x age combination 
% cumData - corresponding vector of cumulative age-aggregated outcomes in real data
% cumDataAge - corresponding matrix of cumulative age-stratified outcomes in real data


nEthnicities = numel(eth_names); % extracting number of ethnicities
age_groups = ["0-9"; "10-19"; "20-29"; "30-39"; "40-49"; "50-59"; "60-69"; "70+"];
nAges = numel(age_groups); % number of age groups

realData = realData(:, :, 3:14); % cut out infection and hospitalisation data

% Now collapse by age

bandsDataByEth = reshape(sum(bandsData, 3), size(bandsData, [1 2 4 5 6]));
realDataByEth = reshape(sum(realData, 2), size(realData, [1 3])); % collapse over age groups


% Totals over age

% set up table

varNames = ["scenario", "ethnicity", "cumInfectionsMedian", "cumInfectionsLower", "cumInfectionsUpper", ...
    "cumCasesMedian", "cumCasesLower", "cumCasesUpper", ...
    "cumAdmissionsMedian", "cumAdmissionsLower", "cumAdmissionsUpper", ...
    "cumDeathsMedian", "cumDeathsLower", "cumDeathsUpper"];
varTypes = ["string", "string", repmat("double", 1, numel(varNames)-2)];
outTab = table('Size', [numel(scenario_names)*nEthnicities numel(varNames)], 'VariableTypes', varTypes, ...
    'VariableNames', varNames);

outTab.scenario = repelem(scenario_names, nEthnicities);
outTab.ethnicity = repmat(eth_names, numel(scenario_names), 1);

% Time range

ind = 1:find(t == finalDate); % for the whole time period

% Now pull out cumulative numbers

row_numbers = 1:nEthnicities; % row counter initialised

for j = 1:numel(scenario_names)

    % -- cumulative infections
    val_range = bandsDataByEth(ind, :, :, 1, j);
    cum_val_range = cumsum(val_range, 1);
    final_vals = cum_val_range(end, :, :);
    final_vals = reshape(final_vals, [], size(final_vals, 3)); % collapse dimension
    slice = quantile(final_vals, 0.5); % getting median alone
    
    for k = 1:nEthnicities
        outTab.cumInfectionsMedian(row_numbers(k)) = slice(k);
        outTab.cumInfectionsLower(row_numbers(k)) = min(final_vals(:, k));
        outTab.cumInfectionsUpper(row_numbers(k)) = max(final_vals(:, k));
    end

    % -- cumulative cases
    val_range = bandsDataByEth(ind, :, :, 2, j);
    cum_val_range = cumsum(val_range, 1);
    final_vals = cum_val_range(end, :, :);
    final_vals = reshape(final_vals, [], size(final_vals, 3)); % collapse dimension
    slice = quantile(final_vals, 0.5); % getting median alone

    for k = 1:nEthnicities
        outTab.cumCasesMedian(row_numbers(k)) = slice(k);
        outTab.cumCasesLower(row_numbers(k)) = min(final_vals(:, k));
        outTab.cumCasesUpper(row_numbers(k)) = max(final_vals(:, k));
    end

    % -- cumulative admissions
    val_range = bandsDataByEth(ind, :, :, 3, j);
    cum_val_range = cumsum(val_range, 1);
    final_vals = cum_val_range(end, :, :);
    final_vals = reshape(final_vals, [], size(final_vals, 3)); % collapse dimension
    slice = quantile(final_vals, 0.5); % getting median alone

    for k = 1:nEthnicities
        outTab.cumAdmissionsMedian(row_numbers(k)) = slice(k);
        outTab.cumAdmissionsLower(row_numbers(k)) = min(final_vals(:, k));
        outTab.cumAdmissionsUpper(row_numbers(k)) = max(final_vals(:, k));
    end

    % -- cumulative deaths
    val_range = bandsDataByEth(ind, :, :, 5, j);
    cum_val_range = cumsum(val_range, 1);
    final_vals = cum_val_range(end, :, :);
    final_vals = reshape(final_vals, [], size(final_vals, 3)); % collapse dimension
    slice = quantile(final_vals, 0.5); % getting median alone

    for k = 1:nEthnicities
        outTab.cumDeathsMedian(row_numbers(k)) = slice(k);
        outTab.cumDeathsLower(row_numbers(k)) = min(final_vals(:, k));
        outTab.cumDeathsUpper(row_numbers(k)) = max(final_vals(:, k));
    end


    row_numbers = row_numbers + nEthnicities; % update row counter

end



% Split by age

% set up table

varNames = ["scenario", "ethnicity", "age", ...
    "cumInfectionsMedian", "cumInfectionsLower", "cumInfectionsUpper", ...
    "cumCasesMedian", "cumCasesLower", "cumCasesUpper", ...
    "cumAdmissionsMedian", "cumAdmissionsLower", "cumAdmissionsUpper", ...
    "cumDeathsMedian", "cumDeathsLower", "cumDeathsUpper"];
varTypes = ["string", "string", repmat("double", 1, numel(varNames)-2)];
outTabAge = table('Size', [numel(scenario_names)*nEthnicities*nAges numel(varNames)], 'VariableTypes', varTypes, ...
    'VariableNames', varNames);

outTabAge.scenario = repelem(scenario_names, nEthnicities*nAges);
outTabAge.ethnicity = repmat(repelem(eth_names, nAges), numel(scenario_names), 1);
outTabAge.age = repmat(age_groups, numel(scenario_names)*nEthnicities, 1);


% Now pull out cumulative numbers

row_numbers = 1:nEthnicities; % row counter initialised
% bandsDataAgeAll dimensions: t * ages * nruns * ethnicities * 6 * models
% 6 metrics: cases, admissions, deaths, admissions per case, CAR and infections per capita

for j = 1:numel(scenario_names)

    % -- cumulative infections
    val_range = bandsData(ind, :, :, :, 1, j);
    cum_val_range = cumsum(val_range, 1);
    final_vals = cum_val_range(end, :, :, :);
    final_vals = reshape(final_vals, [], size(final_vals, 3), size(final_vals, 4)); % collapse dimension

    for age = 1:nAges
        temp = reshape(final_vals(:, age, :), [], size(final_vals, 3)); % collapse dimension
        slice = quantile(temp, 0.5); % getting median alone

        for k = 1:nEthnicities
            outTabAge.cumInfectionsMedian((row_numbers(k)-1)*nAges+age) = slice(k);
            outTabAge.cumInfectionsLower((row_numbers(k)-1)*nAges+age) = min(temp(:, k));
            outTabAge.cumInfectionsUpper((row_numbers(k)-1)*nAges+age) = max(temp(:, k));
        end
    end

    % -- cumulative cases
    val_range = bandsData(ind, :, :, :, 2, j);
    cum_val_range = cumsum(val_range, 1);
    final_vals = cum_val_range(end, :, :, :);
    final_vals = reshape(final_vals, [], size(final_vals, 3), size(final_vals, 4)); % collapse dimension

    for age = 1:nAges
        temp = reshape(final_vals(:, age, :), [], size(final_vals, 3)); % collapse dimension
        slice = quantile(temp, 0.5); % getting median alone

        for k = 1:nEthnicities
            outTabAge.cumCasesMedian((row_numbers(k)-1)*nAges+age) = slice(k);
            outTabAge.cumCasesLower((row_numbers(k)-1)*nAges+age) = min(temp(:, k));
            outTabAge.cumCasesUpper((row_numbers(k)-1)*nAges+age) = max(temp(:, k));
        end
    end

    % -- cumulative admissions
    val_range = bandsData(ind, :, :, :, 3, j);
    cum_val_range = cumsum(val_range, 1);
    final_vals = cum_val_range(end, :, :, :);
    final_vals = reshape(final_vals, [], size(final_vals, 3), size(final_vals, 4)); % collapse dimension

    for age = 1:nAges
        temp = reshape(final_vals(:, age, :), [], size(final_vals, 3)); % collapse dimension
        slice = quantile(temp, 0.5); % getting median alone

        for k = 1:nEthnicities
            outTabAge.cumAdmissionsMedian((row_numbers(k)-1)*nAges+age) = slice(k);
            outTabAge.cumAdmissionsLower((row_numbers(k)-1)*nAges+age) = min(temp(:, k));
            outTabAge.cumAdmissionsUpper((row_numbers(k)-1)*nAges+age) = max(temp(:, k));
        end
    end

    % -- cumulative deaths
    val_range = bandsData(ind, :, :, :, 5, j);
    cum_val_range = cumsum(val_range, 1);
    final_vals = cum_val_range(end, :, :, :);
    final_vals = reshape(final_vals, [], size(final_vals, 3), size(final_vals, 4)); % collapse dimension

    for age = 1:nAges
        temp = reshape(final_vals(:, age, :), [], size(final_vals, 3)); % collapse dimension
        slice = quantile(temp, 0.5); % getting median alone

        for k = 1:nEthnicities
            outTabAge.cumDeathsMedian((row_numbers(k)-1)*nAges+age) = slice(k);
            outTabAge.cumDeathsLower((row_numbers(k)-1)*nAges+age) = min(temp(:, k));
            outTabAge.cumDeathsUpper((row_numbers(k)-1)*nAges+age) = max(temp(:, k));
        end
    end

    row_numbers = row_numbers + nEthnicities; % update row counter

end



% Calculate appropriate cumulative numbers from real data

% Define data time indices corresponding to analysis period
ind = tData <= finalDate;

% Sum data over time (1st dimension)
cumData = sum(realDataByEth(ind, :));
cumDataAge = squeeze(sum(realData(ind, :, :)) );


end
