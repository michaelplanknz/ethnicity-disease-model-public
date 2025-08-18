function par = getBasePar(tMax, myDataPath, dataFileNames, ...
    nEthnicities, useEthVaxData, assort, totalContFreq, OR_hosp, OR_death, Rt_mult)
% Function to create structure of base parameters that stay fixed for all
% simulations
% INPUT:
% - tMax: datenum variable corresponding to last datapoint
% - myDataPath: path to folder containing data
% - dataFileNames: structure with fields containing the filenames of the data files to be read in
% - useEthVaxData: flag that equals 1 to use ethnicity-specific data on
% number vaccine doses, or 0 to use national data and distribute doses
% by ethnicity in proportion to pop size (in each age group)
% - assort: assortativity constant for mixing between ethnicities
% - totalContFreq: vector of total contact frequency weightings for each
% ethnicity
% - OR_hosp: vector of ethnicity-specific odds ratios for hospitalisation
% - OR_death: vector of ethnicity-specific odds ratios for death
% - Rt_mult: multiplier on R0 (set to 1 to use default baseline value for
% R0)
% OUTPUT:
% - par: structure of parameters


% Simulation start date (start date set to 5Mar21 to include full
% vaccine rollout period and simulate correct waning dynamics)
par.date0 = datenum('05MAR2021');

% Simulation end date, if no tMax specified run for 3 years
if isnan(tMax); par.tEnd = 3 * 360; else; par.tEnd = tMax - par.date0; end

% Create time vector
par.tBase = par.date0:par.date0+par.tEnd;

%------------- SEIR parameters --------------
par.R0 = 3.25*Rt_mult;   
par.cSub = 0.5; % Relative infectiousness of subclinicals
par.tE = 1;     % Latent period
par.tI = 2.3;   % Infectious period


%------------- Specify Population Structure -------------
par.nAgeGroups = 16;
par.nEthnicities = nEthnicities; % number of ethnicities

% Number of susceptibility compartments, number of vaccination compartments
% (i.e. number of doses) and number of compartments in the progression series for
% cases, hospitalisations and deaths
par.nSusComp = 14;
par.nVaxComp = 3;
par.nCaseComp = 3;
par.nHospComp = 5;
par.nDeathComp = 6;



% Read in pop data as a matrix with one column for each ethnicity
[par.popCountMatrix, par.ethnicityLabels] = getPopData(myDataPath + dataFileNames.popSizeFname, par.nAgeGroups, par.nEthnicities); 

% Create a single column vector of 64 = 16x4 group sizes
par.popCountVector = par.popCountMatrix(:);


%--------------------- Seed Parameters --------------------
% Time window when community seed cases appear
par.seedDur = 7;
% Number of daily seed cases appearing in the community seeding window for
% each age group
par.initialExp = 0.0001 * par.popCountVector;

% Date when border cases start getting seeded, approximately corresponding
% to the initial relaxation of border policies in 2022
par.borderTime = datenum("01-Mar-2022");
% Number of daily border seed cases appearing from borderTime. This is an
% approximation from the number of border arrivals in previous years
par.borderSeeds = 300;


%------------- Load Contact Matrix and Define NGM --------------
% Get Prem et al contact matrix from data folder
C = readmatrix(myDataPath + dataFileNames.CMdataFname);
par.C_detBal = calcContactMatrix(C, par.popCountMatrix, assort, totalContFreq); 



% ------------------ Population dynamics parameters ---------------------
% Demographic parameters birth, death, ageing - set all of these to zero to
% just have a static population
[Mu, b] = getDemogPars();
par.popnDeathRate = repmat(Mu, par.nEthnicities, 1); % clone for each ethnicity for now
if par.nEthnicities == 1 % if only one ethnicity
    par.popnBirthRate = b;
else
    propByEthnicity = sum(par.popCountMatrix, 1)/sum(par.popCountVector);
    par.popnBirthRate = repelem(b, par.nEthnicities) .* propByEthnicity;
end
par.popnAgeingRate = 1/(5*365.25);




%------------- Disease Rate Data --------------

