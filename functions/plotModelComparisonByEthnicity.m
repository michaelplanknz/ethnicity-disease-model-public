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

bandsDataByEth = reshape(sum(bandsData, 3), size(bandsData, [1 2 4 5 6]));
bestFitDataByEth = reshape(sum(bestFitData, 2), size(bestFitData, [1 3 4 5]));
realDataByEth = reshape(sum(realData, 2), size(realData, [1 3])); % collapse over age groups
realDataByEth = realDataByEth(:, 3:14); % cut out infection and hospitalisation data, \
% not broken down by ethnicity

% Get scenariosToPlotnd labels

legend_labels = strings(1, 2*numel(scenariosToPlot)+1);
for j = 1:numel(scenariosToPlot)
    legend_labels((j*2-1):2*j) = ["", scenario_names(scenariosToPlot(j))]; % append name of scenario
end
legend_labels(end) = 'Data';


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

%line_colours = hsv(numel(scenario_names)+1); % use colormap
%line_colours(1, :) = []; % Remove the first row
line_colours = hsv(numel(scenario_names)); % use colormap
if size(line_colours, 1) == 1
    line_colours = [0.5 0 0];
end
shade_colours = line_colours;

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
    tiledlayout(2, ceil(length(ethnicity_names)/2));
    sgtitle(plot_titles(nplots));

    for i = 1:length(ethnicity_names)
        nexttile
        title(letters(i) + ethnicity_names{i})
        hold on
        for j = 1:numel(scenario_names)
            if ismember(j, scenariosToPlot)
                fill([t, fliplr(t)], [min(bandsDataByEth(:, :, i, nplots, j), [], 2); ...
                    flipud(max(bandsDataByEth(:, :, i, nplots, j),[], 2))], ...
                    "", "FaceColor", shade_colours(j, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
                plot(t, bestFitDataByEth(:, i, nplots, j), 'Color', line_colours(j, :), 'LineWidth', 1)
            end
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
            plot(tData, smoothdata(realDataByEth(:, first_col_pick+i), 'movmean', smoothDays(nplots)), '-',  'Color', [0 0 0 0.5], 'LineWidth', 1)
        end

        hold off
        xlim(tPlotRange)
        ylim([0 inf])
        ylabel(yaxis_labels(nplots))
        grid on
        grid minor
    end

    if ismember(nplots, [2 3 5])
        leg = legend(legend_labels, 'Interpreter', 'none');
    else
        leg = legend(legend_labels(1:end-1), 'Interpreter', 'none');
    end
    leg.Layout.Tile = 'South';


    % Save figure if it doesn't already exist or if overwrite flag is on
    figLabel = split(plot_titles(nplots), '.mat');
    figLabel = append(figDir, 'modelComparisonByEthnicity_', figLabel{1}, '.png');
    if exist(figLabel, 'file') == 0 || overwriteFig
        saveas(f, figLabel)
    end

end

end