%% compare_driving_cycles.m
% Compare K-Means Clustered, WLTC, and Real-Trip Reference (from trips_84.csv)

%% Load Cycle Data
optimized1 = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\optimized_cycle.csv");
optimized2 = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\optimized_wltc.csv");
wltc = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\wltc.csv");

% Create reference line over time
t_ref1 = optimized1.time;
t_ref2 = optimized2.time;

%% Plot 1: Speed vs Time
figure;
plot(optimized1.time, optimized1.speed, 'b--', 'LineWidth', 1.5); hold on;
plot(optimized2.time, optimized2.speed, 'r-', 'LineWidth', 1.5); hold on;
plot(wltc.time, wltc.speed, 'g-.', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Speed (km/h)');
legend('K-Means Clustered NREL', 'K-Means Clustered WLTC', 'WLTC');
title('Speed vs Time Comparison');
grid on;

%% Plot 2: Acceleration vs Time
figure;
plot(optimized1.time, optimized1.accel, 'b--', 'LineWidth', 1.5); hold on;
plot(optimized2.time, optimized2.accel, 'r-', 'LineWidth', 1.5); hold on;
plot(wltc.time, wltc.accel, 'g-.', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Acceleration (m/s^2)');
legend('K-Means Clustered NREL', 'K-Means Clustered WLTC', 'WLTC');
title('Acceleration vs Time');
grid on;

%% Plot 3: Energy Density vs Time
figure;
plot(optimized1.time, optimized1.energy_density, 'b--', 'LineWidth', 1.5); hold on;
plot(optimized2.time, optimized2.energy_density, 'r-', 'LineWidth', 1.5); hold on;
plot(wltc.time, wltc.energy_density, 'g-.', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Rolling Energy Density (Wh/km)');
legend('K-Means Clustered NREL', 'K-Means Clustered WLTC', 'WLTC');
title('Energy Density Comparison');
grid on;

%% Plot 4: Fuel Consumption vs Time
figure;
plot(optimized1.time, optimized1.fuel, 'b--', 'LineWidth', 1.5); hold on;
plot(optimized2.time, optimized2.fuel, 'r-', 'LineWidth', 1.5); hold on;
plot(wltc.time, wltc.fuel, 'g-.', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Fuel Consumption (L)');
legend('K-Means Clustered NREL', 'K-Means Clustered WLTC', 'WLTC');
title('Fuel Consumption Over Time');
grid on;