% Probability of developing symptoms (Fraser group) - clone for ethnicities for now
par.pClin = repmat([0.5440, 0.5550, 0.5770, 0.5985, 0.6195, 0.6395, 0.6585, ...
    0.6770, 0.6950, 0.7117, 0.7272, 0.7418, 0.7552, 0.7680, 0.7800, 0.8008]', par.nEthnicities, 1);

% Davies relative susceptibility - clone for ethnicities for now
par.ui = repmat([0.4000, 0.3950, 0.3850, 0.4825, 0.6875, 0.8075, 0.8425, ...
    0.8450, 0.8150, 0.8050, 0.8150, 0.8350, 0.8650, 0.8450, 0.7750, 0.7400]', par.nEthnicities, 1);

% Overall (all ethnicities pooled) IHR and IFR parameters (for the fully
% susceptible class)
% NB These are from Datta et al. 2024 and were originally derived from the Herrera et
% al estimates with various adjustments made for the Omicorn variant and
% for observed patterns in hopsitalisations and deaths in New Zealand
IHR_all = 1/1000 * [7.1221    1.1494    1.1932    2.4162    3.4768    3.5425    3.6879    3.9855    4.3582    5.4936    6.6751    9.1792   13.4803   21.4427   36.3052  130.0303]';
IFR_all = 1/1000 * [0.0211    0.0034    0.0034    0.0062    0.0122    0.0240    0.0480    0.0912    0.1800    0.3602    0.6967    1.3466    2.6502    5.0775    9.7375   54.6655]';
IFR_all(1:end-1) = IFR_all(1:end-1) * 0.6;
IFR_all(end) = IFR_all(end) * 1.35;




% Calculate group-specific IHR and IFR using specified odds ratios
IHR0 = applyEthnicityORs(IHR_all, par.popCountMatrix, OR_hosp);
IFR0 = applyEthnicityORs(IFR_all, par.popCountMatrix, OR_death);

% Reshape IHR0 and IFR0 to column vectors
par.IHR0 = IHR0(:);
par.IFR0 = IFR0(:);


% --------------------- Testing and lag parameters -----------------------
par.tLatentToTest = 4;              % Days from onset of infectiousness to test
par.tTestToHosp = 1;                % days from test to hospital admission
par.tLOS = repmat([2.0000 2.0000  2.0000  2.0000  2.0000  2.0000  2.6700 ...
    3.3400 4.0100 4.6800 5.3500 6.0200 6.6900 7.3600 8.0300 8.7000]', par.nEthnicities, 1); % clone for ethnicities
par.tDeath = 14;                    % Days from admission to death


% New way of determining CAR: setting fixed starting and ending CAR, linear
% % interpolation between the two, for 3 new age groups (0-30, 30-60, 60+)
par.pTest1_030 = 0.5;
par.pTest1_3060 = 0.60;
par.pTest1_60p = 0.75;
par.pTest2_030 = 0.25;
par.pTest2_3060 = 0.4;
par.pTest2_60p = 0.75;

% Dates between which the CAR decreases
CARchangeDates = datenum(["01MAY2022", "01JAN2023"]) - par.tBase(1);
CARchangeDays = CARchangeDates(2) - CARchangeDates(1) + 1;

par.pTestClin0 = ones(par.nAgeGroups*par.nEthnicities, length(par.tBase));

for j = 1:par.nEthnicities % clone for ethnicities for now

    % Before first date
    par.pTestClin0((j-1)*par.nAgeGroups + (1:6), :) = par.pTest1_030;
    par.pTestClin0((j-1)*par.nAgeGroups + (7:12), :) = par.pTest1_3060;
    par.pTestClin0((j-1)*par.nAgeGroups + (13:16), :) = par.pTest1_60p;

    % Linear decrease between dates
    par.pTestClin0((j-1)*par.nAgeGroups + (1:6), CARchangeDates(1):CARchangeDates(2)) = repmat(linspace(par.pTest1_030, par.pTest2_030, CARchangeDays), 6, 1);
    par.pTestClin0((j-1)*par.nAgeGroups + (7:12), CARchangeDates(1):CARchangeDates(2)) = repmat(linspace(par.pTest1_3060, par.pTest2_3060, CARchangeDays), 6, 1);
    par.pTestClin0((j-1)*par.nAgeGroups + (13:16), CARchangeDates(1):CARchangeDates(2)) = repmat(linspace(par.pTest1_60p, par.pTest2_60p, CARchangeDays), 4, 1);

    % After second date
    par.pTestClin0((j-1)*par.nAgeGroups + (1:6), CARchangeDates(2):end) = par.pTest2_030;
    par.pTestClin0((j-1)*par.nAgeGroups + (7:12), CARchangeDates(2):end) = par.pTest2_3060;
    par.pTestClin0((j-1)*par.nAgeGroups + (13:16), CARchangeDates(2):end) = par.pTest2_60p;

end

% Scaling factor for testing probability of subclinical cases
par.subClinPtestMult = 0.4;

%-------------------------- Get vaccine data ----------------------------
% For multiple ethnicities, just use same projection file to get things off
% the ground - this must be incorrect (numbers are for total population)
par.vaccImmDelay = 14;  % delay in nb of days from vaccination to immunity

[par.doses1, par.doses2, par.doses3, par.doses4plus, par.nDoses1Smoothed0, par.nDoses2Smoothed0, par.nDoses3Smoothed0, par.nDoses4Smoothed0] = assignVaxRates(myDataPath, dataFileNames, useEthVaxData, par);





%---------------- Get antivirals data -------------------
therap_data = load(myDataPath + dataFileNames.AVdataFname);
movmean_period = 8 * 7; % Moving mean over 8 weeks
tailDays_toCut = 1 * 7; % Remove last 1 weeks of data to remove lagged entries
th_dates = therap_data.outTab.date(1:end-tailDays_toCut);

% Get number of daily treated, sum over the 75+, then smooth
daily_treated = therap_data.outTab.nTreated(1:end-tailDays_toCut, 1:15);
daily_treated(:, 16) = sum(therap_data.outTab.nTreated(1:end-tailDays_toCut, 16:end), 2);
daily_treated = movmean(daily_treated, movmean_period, 1);

% Get number of daily cases, sum over the 75+, then smooth
daily_cases = therap_data.outTab.nCases(1:end-tailDays_toCut, 1:15);
daily_cases(:, 16) = sum(therap_data.outTab.nCases(1:end-tailDays_toCut, 16:end), 2);
daily_cases = movmean(daily_cases, movmean_period, 1);

% Get ratio of smoothed daily treated and smoothed daily cases and clone
% for each ethnicity
daily_treatcaseratio = repmat(daily_treated ./ daily_cases, 1, par.nEthnicities);

% Add flat head and tail
daily_treatcaseratio = [zeros(datenum(th_dates(1))-par.date0, par.nAgeGroups*par.nEthnicities);
    daily_treatcaseratio;
    repmat(daily_treatcaseratio(end, :), (par.date0+par.tEnd) - datenum(th_dates(end)), 1)];


dt_num = par.tBase';
dt = datetime(dt_num, 'ConvertFrom', 'datenum');
par.antiviralData = table(dt_num, dt, daily_treatcaseratio);

%------------------------- Immunity parameters --------------------------
par.waneRateMean = 0.0045;          % Assumed mean daily waning rate
par.relRate_RtoS = 1.85;            % Relative rate of moving from R to S


% Run Khoury/Golding submodel to generate immunity parameters
kLog = 2.94/log(10);               % steepness of logistic relationship betweem log titre and VE -  2.94/log(10) -  Khoury Table S5
no50_sympt = log(0.2);         %  determines mapping from titre to VE symptoms - log(0.2)  match to NG
no50_sev = log(0.03);            % determines mapping from titre to VE severe - log(0.04)  for match with NG results   - Khoury Table S5 is a bit more optimistic: no50_sev = log(0.03);           % Khoury offset (Table S5)
logTitreRatio = log(10);               % ratio of titre from one compartment to next (don't change this without also changing wanin rate and calibrating to Golding reulsts)

logTitre0_2 = log(0.2);                 % 0.2  strength of immunity (measured as initial titre) after 2 doses
logTitre0_3 = log(0.4);                 % 0.4  strength of immunity (measured as initial titre) after 3 doses
logTitre0_inf = log(0.8)+log(5);               % 0.8    strength of immunity (measured as initial titre) after 0/1 doses + infection
logTitre0_inf_plus2 = log(3)+log(5);           % 3       strength of immunity (measured as initial titre) after 2 doses + infection
logTitre0_inf_plus3 = log(7)+log(5);          % 7      strength of immunity (measured as initial titre) after 3 doses + infection

% Immunity to hospitalisation and death (from vaccine or prior infection)
% cannot wane below this
minVEsev = 0.5;

% set titre levels for each susceptible compartment
logTitreSequence = logTitreRatio*[0, -1, -2, -3];
logTitreLevels = [-inf -inf    logTitre0_2 + logTitreSequence   logTitre0_3 + logTitreSequence     logTitre0_inf_plus3 + logTitreSequence];

% convert titre levels to immunity agaist each outcome
par.VEi = 1./(1+ exp(-kLog*(logTitreLevels-no50_sympt))); % get Khoury VE
par.VEh = 1./(1+ exp(-kLog*(logTitreLevels-no50_sev))); % get Khoury VE
par.VEt = zeros(1, par.nSusComp);
par.VEs = par.VEi;
par.VEf = par.VEh;

% apply minimum immunity constraint to severe outcomes
par.VEh(3:end) = max(minVEsev, par.VEh(3:end));
par.VEf(3:end) = max(minVEsev, par.VEf(3:end));

% Calculate the proporton of post-infection indiciduala with 0/1 or 2 doses
% who go to each of the 4 post-infection susceptible compartments
% this is done by solving an ODE to calculate the proportion of a
% post-infection cohort who are in each compartment at time t such that
% their average titre has dropped by the specified amount
logTitreDrop =  [logTitre0_inf, logTitre0_inf_plus2] - logTitre0_inf_plus3;
Y0 = getImmPars(logTitreRatio, logTitreDrop);
Y0 = Y0./sum(Y0, 2);

% Proportion going into W1, W2, W3, W4 post recovery
postRecovDist_Unvaxed = Y0(1, :);
postRecovDist_Vaxed2 = Y0(2, :);
postRecovDist_Vaxed3 = [1 0 0 0];

[par.waneNet_StoS, par.waneNet_RtoS, par.vaxNet] = ...
    getATCmatrices(postRecovDist_Unvaxed, postRecovDist_Vaxed2, postRecovDist_Vaxed3);


% --------------- Contact matrix adjustment parameters ------------------
% divide the contact matrix up into blocks - this vector specifies the
% number of 5-year age classes in each "block"
par.ageBlockSizes = [3 2 2 3 2 4];
par.nAgeBlocks = length(par.ageBlockSizes);

% weighting matrix for initial contact matrix
par.Cw1 = [1.1 0.7  0.55 0.45 0.45 0.5;
          0    1.2  0.7  0.5  0.5  0.3;
          0    0    1.1  0.5  0.5  0.5;
          0    0    0    0.15 0.15 0.45;
          0    0    0    0    0.15 0.45;
          0    0    0    0    0    0.15];

% ------------------------ VOC model ----------------------------------
% Date of arrival of the new variant
par.vocWaneDate = datenum('20-Jun-2022');
% Time window over which new variant becomes predominant
par.vocWaneWindow = 2;

% ------------------------ VOC VE model ----------------------------------
% To model reduced VE for VOC set VOC_titreDrop < 1
par.VOC_logTitreDrop = log(0.4);
logTitre0_2_VOC = par.VOC_logTitreDrop + logTitre0_2;
logTitre0_3_VOC = par.VOC_logTitreDrop + logTitre0_3;
logTitreLevels_VOC = [-inf -inf logTitre0_2_VOC+logTitreSequence ...
    logTitre0_3_VOC+logTitreSequence logTitre0_inf_plus3+logTitreSequence];

% Get Khoury VE
par.VEi_VOC = 1./(1+ exp(-kLog*(logTitreLevels_VOC-no50_sympt)));
par.VEh_VOC = 1./(1+ exp(-kLog*(logTitreLevels_VOC-no50_sev)));

par.VEt_VOC = zeros(1, par.nSusComp);
par.VEs_VOC = par.VEi_VOC;
par.VEf_VOC = par.VEh_VOC;

% apply minimum immunity constraint to severe outcomes
par.VEh_VOC(3:end) = max(minVEsev, par.VEh_VOC(3:end));
par.VEf_VOC(3:end) = max(minVEsev, par.VEf_VOC(3:end));


end
