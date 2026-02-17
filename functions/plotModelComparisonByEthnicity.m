function bandsData = plotModelComparisonByEthnicity(t, bandsData, ...
bestFitData, tData, realData, popByEth, plotToDate, scenario_names, ...
    ethnicity_names, overwriteFig, perCapita, scenariosToPlot, figDir)
% Function that plots a grid of plots (infections, cases, hospital
% admissions, hospital occupancy, and deaths), which include a best fit
% line, confidence bands, real data, and vertical lines representing an
% intervention date

% INPUTS:
% - filenameBands: "folder/filename.mat" for bands data
% - filenameBestFit: "folder/filename.mat" for best fit data
% - plotToDate: datetime variable specifying the upper limit for the horizontal (time) axis for the plots
% - dataComb: data for plotting, as output by getAllData.m
% - scenario_names: vector naming the different runs
% - overwriteFig: set to true to overwrite png plots in results
% - perCapita: set to true to plot rates per 100k, or false to plot
% absolute numbers
%
% OUTPUTS:
% - .png figures in results, if they don't already exist or if overwriteFig
%   set to true

% Use function here

% [t, bandsData, bestFitData, tData, realData, ~, ~, ~, popByEth] = ...
%     summariseScenarioRuns(filenameBands, filenameBestFit, dataComb);

% Now collapse by age

% For consistency with other graphs, use colors 1, 2 and 3 for scnearios 1,
% 4 and 5
colIndex = [1, 4, 2, 3];

bandsDataByEth = reshape(sum(bandsData, 3), size(bandsData, [1 2 4 5 6]));
bestFitDataByEth = reshape(sum(bestFitData, 2), size(bestFitData, [1 3 4 5]));
realDataByEth = reshape(sum(realData, 2), size(realData, [1 3])); % collapse over age groups
realDataByEth = realDataByEth(:, 3:14); % cut out infection and hospitalisation data, \
% not broken down by ethnicity


% Write out figure legends
legend_labels = [scenario_names(scenariosToPlot)', "Data"];


% Rescale to per 100,000 if needed

if perCapita == true
    bandsDataByEth = 1e5 * bandsDataByEth ./ reshape(popByEth, 1, 1, 4, 1, 1);
    bestFitDataByEth = 1e5 * bestFitDataByEth ./ reshape(popByEth, 1, 4, 1, 1);
    realDataByEth = 1e5 * realDataByEth./repmat(popByEth, 1, 3);
end


% ------------------------------ PLOTS ------------------------------------

% We now create a figure for each of the metrics (infections, cases, etc.)

smoothDays = [nan, 7, 14, nan, 21];
tPlotRange = [datetime(2022, 1, 1), plotToDate+1];


tmp = colororder;
line_colours = tmp(colIndex, :);

if perCapita == true
    plot_titles = {'New daily infections per 100,000', 'New daily cases per 100,000', ...
        'New daily admissions per 100,000', 'Hospital occupancy per 100,000', ...
        'Daily deaths per 100,000'};
    yaxis_labels = {'daily infections per 100K', 'daily cases per 100K', ...
        'daily admissions per 100K', 'hospital occupancy per 100K', ...
        'daily deaths per 100K'};    
else
    plot_titles = {'New daily infections', 'New daily cases', ...
    'New daily admissions', 'Hospital occupancy', ...
    'Daily deaths'};
    yaxis_labels = {'daily infections', 'daily cases', ...
    'daily admissions', 'hospital occupancy', ...
    'daily deaths'};
end

letters = ["(a) ", "(b) ", "(c) ", "(d) "];

for nplots = 1:numel(plot_titles)

    f = figure;
    set(f, 'WindowStyle', 'normal');
    f.Position = [100*nplots 100 1000 800];
    tiledlayout(2, ceil(length(ethnicity_names)/2), 'TileSpacing', 'tight', 'Padding', 'tight');
    sgtitle(plot_titles(nplots));

    for i = 1:length(ethnicity_names)
        nexttile
        title(letters(i) + ethnicity_names{i})
        hold on
        for j = 1:length(scenariosToPlot)
            kScenario = scenariosToPlot(j);
            plot(t, min(bandsDataByEth(:, :, i, nplots, kScenario), [], 2), 'Color', line_colours(j, :), 'LineStyle', ':', 'LineWidth', 1, 'HandleVisibility', 'off')
            plot(t, max(bandsDataByEth(:, :, i, nplots, kScenario), [], 2), 'Color', line_colours(j, :), 'LineStyle', ':', 'LineWidth', 1, 'HandleVisibility', 'off')
            plot(t, bestFitDataByEth(:, i, nplots, kScenario), 'Color', line_colours(j, :), 'LineWidth', 2)
        end

        % Only plot data for cases (plot 2), admissions (plot 3) and deaths (plot 5), not infections
        % or occupancy as there is ethnicity-stratified data for these
        if ismember(nplots, [2 3 5])
            if nplots == 2
                first_col_pick = 0;
            elseif nplots == 3
                first_col_pick = 4;
            elseif nplots == 5
                first_col_pick = 8;
            end
            plot(tData, smoothdata(realDataByEth(:, first_col_pick+i), 'movmean', smoothDays(nplots)), '-',  'Color', [0 0 0], 'LineWidth', 2)
        end

        hold off
        xlim(tPlotRange)
        ylim([0 inf])
        ylabel(yaxis_labels(nplots))
        grid on
    end

    nexttile(2);
    if ismember(nplots, [2 3 5])
        leg = legend(legend_labels, 'Interpreter', 'none', 'Location', 'northeast');
    else
        leg = legend(legend_labels(1:end-1), 'Interpreter', 'none', 'Location', 'northeast');
    end


    % Save figure if it doesn't already exist or if overwrite flag is on
    figLabel = split(plot_titles(nplots), '.mat');
    figLabel = append(figDir, 'modelComparisonByEthnicity_', figLabel{1}, '.png');
    if exist(figLabel, 'file') == 0 || overwriteFig
        saveas(f, figLabel)
    end

end

end