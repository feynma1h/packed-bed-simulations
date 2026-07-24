% Z-AVERAGED RADIAL POROSITY FOR VARIOUS RANGES OF Z VALUES

clear;

[filename, pathname] = uigetfile('*.csv');
T = readtable(strcat(pathname,filename));
data = table2array(T([1, 3:end], 2:end));

% USER DEFINED VARIABLE
% first element is the range start for all the ranges
% second and all following elements are range ends
range = [60, 170:40:450];

range = range/10;
for i = 1:numel(range)
    identifier{i} = strcat(sprintf('%03d', fix(range(i))), strip(sprintf('%0.1f', mod(abs(range(i)), 1)), 'left', '0'));
end

index = find(contains(table2array(T(3:end, 1)), strcat('z=', identifier)))+1; % row numbers in array "data" corresponding to the z values

porosity = [];
porosity(:, 1) = data(1, :)';
for i=2:numel(range)
    porosity(:, i) = mean(data(index(1):index(i), :))';
end

for i = 1:numel(range)-1
    planeIdentifiers{i} = strcat('z=(' ,sprintf('%03d', fix(range(1))), strip(sprintf('%0.1f', mod(abs(range(1)), 1)), 'left', '0'), '-', sprintf('%03d', fix(range(i+1))), strip(sprintf('%0.1f', mod(abs(range(i+1)), 1)), 'left', '0'), ')cm');
end

filename = 'z-averagedPorosityData.xlsx';
whereToStore = fullfile(pathname, filename);
writetable(table(porosity(:, 1)', 'RowNames', {'(R-r)/dp'}), whereToStore, 'Range', 'A1', 'WriteVariableNames', false, 'WriteRowNames', true)
writetable(table(porosity(:, 2:end)', 'RowNames', planeIdentifiers), whereToStore, 'Range', 'A3', 'WriteVariableNames', false, 'WriteRowNames', true)