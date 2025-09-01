%% STEP 1: Load Data
filePath = "C:\Users\srich\OneDrive\Desktop\Sem 6\Hybrid and EV Vehicles\DA\all_trips_combined.csv"; 
fprintf('Loading dataset...\n');
data = readtable(filePath);
fprintf('Loaded %d rows, %d columns.\n', size(data,1), size(data,2));

%% STEP 2: Feature Selection
selectedVars = {
    'absolute_time_duration_hrs', ...
    'aerodynamic_speed', ...
    'characteristic_acceleration', ...
    'characteristic_deceleration', ...
    'kinetic_intensity', ...
    'average_instantanteous_rolling_energy_density', ...
    'cumulative_instanteous_rolling_energy_density', ...
    'ca_standard', ...
    'cd_standard', ...
    'ki_standard', ...
    'as_standard'
};

fprintf('Selecting relevant features...\n');
features = data(:, selectedVars);
features = rmmissing(features);  % Clean NaNs
X = table2array(features);

%% STEP 3: Correlation Analysis
fprintf('Computing correlation matrix...\n');
corrMatrix = corr(X, 'Rows', 'complete');

figure;
heatmap(selectedVars, selectedVars, corrMatrix, ...
    'Colormap', parula, 'ColorbarVisible', 'on');
title('Correlation Matrix of Features');

%% STEP 4: Clustering with K-Means
fprintf('Clustering using K-means...\n');
X_scaled = normalize(X);
k = 4;
[idx, C] = kmeans(X_scaled, k, 'Replicates', 5);

figure;
gscatter(X_scaled(:,1), X_scaled(:,2), idx);
xlabel(selectedVars{1});
ylabel(selectedVars{2});
title('K-Means Clustering of Driving Trips');

%% STEP 5: Generate Synthetic Driving Cycle from Centroids
fprintf('Generating synthetic driving cycles from cluster centroids...\n');

% Create a synthetic trip using centroids of each cluster
synthetic_cycle = array2table(C, 'VariableNames', selectedVars);
disp('Synthetic driving cycles based on cluster centroids:');
disp(synthetic_cycle);

%% STEP 6: Optimization of Synthetic Cycle
fprintf('Selecting synthetic cycle clusters for lower energy use...\n');

% Objective: Minimize average rolling energy density
objective = @(x) x(6);  % Minimize 'average_instantanteous_rolling_energy_density'

% Constraints:
% 1. Maintain acceleration and aerodynamic speed within bounds
lb = min(X);  % Lower bounds from real data
ub = max(X);  % Upper bounds from real data

% Initial guess from one of the synthetic centroids
x0 = C(1,:);  % Choose Cluster 1 centroid

% Add a non-linear constraint to enforce reasonable trip time
nonlcon = @(x) deal([], x(1) - 0.5);  % 'absolute_time_duration_hrs' ≤ 0.5

% Run optimization
opts = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
[x_opt, fval] = fmincon(objective, x0, [], [], [], [], lb, ub, nonlcon, opts);

% Convert to table for easier interpretation
optCycle = array2table(x_opt, 'VariableNames', selectedVars);
disp('Generated synthetic driving cycle:');
disp(optCycle);

%% Generate Time-Series Version of Synthesized Cycle
duration = round(optCycle.absolute_time_duration_hrs * 3600);  % Convert hours to seconds
t = (0:duration)';  % Time vector (s)

% Simulate speed ramp up and down (triangular profile)
peak_speed = optCycle.aerodynamic_speed;  % km/h
half_point = floor(length(t)/2);
speed = [linspace(0, peak_speed, half_point), linspace(peak_speed, 0, length(t)-half_point)]';

% Estimate acceleration (simple diff)
accel = [0; diff(speed)];  % Approximate accel in km/h/s
accel = accel * (1000/3600);  % Convert to m/s^2

% Estimate energy density (e.g., base + variation)
base_energy = optCycle.average_instantanteous_rolling_energy_density;
energy_density = base_energy + 5 * sin(2 * pi * t / duration);

% Estimate fuel consumption (cumulative)
fuel_rate = base_energy / 10000;  % L/s (approx)
fuel = cumsum(fuel_rate * ones(size(t)));  % cumulative fuel in L

% Build table
optCycle_time_series = table(t, speed, accel, energy_density, fuel, ...
    'VariableNames', {'time', 'speed', 'accel', 'energy_density', 'fuel'});

% Save to CSV
writetable(optCycle_time_series, 'C:\Users\srich\OneDrive\Desktop\Sem 6\Hybrid and EV Vehicles\DA\optimized_cycle.csv');

%% STEP 7: Visual Comparison
figure;
bar([x0(6), x_opt(6)]);  % Compare energy use
xticklabels({'Original Centroid', 'Optimized'})
ylabel('Avg Rolling Energy Density')
title('Energy Optimization Result');

%% Generate Enhanced Time-Series Version of Synthesized Cycle
fprintf('\nGenerating second-by-second time series with realistic variability...\n');

duration = round(optCycle.absolute_time_duration_hrs * 3600);  % Convert hours to seconds
t = (0:duration)';  % Time vector (s)

% Base speed profile: triangle + sine modulation + noise
peak_speed = optCycle.aerodynamic_speed;  % km/h
half_point = floor(length(t)/2);

% Base triangle
base_speed = [linspace(0, peak_speed, half_point), linspace(peak_speed, 0, length(t)-half_point)]';

% Add sine modulation (urban stop/start behavior)
modulation = 6 * sin(2 * pi * t / 60);  % every ~minute
% Add random jitter (driver variance)
jitter = 3 * randn(length(t), 1);  % normally distributed noise

% Combine
speed = base_speed + modulation + jitter;
speed = max(speed, 0);  % Clamp to 0
speed = min(speed, 130);  % Clamp max to 130 km/h

% Estimate acceleration
accel = [0; diff(speed)] * (1000 / 3600);  % Convert from km/h/s to m/s²

% Estimate rolling energy density
base_energy = optCycle.average_instantanteous_rolling_energy_density;
energy_density = base_energy + 0.4 * speed + 2.5 * abs(accel);

% Estimate cumulative fuel use
fuel_rate = energy_density * 0.0001;  % Wh/km → L/s (approximate)
fuel = cumsum(fuel_rate);

% Assemble table
optCycle_time_series = table(t, speed, accel, energy_density, fuel, ...
    'VariableNames', {'time', 'speed', 'accel', 'energy_density', 'fuel'});

% Save to CSV
writetable(optCycle_time_series, 'C:\Users\srich\OneDrive\Desktop\Sem 6\Hybrid and EV Vehicles\DA\optimized_cycle.csv');
fprintf('Saved to CSV.\n');


