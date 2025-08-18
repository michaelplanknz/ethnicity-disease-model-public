function dYdt = calcPopnDynamics(Y, b, Mu, r, nAgeGroups, nEthnicities)

[~, nCols] = size(Y);

if nEthnicities == 1
    dYdt = [b; r*Y(1:end-1, :)] - [r*Y(1:end-1, :); zeros(1, nCols)] - Mu.*Y;
else 
    dYdt = zeros(size(Y));
    for j = 1:nEthnicities
        indices_pick = (j-1)*nAgeGroups + (1:nAgeGroups);
        dYdt(indices_pick, :) = [b(j, :); r*Y(indices_pick(1:end-1), :)] - [r*Y(indices_pick(1:end-1), :); zeros(1, nCols)] - Mu(indices_pick).*Y(indices_pick, :);
    end
end
