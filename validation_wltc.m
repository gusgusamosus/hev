% Load optimized driving cycle
opt_data = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\wltc.csv");
optimized1 = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\optimized_wltc.csv");
optimized = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\optimized_cycle.csv");

% Define Urban Driving Cycle (from res3.pdf), approximate data (time in sec, speed in km/h)
urban_time = [0 10 20 30 40 50 60 70 80 90 100 110 120];
urban_speed = [0 15 25 30 35 40 45 40 35 25 15 5 0];

% Interpolate to 1-second resolution
urban_time_dense = (0:1:120)';
urban_speed_interp = interp1(urban_time, urban_speed, urban_time_dense);

% Compute acceleration (approximate)
urban_accel = [0; diff(urban_speed_interp)];

% Truncate optimized cycle to 121 seconds for fair comparison
opt_trunc1 = opt_data(1:min(length(urban_time_dense), height(opt_data)), :);
optimized_trunc1 = optimized1(1:min(length(urban_time_dense), height(optimized1)), :);

opt_trunc = opt_data(1:min(length(urban_time_dense), height(opt_data)), :);
optimized_trunc = optimized(1:min(length(urban_time_dense), height(optimized)), :);

%% Plot: Speed Comparison
figure;
plot(opt_trunc1.time, opt_trunc1.speed, 'b', 'LineWidth', 1.5); hold on;
plot(optimized_trunc1.time, optimized_trunc1.speed, 'g', 'LineWidth', 1.5);
plot(opt_trunc.time, opt_trunc.speed, 'y-', 'LineWidth', 1.5); hold on;
plot(optimized_trunc.time, optimized_trunc.speed, 'p-', 'LineWidth', 1.5);
plot(urban_time_dense, urban_speed_interp, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Speed (km/h)');
title('Speed Comparison');
legend('K-Means Clustered NREL', 'WLTC', 'K-Means Clustered WLTC', 'Urban Driving Cycle');
grid on;

%% Plot: Acceleration Comparison
figure;
plot(opt_trunc1.time, opt_trunc1.accel, 'b', 'LineWidth', 1.5); hold on;
plot(optimized_trunc1.time, optimized_trunc1.accel, 'g', 'LineWidth', 1.5);
plot(opt_trunc.time, opt_trunc.accel, 'y-', 'LineWidth', 1.5); hold on;
plot(optimized_trunc.time, optimized_trunc.accel, 'p-', 'LineWidth', 1.5);
plot(urban_time_dense, urban_speed_interp, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
title('Acceleration Comparison');
legend('K-Means Clustered NREL', 'WLTC', 'K-Means Clustered WLTC', 'Urban Driving Cycle');
grid on;

%% Compute and display error metrics (Speed)
urban_speed_interp = urban_speed_interp(1:height(opt_trunc1));
speed_error1 = opt_trunc1.speed - urban_speed_interp;
mae_speed1 = mean(abs(speed_error1));
rmse_speed1 = sqrt(mean(speed_error1.^2));

fprintf("Speed MAE: %.2f km/h\n", mae_speed1);
fprintf("Speed RMSE: %.2f km/h\n", rmse_speed1);

speed_error = opt_trunc.speed - urban_speed_interp;
mae_speed = mean(abs(speed_error));
rmse_speed = sqrt(mean(speed_error.^2));

fprintf("Speed MAE: %.2f km/h\n", mae_speed);
fprintf("Speed RMSE: %.2f km/h\n", rmse_speed);