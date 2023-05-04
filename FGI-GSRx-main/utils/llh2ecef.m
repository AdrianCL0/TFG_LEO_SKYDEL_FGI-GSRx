function [x, y, z] = llh2ecef(lat, lon, alt)

    % Constants
    a = 6378137; % WGS-84 Earth semimajor axis (m)
    b = 6356752.3142; % WGS-84 Earth semiminor axis (m)
    e = sqrt(1 - (b/a)^2); % Eccentricity of WGS-84 ellipsoid

    % Intermediate calculations
    N = a / sqrt(1 - e^2 * sind(lat)^2);
    x = (N + alt) * cosd(lat) * cosd(lon);
    y = (N + alt) * cosd(lat) * sind(lon);
    z = (N * (1 - e^2) + alt) * sind(lat);

end