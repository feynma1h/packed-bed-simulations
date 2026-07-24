clear;
[filename, pathname] = uigetfile('*.csv');
T = readtable(strcat(pathname,filename));
data = table2array(T);
% Columns 1 to 3 contain location data
global r zMin

% ALL USER DEFINED VARIABLES HERE
r = 1.032280115; % spherical particle dimension
zMin = -100; % defines the z-location of tube bottom
R = 5; % radius of tube
dH = 0.1; % distance b/w planes

% ---MAIN CODE BEGINS HERE---
H = getBedHeight(data);
N = ceil(H/dH);

DirectoryPath = uigetdir(); % gets where to export the images

for i = 1:N
    X = R*cos(0:2*pi/(400*floor(R/r)):2*pi);
    Y = R*sin(0:2*pi/(400*floor(R/r)):2*pi);
    fill(X, Y, 'k', 'LineStyle', 'none')
    hold on
    z = zMin+i*dH;
    for j = 1:size(data, 1)
        center = data(j, 1:3);
        if CheckIntersect(center, z)
            X = []; Y = [];
            [X Y] = coordinates(center, z);
            fill(X, Y, 'w', 'LineStyle', 'none')
            hold on
        end
    end
    hold off
    
%     f = gcf;
%     f.Units = 'pixels';
%     f.OuterPosition = [0 0 1920 1080];
%     ppi = 225;
%     set(f,'PaperPositionMode','manual')
%     f.PaperUnits = 'inches';
%     f.PaperPosition = [0 0 1920 1080]/ppi;
    
    xlim([-6 6])
    ylim([-6 6])
    daspect([1 1 1])
    
    imagename = strcat(sprintf('%03d', fix(i*dH)), strip(sprintf('%0.1f', mod(abs(i*dH), 1)), 'left', '0'));
    whereToStore=fullfile(DirectoryPath,['z=' imagename '.png']);
    saveas(gcf, whereToStore);
end
% ---MAIN CODE ENDS HERE---


% ---FUNCTION DEFINITIONS---
% returns height of bed
function H = getBedHeight(data)
    global r zMin
    H = max(data(:, 3))+r-zMin;
end
    
% returns coordinates of circular impression of sphere to plot
function [X Y] = coordinates(center, z)
    global r
    tempExtract = num2cell(center);
    [xc, yc, zc] = tempExtract{:}; % sphere centre
    r_impression = sqrt(r^2 - (center(3)-z)^2); % radius of circular impression
    areaImpression = pi*(r_impression)^2; % area of circular impression
    areaCircle = pi*r^2; % area of circle with radius same as sphere
    N = floor(400*areaImpression/areaCircle); % number of points to plot the complete impression
    X = []; Y = [];
    delta = 2*pi/N;
    for i = 1:N
       x = xc + r_impression*cos(i*delta);
       y = yc + r_impression*sin(i*delta);
       X = [X, x];
       Y = [Y, y];
    end
    if ~isempty(X) & ~isempty(Y)
        X = [X, X(1)]; Y = [Y, Y(1)]; % close figure
    end
end

% Checks if a sphere intersects a plane
function boolean = CheckIntersect(center, z)
    % center provides the centroid of the sphere
    % z provides the elevation of the plane
    global r
    if (center(3)+r-z)*(center(3)-r-z)<0
        boolean = true;
    else
        boolean = false;
    end
end
% ---FUNCTION DEFINITIONS END HERE---