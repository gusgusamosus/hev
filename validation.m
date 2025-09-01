% Load optimized driving cycle
opt_data = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\optimized_cycle.csv");
optimized = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\optimized_wltc.csv");

% Define Urban Driving Cycle (from res3.pdf), approximate data (time in sec, speed in km/h)
urban_time = [0 10 20 30 40 50 60 70 80 90 100 110 120];
urban_speed = [0 15 25 30 35 40 45 40 35 25 15 5 0];

% Interpolate to 1-second resolution
urban_time_dense = (0:1:120)';
urban_speed_interp = interp1(urban_time, urban_speed, urban_time_dense);

% Compute acceleration (approximate)
urban_accel = [0; diff(urban_speed_interp)];

% Truncate optimized cycle to 121 seconds for fair comparison
opt_trunc = opt_data(1:min(length(urban_time_dense), height(opt_data)), :);
optimized_trunc = optimized(1:min(length(urban_time_dense), height(optimized)), :);

%% Plot: Speed Comparison
figure;
plot(opt_trunc.time, opt_trunc.speed, 'b', 'LineWidth', 1.5); hold on;
plot(optimized_trunc.time, optimized_trunc.speed, 'g-', 'LineWidth', 1.5);
plot(urban_time_dense, urban_speed_interp, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Speed (km/h)');
title('Speed Comparison: K-Means Clustered vs Urban Cycle');
legend('K-Means Clustered NREL', 'K-Means Clustered WLTC', 'Urban Driving Cycle');
grid on;

%% Plot: Acceleration Comparison
figure;
plot(opt_trunc.time, opt_trunc.accel, 'b', 'LineWidth', 1.5); hold on;
plot(optimized_trunc.time, optimized_trunc.accel, 'g-', 'LineWidth', 1.5);
plot(urban_time_dense, urban_accel, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');
title('Acceleration Comparison: K-Means Clustered vs Urban Cycle');
legend('K-Means Clustered NREL', 'K-Means Clustered WLTC', 'Urban Driving Cycle');
grid on;

%% Compute and display error metrics (Speed)
urban_speed_interp = urban_speed_interp(1:height(opt_trunc));
speed_error = opt_trunc.speed - urban_speed_interp;
mae_speed = mean(abs(speed_error));
rmse_speed = sqrt(mean(speed_error.^2));

fprintf("MAE of Urban Cycle (Interpolated): %.2f km/h\n", mae_speed);
fprintf("RMSE of Urban Cycle (Interpolated): %.2f km/h\n", rmse_speed);