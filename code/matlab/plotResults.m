clear;

% COMPARISON OF Z-AVERAGED RADIAL POROSITY PROFILES FOR 5 EQUALLY SPACED 
% PLANES FOR IMAGES OBTAINED FROM ANSYS AND MATLAB

[filename, pathname] = uigetfile('*.csv');
T = readtable(strcat(pathname,filename));
dataAnsys = table2array(T([1, 3:7], 2:end));

[filename, pathname] = uigetfile('*.csv');
T = readtable(strcat(pathname,filename));
dataMATLAB = table2array(T([1, 3:7], 2:end));

DirectoryPath = uigetdir(); % gets where to export the graphs

for i=1:5
    plot(dataAnsys(1, :), dataAnsys(2, :));
    hold on
    
    plot(dataMATLAB(1, :), dataMATLAB(2, :));
    hold off

    identifier = table2array(T(3:end, 1));

    title([identifier{i} 'cm'])
    legend({'Ansys', 'MATLAB'}, 'Location', 'best', 'Orientation', 'horizontal')
    xlabel('^{(R-r)}/_{d_{P}}')
    ylabel('\theta averaged porosity')

    daspect([1 1 1])

    whereToStore=fullfile(DirectoryPath, [identifier{i} '.png']);
    saveas(gcf, whereToStore);
end

% PERCENTAGE DEVIATIONS FROM AVERAGE POROSITY

clear;

[filename, pathname] = uigetfile('*.csv');
T = readtable(strcat(pathname,filename));
data = table2array(T([1, 3:end], 2:end));

% DirectoryPath = uigetdir(); % gets where to export the graph

% enter z values in mm for which deviations are to be plotted
z = [60, 100, 150, 200, 250];

z = z/10;
for i = 1:numel(z)
    identifier{i} = strcat('z=', sprintf('%03d', fix(z(i))), strip(sprintf('%0.1f', mod(abs(z(i)), 1)), 'left', '0'));
end

index = find(contains(table2array(T(3:end, 1)), identifier))+1; % row numbers in array "data" corresponding to the z values

for i=1:numel(z)
    plot(data(1, :), data(index(i), :));
    hold on
end
hold off

legend(strcat(identifier, 'cm'), 'Location', 'best', 'Orientation', 'horizontal')
xlabel('^{(R-r)}/_{d_{P}}')
ylabel('percentage deviation from average porosity')

daspect([1 1 1])

% whereToStore=fullfile(DirectoryPath, ['deviations.png']);
% saveas(gcf, whereToStore);

% Z-AVERAGED RADIAL POROSITY FOR VARIOUS RANGES OF Z VALUES

clear;

[filename, pathname] = uigetfile('*.csv');
T = readtable(strcat(pathname,filename));
data = table2array(T([1, 3:end], 2:end));

% DirectoryPath = uigetdir(); % gets where to export the graph

% USER DEFINED VARIABLE
% first element is the range start for all the ranges
% second and all following elements are range ends
range = [60, 170, 210, 250, 290, 330, 370, 410, 450];

range = range/10;
for i = 1:numel(range)
    identifier{i} = strcat(sprintf('%03d', fix(range(i))), strip(sprintf('%0.1f', mod(abs(range(i)), 1)), 'left', '0'));
end

index = find(contains(table2array(T(3:end, 1)), strcat('z=', identifier)))+1; % row numbers in array "data" corresponding to the z values

for i=2:numel(range)
    plot(data(1, :), mean(data(index(1):index(i), :)));
    hold on
end
hold off

legend(strcat('z=(', identifier{1}, '-', identifier(2:end), ')cm'), 'Location', 'best', 'Orientation', 'horizontal')
xlabel('^{(R-r)}/_{d_{P}}')
ylabel('\theta-z averaged porosity')

daspect([1 1 1])

% whereToStore=fullfile(DirectoryPath, ['theta-z averaged porosity.png']);
% saveas(gcf, whereToStore);