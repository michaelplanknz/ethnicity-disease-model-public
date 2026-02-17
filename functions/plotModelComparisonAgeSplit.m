function plotModelComparisonAgeSplit(t, bandsData, bestFitData, tData, realData, ...
    popByAge, plotToDate, scenario_names, overwriteFig, perCapita, figDir)
% Function that plots a grid of plots (cases, hospital
% admissions, and deaths), which include a best fit
% line, confidence bands, real data, and vertical lines representing an
% intervention date for each 10year age band

% INPUTS:
% - filenameBands: "folder/filename.mat" for bands data
% - filenameBestFit: "folder/filename.mat" for best fit data
% - plotToDate: datetime variable specifying the upper limit for the horizontal (time) axis for the plots
% - dataComb: data for plotting, as output by getAllData.m
% - scenario_names: vector naming the different runs
% - overwriteFig: set to true to overwrite png plots in results

% OUTPUTS:
% - .png figures in results, if they don't already exist or if overwriteFig
%   set to true

% Subset of scenarios to plot in the next graph (make this 1:nScenarios to
% plot all of them)
scenariosToPlot = [1, 4, 5];
colIndex = [1, 2, 3];

% Set to 1 to plot best fit lines:
plotBestFit = 1;

% Use function here

% [t, bandsData, bestFitData, tData, realData] = ...
%     summariseScenarioRuns(filenameBands, filenameBestFit, dataComb);

% Now collapse by age and ethnicity for initial plots on left

bandsDataAll = reshape(sum(sum(bandsData, 4), 3), size(bandsData, [1 2 5 6]));
bestFitDataAll = reshape(sum(sum(bestFitData, 3), 2), size(bestFitData, [1 4 5]));
realDataAll = reshape(sum(realData, 2), size(realData, [1 3])); % collapse over age groups
realDataAll = [realDataAll(:, 1) sum(realDataAll(:, 3:6), 2) ...
    sum(realDataAll(:, 7:10), 2)...
    realDataAll(:, 2) sum(realDataAll(:, 11:14), 2)];

% Now collapse by ethnicity

bandsDataByAge = reshape(sum(bandsData, 4), size(bandsData, [1 2 3 5 6]));
bestFitDataByAge = reshape(sum(bestFitData, 3), size(bestFitData, [1 2 4 5]));
realDataByAge = [sum(realData(:, :, 3:6), 3) ...
    sum(realData(:, :, 7:10), 3) ...
    sum(realData(:, :, 11:14), 3)];

% Rescale to per 100,000 if needed

