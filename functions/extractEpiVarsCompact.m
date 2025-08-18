function epiVarsCompact = extractEpiVarsCompact(t, Y, par)

% Take a matrix representing the ODE solution over time and restructure 
% as a set of matrices representing epidemiological variables
% The number of rows in the input matrix Y is the number of time steps
% The function returns a structure with fields which are matrices each of which has 16 columns corresponding to 16 age groups and 
% rows representing time points. The fields are:
% N - total population size in each group
% V1, V2, V3 - number with at least 1, 2, 3 doses
% S - number in a susceptible compartment
% Su  - number of never infected in each age group
% Sw  - weighted susceptibility (weighted by vulnerability to infection
% 1-VEi in each susceptibility class)
% E1 - number in an exposed compartment for 1st infection (S-class 1-10)
% E2 - number in an exposed compartment for re-infectoin (S-class 11-14)
% I - number infectious & clinical
% A - number infection & subclinical
% Ci - cumulative cases in immunity categorry i (i = 0, 1, 2, 3 doses, r = reinfection)
% Hiocc - current hospital occupancy
% Hidis - cumulative hospital discharges
% Fi - cumulative fatalities


% Interpolate between original and VOC VE parameters
Alpha = normcdf( t'-par.vocWaneDate(1) , 0, par.vocWaneWindow);
VEi = (1-Alpha).*par.VEi + Alpha.*par.VEi_VOC;


% Go through the columns of Y (correspondnig to elements of y) block by block and assign them to the
% relevant variables, each of which is a 64-column matrix for the 64 age-ethnicity combinations
% Preserves the rows of Y, which correspond to daily time points

% In the following, the *comments* assume there are 16x4 = 64 age-ethncity
% combinations

% iCount is an index variable representing the next element of y to be
% assigned
% For each variable to be assigned, nC is the number of elements of y that
% belong to it

% Pop size N
iCount = 1;
nC = par.nAgeGroups * par.nEthnicities;
epiVarsCompact.N = Y(:, iCount : iCount+nC-1);

% Number vaccinated with 1, 2 or 3 doses
iCount = iCount+nC;
epiVarsCompact.V1 = Y(:, iCount : iCount+nC-1 );
iCount = iCount+nC;
epiVarsCompact.V2 = Y(:, iCount : iCount+nC-1 );
iCount = iCount+nC;
epiVarsCompact.V3 = Y(:, iCount : iCount+nC-1 );

% Susceptible S, and weighted susceptibility Sw
iCount = iCount+nC;
nC = par.nAgeGroups * par.nEthnicities * par.nSusComp;
Stemp = Y(:, iCount : iCount+nC-1);         % matrix of nDays x 896 whose columns are the 64 x 14 = 896 susceptible compartments for the 64 age-ethnciity combinations and 14 susceptible comppartments
epiVarsCompact.S = condenseSusLevels(Stemp, par);       % sum over susceptible compartments to get a nDays x 64 matrix of total susceptible in each age-ethnicity combination
epiVarsCompact.Sw = condenseSusLevels(Stemp.*repelem(1-VEi, 1, par.nAgeGroups*par.nEthnicities), par);      % weighted by (1-immunity to infection) to get average susceptibility to infection in each age-ethnicity combination

% Exposed E, subdivied into 1st infections and reifnections
iCount = iCount+nC;
E1temp = Y(:, iCount:iCount+(par.nAgeGroups*par.nEthnicities*10)-1 );      % first infections exposed class (first 10 susceptibility levels)
E2temp = Y(:,  (iCount+par.nAgeGroups*par.nEthnicities*10):iCount+nC-1);     % reinfections exposed class (remaining 4 susceptibility levels)
epiVarsCompact.E1 = condenseSusLevels(E1temp, par);
epiVarsCompact.E2 = condenseSusLevels(E2temp, par);

% Infectious I
iCount = iCount+nC;
Itemp = Y(:, iCount : iCount+nC-1);
epiVarsCompact.I = condenseSusLevels(Itemp, par);

% Asmyptomatic A
iCount = iCount+nC;
Atemp = Y(:, iCount : iCount+nC-1);
epiVarsCompact.A = condenseSusLevels(Atemp, par);

% R is not extracted for output, so just increment the counter by the
% appropriate number, remembering that only 14-1 = 13 columns of R are
% stored in the state variable y
iCount = iCount+nC;
nC = par.nAgeGroups * par.nEthnicities * (par.nSusComp-1);

% Case compartments 
iCount = iCount+nC;
nC = par.nAgeGroups * par.nEthnicities * par.nCaseComp;
epiVarsCompact.C0 = Y(:, (iCount + (par.nCaseComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1) );       % skipping two unobserved case compartments
iCount = iCount+nC;
epiVarsCompact.C1 = Y(:, (iCount + (par.nCaseComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1) );       % skipping two unobserved case compartments
iCount = iCount+nC;
epiVarsCompact.C2 = Y(:, (iCount + (par.nCaseComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1) );       % skipping two unobserved case compartments
iCount = iCount+nC;
epiVarsCompact.C3 = Y(:, (iCount + (par.nCaseComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1) );       % skipping two unobserved case compartments
iCount = iCount+nC;
epiVarsCompact.Cr = Y(:, (iCount + (par.nCaseComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1) );       % skipping two unobserved case compartments

iCount = iCount+nC;
nC = par.nAgeGroups * par.nEthnicities * par.nHospComp;
epiVarsCompact.H0occ = Y(:, (iCount + (par.nHospComp-2)*par.nAgeGroups*par.nEthnicities):(iCount+(par.nHospComp-1)*par.nAgeGroups*par.nEthnicities-1));    % skipping three unobserved hosp compartments
epiVarsCompact.H0dis = Y(:, (iCount + (par.nHospComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1));    
iCount = iCount+nC;
epiVarsCompact.H1occ = Y(:, (iCount + (par.nHospComp-2)*par.nAgeGroups*par.nEthnicities):(iCount+(par.nHospComp-1)*par.nAgeGroups*par.nEthnicities-1));    % skipping three unobserved hosp compartments
epiVarsCompact.H1dis = Y(:, (iCount + (par.nHospComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1));    
iCount = iCount+nC;
epiVarsCompact.H2occ = Y(:, (iCount + (par.nHospComp-2)*par.nAgeGroups*par.nEthnicities):(iCount+(par.nHospComp-1)*par.nAgeGroups*par.nEthnicities-1));    % skipping three unobserved hosp compartments
epiVarsCompact.H2dis = Y(:, (iCount + (par.nHospComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1));    
iCount = iCount+nC;
epiVarsCompact.H3occ = Y(:, (iCount + (par.nHospComp-2)*par.nAgeGroups*par.nEthnicities):(iCount+(par.nHospComp-1)*par.nAgeGroups*par.nEthnicities-1));    % skipping three unobserved hosp compartments
epiVarsCompact.H3dis = Y(:, (iCount + (par.nHospComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1));    
iCount = iCount+nC;
epiVarsCompact.Hrocc = Y(:, (iCount + (par.nHospComp-2)*par.nAgeGroups*par.nEthnicities):(iCount+(par.nHospComp-1)*par.nAgeGroups*par.nEthnicities-1));    % skipping three unobserved hosp compartments
epiVarsCompact.Hrdis = Y(:, (iCount + (par.nHospComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1));    

iCount = iCount+nC;
nC = par.nAgeGroups * par.nEthnicities * par.nDeathComp;
epiVarsCompact.F0 = Y(:, (iCount + (par.nDeathComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1));       % skipping all but 1 unobserved death compartment
iCount = iCount+nC;
epiVarsCompact.F1 = Y(:, (iCount + (par.nDeathComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1));       % skipping all but 1 unobserved death compartment
iCount = iCount+nC;
epiVarsCompact.F2 = Y(:, (iCount + (par.nDeathComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1));       % skipping all but 1 unobserved death compartment
iCount = iCount+nC;
epiVarsCompact.F3 = Y(:, (iCount + (par.nDeathComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1));       % skipping all but 1 unobserved death compartment
iCount = iCount+nC;
epiVarsCompact.Fr = Y(:, (iCount + (par.nDeathComp-1)*par.nAgeGroups*par.nEthnicities):(iCount+nC-1));       % skipping all but 1 unobserved death compartment


% Check all columns of Y have been used
if iCount+nC-1 ~= size(Y, 2)
    error(sprintf('In extractEpiVarsFull: only %i/%i elements of y used', iCount+nC-1,  size(Y, 2)))
end


end
