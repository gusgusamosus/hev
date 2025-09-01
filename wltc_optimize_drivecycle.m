%% STEP 1: Load Data
filePath = "C:\Users\srich\OneDrive\Desktop\Projects\HEV\wltc.csv";  % Update path/filename
fprintf('Loading driving cycle dataset...\n');
data = readtable(filePath);
fprintf('Loaded %d rows, %d columns.\n', size(data,1), size(data,2));

%% STEP 2: Feature Selection
fprintf('Selecting relevant variables...\n');
selectedVars = {'speed', 'accel', 'energy_density', 'fuel'};
X = table2array(data(:, selectedVars));
X = rmmissing(X);

%% STEP 3: K-Means Clustering
fprintf('Running K-Means clustering...\n');
X_scaled = normalize(X);
k = 3;
[idx, C] = kmeans(X_scaled, k, 'Replicates', 5);

figure;
gscatter(X_scaled(:,1), X_scaled(:,2), idx);
xlabel('Speed'); ylabel('Acceleration');
title('Clustering of Driving Samples');

%% STEP 4: Synthetic Driving Cycle from Centroids
fprintf('Generating synthetic cycle from centroids...\n');
synthetic_cycle = array2table(C, 'VariableNames', selectedVars);
disp('Cluster centroids (synthetic samples):');
disp(synthetic_cycle);

%% STEP 5: Optimization
fprintf('Synthesizing cycle for minimal energy_density...\n');
objective = @(x) x(3);  % Minimize 'energy_density'

lb = min(X);  % Lower bounds from real data
ub = max(X);  % Upper bounds from real data
x0 = C(1,:);  % Start with centroid of first cluster

% Add a nonlinear constraint to bound speed (optional)
nonlcon = @(x) deal([], x(1) - 130);  % speed ≤ 130 km/h

opts = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
[x_opt, fval] = fmincon(objective, x0, [], [], [], [], lb, ub, nonlcon, opts);

optCycle = array2table(x_opt, 'VariableNames', selectedVars);
disp('Speed Profile : K-Means Clustering Applied');
disp(optCycle);

%% STEP 6: Generate Time-Series Driving Profile
fprintf('Simulating enhanced time-series version...\n');

duration = 1800;  % 20-minute cycle (seconds)
t = (0:duration)';

% Generate base triangular speed profile
peak_speed = optCycle.speed;
half_point = floor(length(t)/2);
base_speed = [linspace(0, peak_speed, half_point), linspace(peak_speed, 0, length(t)-half_point)]';

% Add realistic fluctuations
modulation = 6 * sin(2 * pi * t / 60);
jitter = 3 * randn(length(t),1);
speed = base_speed + modulation + jitter;
speed = max(min(speed, 130), 0);  % Clamp between 0–130

% Compute acceleration
accel = [0; diff(speed)] * (1000/3600);  % Convert km/h/s to m/s²

% Estimate rolling energy density and fuel
base_energy = optCycle.energy_density;
energy_density = base_energy + 0.4 * speed + 2.5 * abs(accel);
fuel_rate = energy_density * 0.0001;
fuel = cumsum(fuel_rate);

% Create table
optCycle_time_series = table(t, speed, accel, energy_density, fuel, ...
    'VariableNames', {'time', 'speed', 'accel', ['energy_density' ...
    ''], 'fuel'});

% Save to CSV
outputPath = "C:\Users\srich\OneDrive\Desktop\Projects\HEV\optimized_wltc.csv";
writetable(optCycle_time_series, outputPath);
fprintf('Saved synthesized cycle to: %s\n', outputPath);

%% STEP 7: Visualization
figure;
subplot(3,1,1); plot(t, speed); ylabel('Speed (km/h)'); title('Synthesized Cycle : Speed Profile');
subplot(3,1,2); plot(t, energy_density); ylabel('Energy Density');
subplot(3,1,3); plot(t, fuel); ylabel('Cumulative Fuel (L)'); xlabel('Time (s)');
