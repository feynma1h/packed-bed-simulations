clc;
clear;
folder = uigetdir();
files = dir(fullfile(folder, '*.png'));

r = 1; R = 5; R_Pixelunits = 226823/255/4;
xc = 453.5;
yc = 317;
noOfPlanes = size(files, 1);

fprintf('Processing...\n\n');
% SECTOR ANGLE = 90 DEGREES
for i = 1:4
    porosity = zeros(floor(R_Pixelunits)+1, noOfPlanes+1);
    porosity(:, 1) = (R-R/floor(R_Pixelunits)*[0:1:floor(R_Pixelunits)]')/(2*r);

    fprintf('Sector angle: 90 degrees\n');
    for p = 1:noOfPlanes
        fprintf('%d/%d\n', p, noOfPlanes);
        A = imread(fullfile(folder, files(p).name));

        for radius=0:R_Pixelunits/floor(R_Pixelunits):R_Pixelunits
            X = []; Y = [];
            for t=(i-1)*pi/2:2*pi/360:(i-1)*pi/2+pi/2
                X = [X, xc+radius*cos(t)];
                Y = [Y, yc+radius*sin(t)];
            end
            pixelData = impixel(A, X, Y);
            blackandwhite = pixelData(:, :, 1)/255; % 0 represents black and 1 represents white
            white = sum(blackandwhite, 'all');
            black = sum(1-blackandwhite, 'all');
            porosity(int16(radius*floor(R_Pixelunits)/R_Pixelunits+1), p+1) = black/(black+white);
        end
    end

    % porosity(floor(R_Pixelunits)+1, 2:end) = 1;
    porosity = flipud(porosity);

    planeIdentifiers = [];
    for p = 1:noOfPlanes
        planeIdentifiers = [planeIdentifiers; convertCharsToStrings(files(p).name(1:end-4))];
    end

    filename = strcat('porosityData(', string((i-1)*90), '-', string((i-1)*90+90), ').xlsx');
    whereToStore = fullfile(folder, filename);
    writetable(table(porosity(:, 1)', 'RowNames', {'(R-r)/dp'}), whereToStore, 'Sheet', 1, 'Range', 'A1', 'WriteVariableNames', false, 'WriteRowNames', true)
    writetable(table(porosity(:, 2:end)', 'RowNames', planeIdentifiers), whereToStore, 'Sheet', 1, 'Range', 'A3', 'WriteVariableNames', false, 'WriteRowNames', true)
end

% SECTOR ANGLE = 180 DEGREES
for i = 1:4
    porosity = zeros(floor(R_Pixelunits)+1, noOfPlanes+1);
    porosity(:, 1) = (R-R/R_Pixelunits*[0:1:floor(R_Pixelunits)]')/(2*r);

    fprintf('Sector angle: 180 degrees\n');
    for p = 1:noOfPlanes
        fprintf('%d/%d\n', p, noOfPlanes);
        A = imread(fullfile(folder, files(p).name));

        for radius=0:1:floor(R_Pixelunits)
            X = []; Y = [];
            for t=(i-1)*pi/2:2*pi/360:(i-1)*pi/2+pi
                X = [X, xc+radius*cos(t)];
                Y = [Y, yc+radius*sin(t)];
            end
            pixelData = impixel(A, X, Y);
            blackandwhite = pixelData(:, :, 1)/255; % 0 represents black and 1 represents white
            white = sum(blackandwhite, 'all');
            black = sum(1-blackandwhite, 'all');
            porosity(radius+1, p+1) = black/(black+white);
        end
    end

    % porosity(floor(R_Pixelunits)+1, 2:end) = 1;
    porosity = flipud(porosity);

    planeIdentifiers = [];
    for p = 1:noOfPlanes
        planeIdentifiers = [planeIdentifiers; convertCharsToStrings(files(p).name(1:end-4))];
    end

    filename = strcat('porosityData(', string((i-1)*90), '-', string((i-1)*90+180), ').xlsx');
    whereToStore = fullfile(folder, filename);
    writetable(table(porosity(:, 1)', 'RowNames', {'(R-r)/dp'}), whereToStore, 'Sheet', 1, 'Range', 'A1', 'WriteVariableNames', false, 'WriteRowNames', true)
    writetable(table(porosity(:, 2:end)', 'RowNames', planeIdentifiers), whereToStore, 'Sheet', 1, 'Range', 'A3', 'WriteVariableNames', false, 'WriteRowNames', true)
end