function bandsData = plotModelComparisonAgeSplitByEthnicity(t, bandsData, ...
    bestFitData, tData, realData, popCountMatrix10, popByEth, plotToDate, ...
    scenario_names, ethnicity_names, overwriteFig, perCapita, figDir)
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
% - perCapita: set to true to plot rates per 100k, or false to plot
% absolute numbers

% OUTPUTS:
% - .png figures in results, if they don't already exist or if overwriteFig
%   set to true

% Set to 1 to plot best fit lines:
plotBestFit = 1;


% Collapse by age
bandsDataByEth = reshape(sum(bandsData, 3), size(bandsData, [1 2 4 5 6]));
bestFitDataByEth = reshape(sum(bestFitData, 2), size(bestFitData, [1 3 4 5]));

% remove infections and occupancy in real data
realData = realData(:, :, 3:14);

% collapse over age groups
realDataByEth = reshape(sum(realData, 2), size(realData, [1 3])); 


% Rescale to per 100,000 if needed
if perCapita == true

    % Totals by ethnicity
    bandsDataByEth = 1e5 * bandsDataByEth ./ reshape(popByEth, 1, 1, numel(popByEth), 1, 1);
    bestFitDataByEth = 1e5 * bestFitDataByEth ./ reshape(popByEth, 1, numel(popByEth), 1, 1);
    realDataByEth = 1e5 * realDataByEth ./ repmat(popByEth, 1, 3);

    % By age and ethnicity
    bandsData = 1e5 * bandsData ./ ...
        reshape(popCountMatrix10, 1, 1, size(popCountMatrix10, 1), ...
        size(popCountMatrix10, 2), 1, 1);
    bestFitData = 1e5 * bestFitData ./ ...
        reshape(popCountMatrix10, 1, size(popCountMatrix10, 1), ...
        size(popCountMatrix10, 2), 1, 1);
    realData = 1e5 * realData ./ ...
        reshape(repmat(popCountMatrix10, 1, 3), 1, size(popCountMatrix10, 1), ...
        3*size(popCountMatrix10, 2));


    % make cumlative infections results per capita instead of per 100K:
    bestFitDataByEth(:, :, 6:7, :) = 1e-5 * bestFitDataByEth(:, :, 6:7, :);
    bestFitData(:, :, :, 6:7, :) = 1e-5 *  bestFitData(:, :, :, 6:7, :);
else

    % Rescale for cumulative per capita exposure

    bestFitDataByEth(:, :, 6:7, :) = bestFitDataByEth(:, :, 6:7, :) ./ ...
        reshape(popByEth, 1, numel(popByEth), 1, 1);
    bestFitData(:, :, :, 6:7, :) = bestFitData(:, :, :, 6:7, :) ./ ...
        reshape(popCountMatrix10, 1, size(popCountMatrix10, 1), size(popCountMatrix10, 2), 1, 1);

end



% ------------------------------ PLOTS ------------------------------------

smoothDaysAgg = [nan, 7, 14, 21, nan];
smoothDaysAge = [nan, 7, 14, 21, nan];

tPlotRange = [datetime(2022, 1, 1), plotToDate+1];
layer_pick = [1 2 3 5 6]; % choosing correct metrics (not occupancy)

line_colours = hsv(numel(scenario_names)+1); % use colormap
line_colours(1, :) = []; % Remove the first row
shade_colours = line_colours;

age_groups = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70+'};

if perCapita == true
    plot_titles = {'New daily infections per 100,000', 'New daily cases per 100,000', ...
        'New daily admissions per 100,000', 'Daily deaths per 100,000', ...
        'Cumulative infections per capita'};
    yaxis_labels = {'infections per 100K', 'cases per 100K', ...
        'admissions per 100K', 'deaths per 100K', ...
        'infections per capita'};
else
    plot_titles = {'New daily infections', 'New daily cases', 'New daily admissions', ...
    'Daily deaths', 'Cumulative infections per capita'};
    yaxis_labels = {'infections', 'cases', 'admissions', ...
    'deaths', 'infections per capita'};
end

% Initialize a cell array to store handles
legend_handles = cell(1, numel(scenario_names)+1);

