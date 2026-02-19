function plotCumulativeSummary(outTab, outTabAge, cumData, cumDataAge, ...
    popCountMatrix10, popByEth, overwriteFig, perCapita, figDir)

% Function that plots histograms comparing the number of cases, admissions
% and deaths for different ethnicities between model runs

% INPUTS:
% - outTab: model summary at the age-aggregated level
% - outTabAge: model summary at the age-disaggregated level
% - cumData: cumulative real data age-aggregated
% - cumDataAge: cumulative real data age-disaggregated
% - popCountMatrix10: Population count by ethnicity and 10 year age group
% - perCapita: set to true to get rates per 100k, or false to get absolute numbers

% OUTPUTS:
% - .png figures in results, if they don't already exist or if overwriteFig
%   set to true

scenario_names = unique(outTab.scenario, 'stable');
ethnicity_names = unique(outTab.ethnicity, 'stable');
nScenarios = numel(scenario_names);
nEthnicities = numel(ethnicity_names);

% For consistency with other graphs, use colors 1, 2 and 3 for scnearios 1,
% 4 and 5, and color 4 for scenario 3 (and hence use color 5 for scenario
% 2)
colIndex = [1, 4, 5, 2, 3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rescale data to per 100k if perCapita == true
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if perCapita == true
    plotTitle = 'Cumulative numbers (per 100,000)';
    subplotYaxis = {'infections per 100,000', 'cases per 100,000', 'admissions per 100,000', 'deaths per 100,000'};

    % rescale aggregate data
    vars = outTab.Properties.VariableNames;
    pop_vec = repmat(popByEth', nScenarios, 1);

    for i = 3:numel(vars) % ignore first two columns for rescaling (scenario and ethnicity)
        outTab.(vars{i}) = 1e5 * outTab.(vars{i}) ./ pop_vec;
    end

    % rescale age data
    vars = outTabAge.Properties.VariableNames;
    pop_vec = repmat(reshape(popCountMatrix10, [], 1), nScenarios, 1);

    for i = 4:numel(vars) % ignore first three columns for rescaling (scenario, ethnicity and age)
        outTabAge.(vars{i}) = 1e5 * outTabAge.(vars{i}) ./ pop_vec;
    end

    % rescale data
    cumData = 1e5*cumData ./ repmat(popByEth, 1, 3);
    cumDataAge = 1e5*cumDataAge ./ repmat(popCountMatrix10, 1, 3);

else
    plotTitle = 'Cumulative numbers (total)';
    subplotYaxis = {'infections', 'cases', 'admissions', 'deaths'};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make table of relative errors in cumulative results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get relevant data (1:4 is cases, 5:8 is admissions, 9:12 is deaths)
admByEthData = cumData(5:8)';
deathsByEthData = cumData(9:12)';
relErrAdm = zeros(nScenarios, 1);
relErrDeaths = zeros(nScenarios, 1);
% Calculate relative errors for each scenario
for iScenario = 1:nScenarios
    admByEthModel = outTab.cumAdmissionsMedian(contains(outTab.scenario, string(iScenario)), :);
    deathsByEthModel = outTab.cumDeathsMedian(contains(outTab.scenario, string(iScenario)), :);
    relErrAdm(iScenario) = sum(abs(admByEthModel-admByEthData)./abs(admByEthData));
    relErrDeaths(iScenario) = sum(abs(deathsByEthModel-deathsByEthData)./abs(deathsByEthData));
end
% Put results in a tbale
tbl = table(scenario_names, relErrAdm, relErrDeaths);
tbl = renamevars(tbl, {'scenario_names'}, {'Scenario'});

% Save table if it doesn't already exist or if overwrite flag is on
fName = append(figDir, "error_table.csv");
if exist(fName, 'file') == 0 || overwriteFig
    writetable(tbl, fName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

age_groups = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70+'};
subplotTitles = {'(a) Infections', '(b) Cases', '(c) Admissions', '(d) Deaths'};

% Define a colormap with the desired colors
tmp = colororder;
colours = tmp(colIndex, :);


f = figure;
set(f, 'WindowStyle', 'normal');
f.Position = [50 100 1000 800];
tiledlayout(2, 2, 'TileSpacing', 'tight');
sgtitle(plotTitle);
xla = reordercats(categorical(ethnicity_names), ["European", "Māori", "Pacific", "Asian"]);

% Calculating the width for each bar group (for errorbars)
groupwidth = min(0.8, nScenarios / (nScenarios + 1.5));

for i = 1:numel(subplotYaxis)
    nexttile
    title(subplotTitles(i))

    % Pull out data for different runs - rows are runs, columns are
    % ethnicities

    % Rows are ethnicities, columns are model scenarios
    if i == 1 % infections
        dummy = reshape(outTab.cumInfectionsMedian, nEthnicities, nScenarios); 
        lower_vals = reshape(outTab.cumInfectionsLower, nEthnicities, nScenarios); 
        upper_vals = reshape(outTab.cumInfectionsUpper, nEthnicities, nScenarios); 
    elseif i == 2 % cases
        dummy = reshape(outTab.cumCasesMedian, nEthnicities, nScenarios);
        lower_vals = reshape(outTab.cumCasesLower, nEthnicities, nScenarios); 
        upper_vals = reshape(outTab.cumCasesUpper, nEthnicities, nScenarios); 
    elseif i == 3 % admissions
        dummy = reshape(outTab.cumAdmissionsMedian, nEthnicities, nScenarios); 
        lower_vals = reshape(outTab.cumAdmissionsLower, nEthnicities, nScenarios); 
        upper_vals = reshape(outTab.cumAdmissionsUpper, nEthnicities, nScenarios); 
    elseif i == 4 % deaths
        dummy = reshape(outTab.cumDeathsMedian, nEthnicities, nScenarios); 
        lower_vals = reshape(outTab.cumDeathsLower, nEthnicities, nScenarios); 
        upper_vals = reshape(outTab.cumDeathsUpper, nEthnicities, nScenarios); 
    end

    % Create grouped bar plot
    b = bar(xla, dummy);
    hold on

    for k = 1:nScenarios
        % Set the colors of the bars
        b(k).FaceColor = colours(k, :); 

        % Add error bars
        x = (1:nEthnicities) - groupwidth/2 + (2*k-1) * groupwidth / (2*nScenarios);
        errorbar(x, dummy(:, k), dummy(:, k) - lower_vals(:, k), ...
            upper_vals(:, k) - dummy(:, k), 'k', 'linestyle', 'none', 'LineWidth', 1);
    end

    % Overlay real data (except for infections)
    if i ~= 1
        for iEth = 1:nEthnicities
            % Elements of cumData are [cases for eth1 ... eth4, admissions for eth1 ... eth4, deaths for eth1 ... eth4]
            y = cumData(nEthnicities*(i-2) + iEth);
            plot([iEth-0.5, iEth+0.5], y*[1 1], 'k--', 'LineWidth', 2)
        end
    end
    hold off

    % Customize the plot
    ylabel(subplotYaxis{i});
    title(subplotTitles{i});

end

% Create a dummy plot for the red dashed line to include in the legend
hold on
hData = plot(NaN, NaN, 'k--', 'LineWidth', 2); % Invisible placeholder
hold off

% Create legend including scenario names and the real data line
leg = legend([b, hData], [scenario_names; {'Data'}], 'Interpreter', 'none');
leg.Layout.Tile = 'South';



% Save figure if it doesn't already exist or if overwrite flag is on
figLabel = append(figDir, plotTitle, '.png');
if exist(figLabel, 'file') == 0 || overwriteFig
    saveas(f, figLabel)
end


%% Age split plot

if perCapita
    subplotYaxis = {'cases per 100,000', 'admissions per 100,000', 'deaths per 100,000'};
    subplotTitles = {'Cases by age (per 100,000)', 'Admissions by age (per 100,000)', ...
        'Deaths by age (per 100,000)'};
else
    subplotYaxis = {'cases', 'admissions', 'deaths'};
    subplotTitles = {'Cases by age', 'Admissions by age', 'Deaths by age'};
end

for nplots = 1:3

    f = figure;
    set(f, 'WindowStyle', 'normal');
    f.Position = [100*nplots 100 1000 800];
    tiledlayout(3, 3);
    sgtitle(subplotTitles(nplots));

    for i = 1:numel(age_groups)
        nexttile
        title(age_groups(i))
        hold on

        % Pull out data for different runs by ag
        % Rows are ethnicities, columns are model scenarios
        if nplots == 1 % cases
            dummy = reshape(outTabAge.cumCasesMedian(outTabAge.age == age_groups(i)), ...
                nEthnicities, nScenarios); 
            lower_vals = reshape(outTabAge.cumCasesLower(outTabAge.age == age_groups(i)), ...
                nEthnicities, nScenarios); 
            upper_vals = reshape(outTabAge.cumCasesUpper(outTabAge.age == age_groups(i)), ...
                nEthnicities, nScenarios); 
        elseif nplots == 2 % admissions
            dummy = reshape(outTabAge.cumAdmissionsMedian(outTabAge.age == age_groups(i)), ...
                nEthnicities, nScenarios); 
            lower_vals = reshape(outTabAge.cumAdmissionsLower(outTabAge.age == age_groups(i)), ...
                nEthnicities, nScenarios); 
            upper_vals = reshape(outTabAge.cumAdmissionsUpper(outTabAge.age == age_groups(i)), ...
                nEthnicities, nScenarios); 
        elseif nplots == 3 % deaths
            dummy = reshape(outTabAge.cumDeathsMedian(outTabAge.age == age_groups(i)), ...
                nEthnicities, nScenarios); 
            lower_vals = reshape(outTabAge.cumDeathsLower(outTabAge.age == age_groups(i)), ...
                nEthnicities, nScenarios); 
            upper_vals = reshape(outTabAge.cumDeathsUpper(outTabAge.age == age_groups(i)), ...
                nEthnicities, nScenarios); 
        end

        % Create grouped bar plot
        b = bar(xla, dummy);

        for k = 1:nScenarios
            % Set the colors of the bars
            b(k).FaceColor = colours(k, :);

            % Add error bars
            x = (1:nEthnicities) - groupwidth/2 + (2*k-1) * groupwidth / (2*nScenarios);
            errorbar(x, dummy(:, k), dummy(:, k) - lower_vals(:, k), ...
                upper_vals(:, k) - dummy(:, k), 'k', 'linestyle', 'none', 'LineWidth', 1);
        end


        hold on
        for iEth = 1:nEthnicities
            % Columns of cumDataAge are [cases for eth1 ... eth4, admissions for eth1 ... eth4, deaths for eth1 ... eth4]
            y = cumDataAge(i, nEthnicities*(nplots-1) + iEth);
            plot([iEth-0.5, iEth+0.5], y*[1 1], 'k--' , 'LineWidth', 2)
        end

        % Customize the plot
        ylabel(subplotYaxis{nplots});
        hold off

    end

    % Create a dummy plot for the red dashed line to include in the legend
    hold on
    hData = plot(NaN, NaN, 'k--', 'LineWidth', 2); % Invisible placeholder
    hold off

    % Create legend including scenario names and the real data line
    leg = legend([b, hData], [scenario_names; {'Data'}], 'Interpreter', 'none');
    leg.Layout.Tile = 9;%'South';


    % Save figure if it doesn't already exist or if overwrite flag is on
    figLabel = append(figDir, 'Cumulative ', subplotTitles{nplots}, '.png');
    if exist(figLabel, 'file') == 0 || overwriteFig
        pause(0.1)
        saveas(f, figLabel)
    end

end


end