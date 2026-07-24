% Z-AVERAGED RADIAL POROSITY FOR VARIOUS RANGES OF THETA-AVERAGING

clear;

[filename, pathname] = uigetfile('*.csv');
T = readtable(strcat(pathname,filename));
data = table2array(T(3:end, [1, 2, 4, 5, 7, 8, 10, 11, 13, 14]));
data = str2double(data);

for i = 1:5
    plot(data(:, 2*i-1), data(:, 2*i));
    hold on
end
hold off

legend({'\theta=(0-360)', '\theta=(0-90)', '\theta=(90-180)', '\theta=(180-270)', '\theta=(270-360)'}, 'Location', 'best', 'Orientation', 'horizontal')

xlabel('^{(R-r)}/_{d_{P}}')
ylabel('\theta-z averaged porosity')

daspect([1 1 1])

% whereToStore=fullfile(DirectoryPath, ['theta-z averaged porosity.png']);
% saveas(gcf, whereToStore);