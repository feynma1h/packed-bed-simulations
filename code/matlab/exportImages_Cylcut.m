clear;
[filename, pathname] = uigetfile('*.csv');
T = readtable(strcat(pathname,filename));
data = table2array(T);
% Columns 1 to 3 contain location data
% Columns 4 to 6 contain rotation data

global d r2 L zMin

% ALL USER DEFINED VARIABLES HERE
r1 = 0.75; r2 = 1; L = 2; t = 0.25; % Daisy particle dimensions (r1 is inner radius. r2 is outer.)
d = 2*sqrt(r1^2-(t/2)^2);
zMin = 0; % defines the z-location of tube bottom
R = 2; % radius of tube
dH = 0.5; % distance b/w planes

% ---MAIN CODE BEGINS HERE---
H = getBedHeight(data);
N = ceil(H/dH);

DirectoryPath = uigetdir(); % gets where to export the images

for i = 1:N
    X = R*cos(0:2*pi/(400*floor(R/r2)):2*pi);
    Y = R*sin(0:2*pi/(400*floor(R/r2)):2*pi);
    fill(X, Y, 'k', 'LineStyle', 'none')
    hold on
    z = zMin+i*dH;
    for j = 1:size(data, 1)
        center = data(j, 1:3);
        theta = data(j, 4:6);
        if CheckIntersect(center', theta, z, r2)
            cuboidCenters = [center' center'];
            % plot hollow cylinder
            X = []; Y = [];
            [X Y] = cylinderCoordinates(center, theta, z, r2);
            fill(X, Y, 'w', 'LineStyle', 'none')
            hold on
            X = []; Y = [];
            [X Y] = cylinderCoordinates(center, theta, z, r1);
            fill(X, Y, 'k', 'LineStyle', 'none')
            hold on
            % loop to plot cuboids
            for k = 1:size(cuboidCenters, 2)
                X = []; Y = [];
                [X Y] = cuboidCoordinates(cuboidCenters(:, k), theta, z, t, (k-1)*pi/size(cuboidCenters, 2));
                fill(X, Y, 'w', 'LineStyle', 'none')
                hold on
            end
            % loop to plot circular segments of cylinder
            for k = 1:4
                X = []; Y = [];
                [X Y] = partCylinderCoordinates(center, theta, z, r1, [k*pi/2-atan(t/d), k*pi/2+atan(t/d)]);
                fill(X, Y, 'w', 'LineStyle', 'none')
                hold on
            end
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
    global r2 L zMin
    dummy = zMin*ones(size(data, 1), 1);
    for i = 1:size(data, 1)
        center = data(i, 1:3);
        theta = data(i, 4:6);
        [l m n] = Rot2DirectionCos(theta);
        for j = 1:2
            for k = 1:2
                dummy(i) = max(dummy(i), center(3)+(-1)^j*L/2*n+(-1)^k*r2*sqrt(l^2+m^2));
            end
        end
    end
    H = max(dummy)-zMin;
end
   
% returns coordinates of elliptic/part-elliptic impression of cylinder to
% plot
function [X Y] = cylinderCoordinates(center, theta, z, r)
    global L
    DirectionCos = Rot2DirectionCos(theta, [0; 0; 1]);
    l = DirectionCos(1, :);
    m = DirectionCos(2, :);
    n = DirectionCos(3, :);
    xc = center(1);
    yc = center(2);
    zc = center(3); % cylinder centre
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
    if ~isempty(X) & ~isempty(Y)
        X = [X, X(1)]; Y = [Y, Y(1)]; % close figure
    end
end

% returns coordinates of elliptic/part-elliptic impression of cylinder to
% plot
function [X Y] = partCylinderCoordinates(center, theta, z, r, thetaRange)
    global L
    A = Rot2DirectionCos(theta, [[1; 0; 0] [0; 1; 0] [0; 0; 1]]);
    % A stores the unit vector directions along the x, y and z axes of the
    % cylinder in terms of the unit vectors along the original axes
    % Column 1: x; Column 2: y; Column 3: z;
    
    B = [0; 0; 1];
    DirectionCos = cross(A(:, 3), [0; 0; 1])/norm(cross(A(:, 3), [0; 0; 1]));
    B = [DirectionCos B];
    DirectionCos = cross(DirectionCos(:, 1), [0; 0; 1])/norm(cross(DirectionCos(:, 1), [0; 0; 1])); % here DirectionCos stores the direction of the minor axis in the RHS of the eqn
    B = [DirectionCos B];
    % B stores the unit vector directions along the x, y and z axes of the
    % ellipse in terms of the unit vectors along the original axes
    % Column 1: major axis; Column 2: minor axis; Column 3: z;
    
    tempExtract = num2cell(center);
    [xc, yc, zc] = tempExtract{:}; % cylinder centre
    
    a = r/abs(A(3, 3)); b = r; % major and minor radius
    areaEllipse = pi*(3*(a+b)-sqrt((3*a+b)*(a+3*b))); % Ramanujan's approximation for ellipse perimeter
    areaCircle = pi*r^2; % area of circular cut of the cylinder
    N = floor(400*areaEllipse/areaCircle*range(thetaRange)/(2*pi)); % number of points to plot the complete ellipse
    
    t1 = min(thetaRange); t2 = max(thetaRange);
    
    X = []; Y = [];
    delta = range(thetaRange)/N;
    for i = 1:N+1
        dummyVector = [xc; yc; zc] + r*cos(t1+(i-1)*delta)*A(:, 1) + r*sin(t1+(i-1)*delta)*A(:, 2);
        x_cyl = dummyVector(1); y_cyl = dummyVector(2); z_cyl = dummyVector(3);
        
        dummyVector = [x_cyl; y_cyl; z_cyl] + (z-z_cyl)/A(3, 3)*A(:, 3);
        x = dummyVector(1); y = dummyVector(2); % z = dummyVector(3);

        if (A(:, 3)'*[x-xc; y-yc; z-zc]-L/2)*(A(:, 3)'*[x-xc; y-yc; z-zc]+L/2)<0
            X = [X, x];
            Y = [Y, y];
        end
    end

    if ~isempty(X) & ~isempty(Y)
        X = [X, X(1)]; Y = [Y, Y(1)]; % close figure
    end
end

% returns coordinates of cuboid impression to plot
function [X Y] = cuboidCoordinates(center, theta, z, t, lobeAngle)
    global d L
    
    X = []; Y = [];
    DirectionCos = Rot2DirectionCos(theta, zRotate(lobeAngle, [1; 0; 0]));
    lx = DirectionCos(1, :);
    mx = DirectionCos(2, :);
    nx = DirectionCos(3, :);    
    DirectionCos = Rot2DirectionCos(theta, zRotate(lobeAngle, [0; 1; 0]));
    ly = DirectionCos(1, :);
    my = DirectionCos(2, :);
    ny = DirectionCos(3, :);
    DirectionCos = Rot2DirectionCos(theta, zRotate(lobeAngle, [0; 0; 1]));
    lz = DirectionCos(1, :);
    mz = DirectionCos(2, :);
    nz = DirectionCos(3, :);

    planePoints = [[center-t/2*[lx; mx; nx]] [center+t/2*[lx; mx; nx]] [center-d/2*[ly; my; ny]] [center+d/2*[ly; my; ny]] [center-L/2*[lz; mz; nz]] [center+L/2*[lz; mz; nz]]]; % identifying points for the various planes making the cuboid
    %NOTE: [leftPlane, rightPlane, bottomPlane, topPlane, backPlane,
    %forwardPlane] is the order of points for the planes

    planeNormals = [[lx; mx; nx] [lx; mx; nx] [ly; my; ny] [ly; my; ny] [lz; mz; nz] [lz; mz; nz]]; % identifying normals for the various planes making the cuboid
    %NOTE: Same order as the points

    points = [];
    for j = 1:6
        xl = planeNormals(2, j)*((planeNormals(:, j)'*(planePoints(:, j)-[0; 0; z]))/(2*planeNormals(2, j)*planeNormals(1, j)));
        yl = planeNormals(1, j)*((planeNormals(:, j)'*(planePoints(:, j)-[0; 0; z]))/(2*planeNormals(2, j)*planeNormals(1, j)));
        zl = z; % (xl, yl, zl) are the points identifying the line formed by the intersection of the current plane with the plane z=z

        for k = 1:4
            planeIndex = mod(j+mod(j, 2)+k, 6);
            planeIndex = (planeIndex==0)*6 + (planeIndex~=0)*planeIndex; % index of current plane intersecting the line
            intersectionPoint = [xl; yl; zl] + cross(planeNormals(:, j), [0; 0; 1]) * (planeNormals(:, planeIndex)'*(planePoints(:, planeIndex)-[xl; yl; zl]))/(planeNormals(1, planeIndex)*planeNormals(2, j)-planeNormals(1, j)*planeNormals(2, planeIndex));
            indexCheckBetween = mod(j+mod(j, 2)+[2*k-1, 2*k] + 2*mod(k, 2), 6);
            indexCheckBetween(find(indexCheckBetween==0)) = 6; % index of planes which are to be used to check if the "instersectionPoint" lies b/w them
            p1 = indexCheckBetween(1);
            p2 = indexCheckBetween(2);
            if (planeNormals(:, p1)'*(intersectionPoint-planePoints(:, p1))) * (planeNormals(:, p2)'*(intersectionPoint-planePoints(:, p2))) < 0
                points = [points intersectionPoint];
            end
        end
    end
    points = arrangeCyclic(points);
    X = [X, points(1, :)'];
    Y = [Y, points(2, :)'];
end

% Checks if a set of cylinders intersects a plane
function boolean = CheckIntersect(center, theta, z, r)
    % center provides the centroid of the cylinder
    % theta provides the rotation information of the cylinder
    % z provides the elevation of the plane
    global L
    DirectionCos = Rot2DirectionCos(theta, [0; 0; 1]);
    l = DirectionCos(1, :);
    m = DirectionCos(2, :);
    n = DirectionCos(3, :);
    dummy = [];
    for i = 1:2
        for j = 1:2
            dummy = [dummy; center(3)+(-1)^i*L/2*n+(-1)^j*r*sqrt(l^2+m^2)];
        end
    end
    z_max = max(dummy);
    z_min = min(dummy);
    boolean = (z_max-z).*(z_min-z)<0;
end

% Converts rotation information to direction cosines
function DirectionCos = Rot2DirectionCos(theta, initialDirectionCos)

    % x-rotation transform
    DirectionCos = [1, 0, 0; 0, cos(theta(1)), -sin(theta(1)); 0, sin(theta(1)), cos(theta(1))]*initialDirectionCos;
    
    % y-rotation transform
    DirectionCos = [cos(theta(2)), 0, sin(theta(2)); 0, 1, 0; -sin(theta(2)), 0, cos(theta(2))]*DirectionCos;
    
    % z-rotation transform
    DirectionCos = [cos(theta(3)), -sin(theta(3)), 0; sin(theta(3)), cos(theta(3)), 0; 0, 0, 1]*DirectionCos;
end

% Converts rotation information to direction cosines
function DirectionCos = zRotate(theta, initialDirectionCos)

    % z-rotation transform
    DirectionCos = [cos(theta), -sin(theta), 0; sin(theta), cos(theta), 0; 0, 0, 1]*initialDirectionCos;
end

% Arranges a set of (x, y) points in cyclic order so that they can be plotted
function arrangedPoints = arrangeCyclic(points)
    center = mean(points, 2);
    angles = atan2d((points(2, :)-center(2)), (points(1, :)-center(1)));
    [~, sortedIndexes] = sort(angles); % [sortedAngles, sortedIndexes] = sort(angles);
    arrangedPoints = points(:, sortedIndexes);  % Reorder the points with the new sort order.
end
% ---FUNCTION DEFINITIONS END HERE---