if perCapita == true

    % totals
    bandsDataAll = 1e5 * bandsDataAll ./ sum(popByAge);
    bestFitDataAll = 1e5 * bestFitDataAll ./ sum(popByAge);
    realDataAll = 1e5 * realDataAll ./ sum(popByAge);

    % age split
    bandsDataByAge = 1e5 * bandsDataByAge ./ reshape(popByAge, 1, 1, 8, 1, 1);
    bestFitDataByAge = 1e5 * bestFitDataByAge ./ reshape(popByAge, 1, 8, 1, 1);
    realDataByAge = 1e5 * realDataByAge ./ repmat(popByAge', 1, 3);

    % make cumlative infections results per capita instead of per 100K:
    bestFitDataAll(:, 6:7, :) = 1e-5 * bestFitDataAll(:, 6:7, :);
    bestFitDataByAge(:, :, 6:7, :) = 1e-5 * bestFitDataByAge(:, :, 6:7, :);

else

    % Rescale for cumulative per capita exposure
    bestFitDataAll(:, 6:7, :) = bestFitDataAll(:, 6:7, :) / sum(popByAge);
    bestFitDataByAge(:, :, 6:7, :) = bestFitDataByAge(:, :, 6:7, :) ./ ...
        reshape(popByAge, 1, 8, 1, 1);

end



% ------------------------------ PLOTS ------------------------------------

plotTitle = 'Comparing all scenarios';

age_groups = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70+'};
title_pick = 'Age-stratified results';
    
if perCapita
    subplotYaxis = {'infections per 100K', 'cases per 100K', 'adms per 100K', ...
    'deaths per 100K', 'infections per capita'};
else
    subplotYaxis = {'daily infections', 'daily cases', 'daily admissions', ...
    'daily deaths', 'infections per capita'};
end
smoothDays = [nan, 7, 14, 21, nan];
tPlotRange = [datetime(2022, 1, 1), plotToDate+1];
layer_pick = [1 2 3 5 6]; % choosing correct metrics (not occupancy)


tmp = colororder;
line_colours = tmp(colIndex, :);

f = figure;
set(f, 'WindowStyle', 'normal');
f.Position = [15 80 1810 860];
tiledlayout(4, 8, 'TileSpacing', 'compact', 'Padding', 'tight');
sgtitle(title_pick);


% Initialize a cell array to store handles
legend_handles = cell(1, numel(scenario_names)+1);

for i = 2:numel(subplotYaxis)       % Start at i=2 to omit daily infection incidence plots
    for ag = 1:size(age_groups, 2)  % Start at ag=1 (rather than ag=0) to omit all ages plots
        nexttile
        hold on
        if ag == 0      % Plot all ages plot
            title('all ages')
            for j = 1:length(scenariosToPlot)
                kScenario = scenariosToPlot(j);
                if i < numel(subplotYaxis) % no bands for cumulative infections per capita
                    plot(t, min(bandsDataAll(:, :, layer_pick(i), kScenario),[], 2), 'Color', line_colours(j, :), 'LineWidth', 1, 'LineStyle', ':', 'HandleVisibility', 'off')
                    plot(t, max(bandsDataAll(:, :, layer_pick(i), kScenario),[], 2), 'Color', line_colours(j, :), 'LineWidth', 1, 'LineStyle', ':', 'HandleVisibility', 'off')
                end
                if plotBestFit == 1
                    h(j) = plot(t, bestFitDataAll(:, layer_pick(i), kScenario), 'Color', line_colours(j, :), 'LineWidth', 2);
                    % On the final row of plots (cumulative infectoins),
                    % also plot the 7th 'layer' (which is total first infections
                    % plus reinfections) as dashed lines:
                    if i == numel(subplotYaxis)
                        plot(t, bestFitDataAll(:, layer_pick(i)+1, kScenario), 'Color', line_colours(j, :), 'LineWidth', 2, 'LineStyle', '--');
                    end
                end
                h(j).DisplayName = scenario_names(kScenario);
            end

            % Plot data
            if i < numel(subplotYaxis)
                h(j+1) = plot(tData, smoothdata(realDataAll(:, layer_pick(i)), 'movmean', 7), 'Color', [0 0 0], 'LineWidth', 1);
                h(j+1).DisplayName = 'Data';
            end
        else
            title(age_groups(ag))
            for j = 1:length(scenariosToPlot)
                kScenario = scenariosToPlot(j);
                if i < numel(subplotYaxis) % no bands for cumulative infections per capita
                    plot(t, min(bandsDataByAge(:, :, ag, layer_pick(i), kScenario), [], 2), 'Color', line_colours(j, :), 'LineWidth', 1, 'LineStyle', ':', 'HandleVisibility', 'off');
                    plot(t, max(bandsDataByAge(:, :, ag, layer_pick(i), kScenario), [], 2), 'Color', line_colours(j, :), 'LineWidth', 1, 'LineStyle', ':', 'HandleVisibility', 'off');
                end
                if plotBestFit == 1
                    h(j) = plot(t, bestFitDataByAge(:, ag, layer_pick(i), kScenario), 'Color', line_colours(j, :), 'LineWidth', 2);
                    if i == numel(subplotYaxis)
                        plot(t, bestFitDataByAge(:, ag, layer_pick(i)+1, kScenario), 'Color', line_colours(j, :), 'LineWidth', 2, 'LineStyle', '--');
                    end
                end
                h(j).DisplayName = scenario_names(kScenario);
            end
            if ismember(i, [2 3 4])
                if i == 2
                    start_col = 0;
                elseif i == 3
                    start_col = 8;
                else
                    start_col = 16;
                end
                h(j+1) = plot(tData, smoothdata(realDataByAge(:, start_col + ag), 'movmean', smoothDays(i)), 'Color', [0 0 0], 'LineWidth', 1);
                h(j+1).DisplayName = 'Data';
            end

            % Store handles from the first subplot
            if i == 2 && ag == 1
                for mm = 1:numel(scenariosToPlot)+1
                    legend_handles{mm} = h(mm);
                end
            end
        end
        xlim(tPlotRange)
        hold off
        ylabel(subplotYaxis(i))
        grid on
    end
end


leg = legend([legend_handles{:}]);
leg.Layout.Tile = 'South';

% Save figure if it doesn't already exist or if overwrite flag is on
figLabel = split(plotTitle, '.mat');
figLabel = append(figDir, figLabel{1}, '_modelComparisonAgeSplit.png');
if exist(figLabel, 'file') == 0 || overwriteFig
    pause(0.1)
    saveas(f, figLabel)
end

