%% This program will linearly interpolate a the Helium NIST data into a 3rd order polynomial
clear, clc, close all;

% Set the order of the polynomial
degree = 3;

% Symbolic temperature
syms T;

% The aquired temperatures and pressures
temps = [100,125,150,175,200,225,250,275,300,325,350,375,400,425,450,475,500,525,550,575,600];

% The dataset to load in
dataset_location = "X:\03_COOP_and_Summer_Students\2023\Koah Ross\HeliumProperties\Data\HeMix_90.mat";

% Load in the dataset
dataset = load(dataset_location);

% Extract the data from the struct
dataset_names = fieldnames(dataset);
he_data = dataset.(dataset_names{1});

% Delete the first point of all data for better iterpolation
he_data.Cv = he_data.Cv(2:end);
he_data.Cp = he_data.Cp(2:end);
he_data.k = he_data.k(2:end);
he_data.mu = he_data.mu(2:end);

% Divide Cv and Cp by 1000 to convert from J/g*K to J/kg*K
he_data.Cv = he_data.Cv.*1000;
he_data.Cp = he_data.Cp.*1000;

% Create a linear interpolation of the data
Cv_poly = polyfit(temps, he_data.Cv,degree);
Cp_poly = polyfit(temps, he_data.Cp,degree);
k_poly = polyfit(temps, he_data.k, degree);
mu_poly = polyfit(temps, he_data.mu,degree);

% Create plot
tiledlayout("flow")

% Compare the fits
ComparePlot(temps, he_data.Cv, Cv_poly, "Cv")
ComparePlot(temps, he_data.Cp, Cp_poly, "Cp")
ComparePlot(temps, he_data.k, k_poly, "k")
ComparePlot(temps, he_data.mu, mu_poly, "mu")

% Export to terminal for pasting
fprintf('Cv (dT_du):       ')
FormatEquation(Cv_poly, degree)

fprintf('Cp (dh_dT):       ')
FormatEquation(Cp_poly, degree)

fprintf('K:       ')
FormatEquation(k_poly, degree)

fprintf('mu:       ')
FormatEquation(mu_poly, degree)

% Find average Cv and take reciprocal
recip_Cv = (he_data.Cv(1) + he_data.Cv(length(he_data.Cv)))./2;

disp(strcat("1/Cv:       ",string(1/recip_Cv)))


function ComparePlot(temps, original, poly, value)
    nexttile; hold on;
    points = polyval(poly, temps);
    plot(temps, points, '--')
    plot(temps, original, 'x')
    ylabel(value)
    xlabel("Temp")
end

function FormatEquation(poly, degree)
    poly_string = string(abs(poly));
    equ = "";
    exponent = degree;

    % Main portion
    for i = 1:(degree - 1)
        if i == 1
            equ = strcat(string(poly(i)), "*(T.^", string(exponent), ")");
        else
            if poly(i) > 0
                operation = " + ";
            else
                operation = " - ";
            end
        
            equ = strcat(equ, operation, poly_string(i), "*(T.^", string(exponent), ")");
        end
        exponent = exponent - 1;
    end

    % Second last term
    if poly(degree) > 0
        equ = strcat(equ, " + ", poly_string(degree), "*(T)");
    else
        equ = strcat(equ, " - ", poly_string(degree), "*(T)");
    end

    % Last term
    if poly(degree+1) > 0
        equ = strcat(equ, " + ", poly_string(degree+1));
    else
        equ = strcat(equ, " - ", poly_string(degree+1));
    end

    fprintf(equ)
    fprintf('\n')
end