for nplots = 1:numel(plot_titles)

    f = figure;
    set(f, 'WindowStyle', 'normal');
    f.Position = [20 170-30*(nplots-1) 1880 800];
    tiledlayout(numel(ethnicity_names), 9);
    sgtitle(plot_titles(nplots));

    for j = 1:numel(ethnicity_names)
        for ag = 0:size(age_groups, 2)
            nexttile
            hold on
            if ag == 0
                title(sprintf('all ages (%s)', ethnicity_names{j}))
                for k = 1:numel(scenario_names)
                    if nplots < numel(plot_titles) % no bands for cumulative infections per capita
                        fill([t, fliplr(t)], [min(bandsDataByEth(:, :, j, layer_pick(nplots), k), [], 2); ...
                            flipud(max(bandsDataByEth(:, :, j, layer_pick(nplots), k), [], 2))], ...
                            '', 'FaceColor', shade_colours(k, :), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                    end
                    if plotBestFit == 1
                        h(k) = plot(t, bestFitDataByEth(:, j, layer_pick(nplots), k), 'Color', line_colours(k, :));
                        if nplots == numel(plot_titles)
                            plot(t, bestFitDataByEth(:, j, layer_pick(nplots)+1, k), '--', 'Color', line_colours(k, :));
                        end
                    end
                    h(k).DisplayName = scenario_names(k);
                end

                % plotting real data

                h(k+1) = plot(nan, nan, '-',  'Color', [0 0 0 0.2]); % dummy for legend label
                h(k+1).DisplayName = 'Data';

                if ismember(nplots, [2 3 4])
                    if nplots == 2 % cases
                        first_col_pick = 0;
                    elseif nplots == 3 % hosp
                        first_col_pick = 4;
                    elseif nplots == 4 % deaths
                        first_col_pick = 8;
                    end
                    plot(tData, smoothdata(realDataByEth(:, first_col_pick+j), 'movmean', smoothDaysAgg(nplots)), '-',  'Color', [0 0 0 0.2]);
                end


                % Store handles from the first subplot
                if j == 1 && ag == 0
                    for mm = 1:numel(scenario_names)+1
                        legend_handles{mm} = h(mm);
                    end
                end


            else
                title(sprintf('%s (%s)', age_groups{ag}, ethnicity_names{j}))
                for k = 1:numel(scenario_names)
                    if nplots < numel(plot_titles) % no bands for cumulative infections per capita
                        fill([t, fliplr(t)], [min(bandsData(:, :, ag, j, layer_pick(nplots), k), [], 2); ...
                            flipud(max(bandsData(:, :, ag, j, layer_pick(nplots), k), [], 2))], ...
                            '', 'FaceColor', shade_colours(k, :), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                    end
                    if plotBestFit == 1
                        plot(t, bestFitData(:, ag, j, layer_pick(nplots), k), 'Color', line_colours(k, :));
                        if nplots == numel(plot_titles)
                            plot(t, bestFitData(:, ag, j, layer_pick(nplots)+1, k), '--', 'Color', line_colours(k, :));
                        end
                    end


                    % plotting real data

                    if ismember(nplots, [2 3 4])
                        if nplots == 2 % cases
                            first_col_pick = 0;
                        elseif nplots == 3 % hosp
                            first_col_pick = 4;
                        elseif nplots == 4 % deaths
                            first_col_pick = 8;
                        end
                        plot(tData, smoothdata(realData(:, ag, first_col_pick+j), 'movmean', smoothDaysAge(nplots)), '-',  'Color', [0 0 0 0.2])
                    end

                end

            end
            hold off
            xlim(tPlotRange)
            ylabel(yaxis_labels{nplots})
            grid on
            grid minor

        end

    end

    if ismember(nplots, [2 3 4])
        leg = legend([legend_handles{:}]);
    else
        leg = legend([legend_handles{1:end-1}]); % remove data label
    end
    leg.Layout.Tile = 'South';


    % Save figure if it doesn't already exist or if overwrite flag is on
    figLabel = append(figDir, 'modelComparisonAgeSplitByEthnicity_', plot_titles{nplots}, '.png');
    if exist(figLabel, 'file') == 0 || overwriteFig
        pause(0.1)
        saveas(f, figLabel)
    end


end


end