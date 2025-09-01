%% compare_driving_cycles.m
% Compare K-Means Clustered NREL and WLTC

%% Load Cycle Data
optimized = readtable("C:\Users\srich\OneDrive\Desktop\Sem 6\Hybrid and EV Vehicles\DA\optimized_cycle.csv");
wltc = readtable("C:\Users\srich\OneDrive\Desktop\Sem 6\Hybrid and EV Vehicles\DA\wltc.csv");

% Create reference line over time
t_ref = optimized.time;

%% Plot 1: Speed vs Time
figure;
plot(optimized.time, optimized.speed, 'r-', 'LineWidth', 1.5); hold on;
plot(wltc.time, wltc.speed, 'g-.', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Speed (km/h)');
legend('K-Means Clustered NREL', 'WLTC');
title('Speed vs Time Comparison');
grid on;

%% Plot 2: Acceleration vs Time
figure;
plot(optimized.time, optimized.accel, 'r-', 'LineWidth', 1.5); hold on;
plot(wltc.time, wltc.accel, 'g-.', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Acceleration (m/s^2)');
legend('K-Means Clustered NREL', 'WLTC');
title('Acceleration vs Time');
grid on;

%% Plot 3: Energy Density vs Time
figure;
plot(optimized.time, optimized.energy_density, 'r-', 'LineWidth', 1.5); hold on;
plot(wltc.time, wltc.energy_density, 'g-.', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Rolling Energy Density (Wh/km)');
legend('K-Means Clustered NREL', 'WLTC');
title('Energy Density Comparison');
grid on;

%% Plot 4: Fuel Consumption vs Time
figure;
plot(optimized.time, optimized.fuel, 'r-', 'LineWidth', 1.5); hold on;
plot(wltc.time, wltc.fuel, 'g-.', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Fuel Consumption (L)');
legend('K-Means Clustered NREL', 'WLTC');
title('Fuel Consumption Over Time');
grid on;
