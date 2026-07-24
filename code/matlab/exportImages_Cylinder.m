clear;
[filename, pathname] = uigetfile('*.csv');
T = readtable(strcat(pathname,filename));
data = table2array(T);
% Columns 1 to 3 contain location data
% Columns 4 to 6 contain rotation data

global r L zMin

% ALL USER DEFINED VARIABLES HERE
r = 1; L = 2; % cylindrical particle dimensions
zMin = -100; % defines the z-location of tube bottom
R = 4.7; % radius of tube
dH = 0.5; % distance b/w planes

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
        theta = data(j, 4:6);
        if CheckIntersect(center, theta, z)
            X = []; Y = [];
            [X Y] = coordinates(center, theta, z);
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
    
    daspect([1 1 1])
    
    imagename = strcat(sprintf('%03d', fix(i*dH)), strip(sprintf('%0.1f', mod(abs(i*dH), 1)), 'left', '0'));
    whereToStore=fullfile(DirectoryPath,['z=' imagename '.png']);
    saveas(gcf, whereToStore);
end
% ---MAIN CODE ENDS HERE---


% ---FUNCTION DEFINITIONS---
% returns height of bed
function H = getBedHeight(data)
    global r L zMin
    dummy = zMin*ones(size(data, 1), 1);
    for i = 1:size(data, 1)
        center = data(i, 1:3);
        theta = data(i, 4:6);
        [l m n] = Rot2DirectionCos(theta);
        for j = 1:2
            for k = 1:2
                dummy(i) = max(dummy(i), center(3)+(-1)^j*L/2*n+(-1)^k*r*sqrt(l^2+m^2));
            end
        end
    end
    H = max(dummy)-zMin;
end
    
% returns coordinates of elliptic/part-elliptic impression of cylinder to
% plot
function [X Y] = coordinates(center, theta, z)
    global r L
    [l m n] = Rot2DirectionCos(theta);
    tempExtract = num2cell(center);
    [xc, yc, zc] = tempExtract{:}; % cylinder centre
    a = r/abs(n); b = r; % major and minor radius
    areaEllipse = pi*(3*(a+b)-sqrt((3*a+b)*(a+3*b))); % Ramanujan's approximation for ellipse perimeter
    areaCircle = pi*r^2; % area of circular cut of the cylinder
    N = floor(400*areaEllipse/areaCircle); % number of points to plot the complete ellipse
    xe = xc + l/n*(z-zc);
    ye = yc + m/n*(z-zc);
%     ze = z;
    X = []; Y = [];
    delta = 2*pi/N;
    for i = 1:N
       x = xe + (a*l*cos(i*delta)-b*m*sin(i*delta))/sqrt(l^2+m^2);
       y = ye + (a*m*cos(i*delta)+b*l*sin(i*delta))/sqrt(l^2+m^2);
       % if point falls b/w the enclosing planes of the cylinder, add to
       % plot
       if (l*(x-xc)+m*(y-yc)+n*(z-zc)-L/2)*(l*(x-xc)+m*(y-yc)+n*(z-zc)+L/2)<0
           X = [X, x];
           Y = [Y, y];
       end
    end
    X = [X, X(1)]; Y = [Y, Y(1)]; % close figure
end

% Checks if a set of cylinders intersects a plane
function boolean = CheckIntersect(center, theta, z)
    % center provides the centroid of the cylinder
    % theta provides the rotation information of the cylinder
    % z provides the elevation of the plane
    global r L
    [l m n] = Rot2DirectionCos(theta);
    dummy = [];
    for i = 1:2
        for j = 1:2
            dummy = [dummy, center(3)+(-1)^i*L/2*n+(-1)^j*r*sqrt(l^2+m^2)];
        end
    end
    z_max = max(dummy);
    z_min = min(dummy);
    if (z_max-z)*(z_min-z)<0
        boolean = true;
    else
        boolean = false;
    end
end

% Converts rotation information to direction cosines
function [l m n] = Rot2DirectionCos(theta)
    l = 0; m = 0; n = 1;
    
    % x-rotation transform
    tempExtract = num2cell([1, 0, 0; 0, cos(theta(1)), -sin(theta(1)); 0, sin(theta(1)), cos(theta(1))]*[l; m; n]);
    [l, m, n] = tempExtract{:};
    
    % y-rotation transform
    tempExtract = num2cell([cos(theta(2)), 0, sin(theta(2)); 0, 1, 0; -sin(theta(2)), 0, cos(theta(2))]*[l; m; n]);
    [l, m, n] = tempExtract{:};
    
    % z-rotation transform
    tempExtract = num2cell([cos(theta(3)), -sin(theta(3)), 0; sin(theta(3)), cos(theta(3)), 0; 0, 0, 1]*[l; m; n]);
    [l, m, n] = tempExtract{:};
end
% ---FUNCTION DEFINITIONS END HERE---