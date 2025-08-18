function [doses1, doses2, doses3, doses4plus, nDoses1Smoothed0, nDoses2Smoothed0, nDoses3Smoothed0, nDoses4Smoothed0] = assignVaxRates(myDataPath, dataFileNames, useEthVaxData, par)

% Returns cumulatiive doses and smoothed doses per day by dose number, age and ethnicity

% Window for smoothing cumulative data before diffing
smoothWindow = 56;


if par.nEthnicities == 1
    [~, doses1, doses2, doses3, doses4plus] = ...
        getVaccineData(myDataPath, dataFileNames.vaxDataFname, par.vaccImmDelay, par.date0, par.tEnd);
elseif par.nEthnicities == 4 && useEthVaxData == false
    % Read in the national data
    [~, doses1_all, doses2_all, doses3_all, doses4plus_all] = ...
        getVaccineData(myDataPath, dataFileNames.vaxDataFname, par.vaccImmDelay, par.date0, par.tEnd);
    propByAge = par.popCountMatrix./sum(par.popCountMatrix, 2); % proportions in each ethnicity by age group
    doses1 = zeros(size(doses1_all, 1), par.nAgeGroups*par.nEthnicities); % empty matrix
    doses2 = doses1;
    doses3 = doses1;
    doses4plus = doses1;
    % Distribute total national doses across ethnicities in proportion to
    % population:
    for j = 1:par.nEthnicities
        doses1(:, par.nAgeGroups*(j-1)+(1:par.nAgeGroups)) = round(doses1_all.*propByAge(:, j)');
        doses2(:, par.nAgeGroups*(j-1)+(1:par.nAgeGroups)) = round(doses2_all.*propByAge(:, j)');
        doses3(:, par.nAgeGroups*(j-1)+(1:par.nAgeGroups)) = round(doses3_all.*propByAge(:, j)');
        doses4plus(:, par.nAgeGroups*(j-1)+(1:par.nAgeGroups)) = round(doses4plus_all.*propByAge(:, j)');
    end
elseif par.nEthnicities == 4 && useEthVaxData == true
    [~, doses1European, doses2European, doses3European, doses4plusEuropean] = ...
        getVaccineData(myDataPath, dataFileNames.vaxDataEuropeanFname, par.vaccImmDelay, par.date0, par.tEnd);
    [~, doses1Maori, doses2Maori, doses3Maori, doses4plusMaori] = ...
        getVaccineData(myDataPath, dataFileNames.vaxDataMaoriFname,par.vaccImmDelay, par.date0, par.tEnd);
    [~, doses1Pacific, doses2Pacific, doses3Pacific, doses4plusPacific] = ...
        getVaccineData(myDataPath, dataFileNames.vaxDataPacificFname, par.vaccImmDelay, par.date0, par.tEnd);
    [~, doses1Asian, doses2Asian, doses3Asian, doses4plusAsian] = ...
        getVaccineData(myDataPath, dataFileNames.vaxDataAsianFname, par.vaccImmDelay, par.date0, par.tEnd);

    % Adjust the number of doses in each age group so that the total doses across the 4 ethnicity groups equals the number of doses in the national data
    % Sum doses across the 4 groups at the final time point
    doses1_agg_final = doses1European(end, :) + doses1Maori(end, :) + doses1Pacific(end, :) + doses1Asian(end, :);
    doses2_agg_final = doses2European(end, :) + doses2Maori(end, :) + doses2Pacific(end, :) + doses2Asian(end, :);
    doses3_agg_final = doses3European(end, :) + doses3Maori(end, :) + doses3Pacific(end, :) + doses3Asian(end, :);
    doses4plus_agg_final = doses4plusEuropean(end, :) + doses4plusMaori(end, :) + doses4plusPacific(end, :) + doses4plusAsian(end, :);

    % Read in the national data
    [~, doses1_all, doses2_all, doses3_all, doses4plus_all] = ...
        getVaccineData(myDataPath, dataFileNames.vaxDataFname, par.vaccImmDelay, par.date0, par.tEnd);
    
    % Calculate multipliers for each dose number and each age group
    mult1 = doses1_all(end, :)./doses1_agg_final;
    mult2 = doses2_all(end, :)./doses2_agg_final;
    mult3 = doses3_all(end, :)./doses3_agg_final;
    mult4plus = doses4plus_all(end, :)./doses4plus_agg_final;

    % Set any NaN or Inf multipliers (due to a zero denominator) to 1
    mult1(~isfinite(mult1)) = 1;
    mult2(~isfinite(mult2)) = 1;
    mult3(~isfinite(mult3)) = 1;
    mult4plus(~isfinite(mult4plus)) = 1;
    

    % For each dose number, concatenate the four nt x 16 arrays to give a
    % nt x 64 array
    doses1 = [doses1European, doses1Maori, doses1Pacific, doses1Asian];
    doses2 = [doses2European, doses2Maori, doses2Pacific, doses2Asian];
    doses3 = [doses3European, doses3Maori, doses3Pacific, doses3Asian];
    doses4plus = [doses4plusEuropean, doses4plusMaori, doses4plusPacific, doses4plusAsian];

    % Apply multipliers to the ethnicity specific data
    doses1 = repmat(mult1, 1, 4).*doses1;
    doses2 = repmat(mult2, 1, 4).*doses2;
    doses3 = repmat(mult3, 1, 4).*doses3;
    doses4plus = repmat(mult4plus, 1, 4).*doses4plus;
else
    error('par.nEthnicities must be either 1 or 4, and useEthVaxData must be either 0 or 1')
end

nDoses1Smoothed0 = [zeros(1, par.nAgeGroups*par.nEthnicities); diff(smoothdata(doses1, 'movmean', smoothWindow));];
nDoses2Smoothed0 = [zeros(1, par.nAgeGroups*par.nEthnicities); diff(smoothdata(doses2, 'movmean', smoothWindow))];
nDoses3Smoothed0 = [zeros(1, par.nAgeGroups*par.nEthnicities); diff(smoothdata(doses3, 'movmean', smoothWindow))];
nDoses4Smoothed0 = [zeros(1, par.nAgeGroups*par.nEthnicities); diff(smoothdata(doses4plus, 'movmean', smoothWindow))];

