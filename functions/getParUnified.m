function par = getParUnified(Theta, parBase)
% Function to create structure of parameters that can change in the fitting
% procedures or in scenarios
% INPUTS:
% - Theta: table of parameter values to be fitted, or posterior
% - parBase: structure of fixed parameters, defined in getParBase.m
% OUTPUT:
% - par: structure of parameters


% Functions to add a zero-centred random variable to selected parameters
% according to random deviates [0,1] specified in input parameter Theta
plusMinus = @(z, r)(2*r*z - r);                     % uniform perturbation between +/- r, z is a random deviate [0,1]
plusMinusInt = @(z, r)(floor((2*r+1)*z) - r );      % uniform perturbation on integers between +/- r, z is a random deviate [0,1]


%--------------------- Seed date --------------------
par.dateSeed = datenum('19JAN2022') + plusMinusInt(Theta.dateSeed, 3);


% -------------------- Control function parameters -----------------------

% Starting value of Ct (fitted) - between 0.58-0.78
par.Ct = (0.68 + plusMinus(Theta.Cstart, 0.1)) * ones(1, parBase.tEnd+1);

CtRampStarts = [datenum('10-Mar-2022') + plusMinusInt(Theta.rampStart, 5), ...
    datenum('15-Sep-2022') + plusMinusInt(Theta.ramp2Start, 5), ...
    parBase.date0 + parBase.tEnd];
CtRampDays = [55 + plusMinusInt(Theta.rampDays, 20), ...
    10 + plusMinusInt(Theta.ramp2Days, 9), 0];

% Ct after 1st ramp up (0.89-1.31) 
% and after 2nd ramp up (0.89-1.31 * 1.1-1.3)
CtRamp = [1.1 + plusMinus(Theta.Cramp, 0.21), ...
    (1.1 + plusMinus(Theta.Cramp, 0.21)) * (1.2 + plusMinus(Theta.Cramp2, 0.1)), ...
    (1.1 + plusMinus(Theta.Cramp, 0.21)) * (1.2 + plusMinus(Theta.Cramp2, 0.1))];


% Adding Ct ramp-ups at each date:
for pci = 1:length(CtRampStarts)
    ti = datenum(CtRampStarts(pci)) - parBase.date0;
    par.Ct(ti:ti+CtRampDays(pci)-1) = linspace(par.Ct(ti), CtRamp(pci), CtRampDays(pci));
    par.Ct(ti+CtRampDays(pci):end) = CtRamp(pci);
    par.Ct = par.Ct(1:parBase.tEnd+1); % Making sure size stays the same
end


CtFigure = 0;
if CtFigure == 1
    figure
    plot(datetime(parBase.tBase(302:end), 'ConvertFrom', 'datenum'), par.Ct(302:end), 'LineWidth', 2)
    hold on
    grid on
    grid minor
    xlim(datetime([parBase.tBase(302), parBase.tBase(end)], 'ConvertFrom', 'datenum'))
    ylabel('Control function C(t)')
    drawnow
end


% --------------------- Testing and lag parameters -----------------------
% Overall scaling constant for all testing parameters
par.pTestClin = parBase.pTestClin0 .* (1 + plusMinus(Theta.pTestMult, 0.2));

% Subclinical cases have a lower testing probability
par.pTestSub = parBase.subClinPtestMult .* par.pTestClin;                           

% Average over clinical and subclinical (within each age/ethnicity group)
par.pTestTS = (par.pTestClin .* parBase.pClin + par.pTestSub .* (1 - parBase.pClin));



% ------------- Disease Rate Multipliers --------------
% Overall scaling constants for IHR and IFR
par.IHRmult = 1 + plusMinus(Theta.IHR, 0.5);  
par.IFRmult = 1 + plusMinus(Theta.IFR, 0.5);      

par.IHR = par.IHRmult * parBase.IHR0;
par.IFR = par.IFRmult * parBase.IFR0;


% ---------------- Effect of antivirals -------------------
% Multiplier for the effect of antivirals on par.IHR and par.IFR.
% 0 - no effect; 1 - full protection from outcome
par.antiviralsEffectIHRmult = 0; 
par.antiviralsEffectIFRmult = 0.5 + plusMinus(Theta.aViralEffect, 0.1); 


% --------------- Contact matrix adjustment ------------------
% Amount by which contract matrix relaxes back to Prem (0=not at all, 1=fully)
par.relaxAlpha = 0.4 + plusMinus(Theta.relaxAlpha, 0.4);             

Cw2 = (1-par.relaxAlpha) * parBase.Cw1 + ...
    par.relaxAlpha * triu(ones(parBase.nAgeBlocks));
Cw1 = parBase.Cw1 + triu(parBase.Cw1, 1)';                % make weights into symmetric matrices
Cw2 = Cw2 + triu(Cw2, 1)';
par.contactPar.weights = repelem(Cw1, parBase.ageBlockSizes, parBase.ageBlockSizes);        % expand blocks to create a 16x16 matrix that can multiplied elementwise with the contact matrix
par.contactPar.weightsChange = repelem(Cw2, parBase.ageBlockSizes, parBase.ageBlockSizes);

% Expand these to all ethnicities
par.contactPar.weights = repmat(par.contactPar.weights, parBase.nEthnicities, parBase.nEthnicities);
par.contactPar.weightsChange = repmat(par.contactPar.weightsChange, parBase.nEthnicities, parBase.nEthnicities);

% Start date and time window for change of contact matrix - matrix will
% change linearly during the specified number of days followiong the start
% date
par.contactPar.changeDate = CtRampStarts(1);
par.contactPar.changeWindow = 70 + plusMinusInt(Theta.MRampDays, 20);



%---------------------------  VOC model ---------------------------------
% Coefficient determining what fraction of each post-infection susceptible
% compartment gets bumped down the immunity scale
par.vocWaneAmount = 0.4 + plusMinus(Theta.vocWane, 0.3) ;

par.VOC2active = true;
par.vocWaneAmount2 = 0.25;
par.vocWaneDate2 = datenum('15-Nov-2022');




%------------------------- Immunity parameters --------------------------
par.waneRateMult = 1 + plusMinus(Theta.waneRate, 0.5);    % Fitted multiplier on waning rate
par.waneRate_StoS = parBase.waneRateMean * par.waneRateMult;  % Rate of moving from one S compartment to the next one with lower immunity
par.waneRate_RtoS = parBase.waneRateMean * par.waneRateMult * parBase.relRate_RtoS; % Rate of moving R to S


%------------------------- Vaccination coverage --------------------------

% By default, the number of doses in each age group is as defined in getBasePar.m
par.nDoses1Smoothed = parBase.nDoses1Smoothed0;
par.nDoses2Smoothed = parBase.nDoses2Smoothed0;
par.nDoses3Smoothed = parBase.nDoses3Smoothed0;
par.nDoses4Smoothed = parBase.nDoses4Smoothed0;



end

