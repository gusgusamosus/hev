%% statistical_validation.m
% Compares K-Means Clustered WLTC vs WLTC

%% Load Real Trip Reference
optimized1 = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\optimized_cycle.csv");
optimized2 = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\optimized_wltc.csv");
wltc = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\wltc.csv");

% Create flat-line series for fair comparison
t2 = optimized2.time;
t1 = optimized1.time;

%% MAE vs Real Trip Average
opt_avg_speed2 = mean(optimized2.speed);
mae_speed_wltc2 = abs(opt_avg_speed2 - mean(wltc.speed));
fprintf('MAE vs WLTC (Speed): %.2f km/h\n', mae_speed_wltc2);

opt_avg_speed1 = mean(optimized1.speed);
mae_speed_wltc1 = abs(opt_avg_speed1 - mean(wltc.speed));
fprintf('MAE vs NREL (Speed): %.2f km/h\n', mae_speed_wltc1);

%% Correlation Coefficients
speed_corr_wltc2 = corr(optimized2.speed, wltc.speed(1:length(t2)), 'Rows', 'complete');
accel_corr_wltc2 = corr(optimized2.accel, wltc.accel(1:length(t2)), 'Rows', 'complete');

fprintf('\nCorrelation with WLTC: Speed = %.2f | Accel = %.2f\n', speed_corr_wltc2, accel_corr_wltc2);

speed_corr_wltc1 = corr(optimized1.speed, wltc.speed(1:length(t1)), 'Rows', 'complete');
accel_corr_wltc1 = corr(optimized1.accel, wltc.accel(1:length(t1)), 'Rows', 'complete');

fprintf('\nCorrelation with NREL: Speed = %.2f | Accel = %.2f\n', speed_corr_wltc1, accel_corr_wltc1);

%% Boxplots for Energy
figure;
boxplot([optimized1.energy_density, optimized2.energy_density, wltc.energy_density(1:length(t2))], ...
    'Labels', {'K-Means Clustered NREL','K-Means Clustered WLTC','WLTC'});
ylabel('Rolling Energy Density (Wh/km)');
title('Energy Density Comparison (Boxplot)');

%% Histograms of Acceleration
figure;
histogram(optimized1.accel, 'FaceColor','b'); hold on;
histogram(optimized2.accel, 'FaceColor','r'); hold on;
histogram(wltc.accel, 'FaceColor','g');
legend('K-Means Clustered NREL','K-Means Clustered WLTC','WLTC','Real Avg');
xlabel('Acceleration (m/s^2)');
title('Acceleration Distribution');

%% Regression Setup (Fuel Prediction)
inputs = {'speed', 'accel', 'energy_density'};

% K-Means Clustered WLTC
opt_input1 = optimized1(:, inputs);
opt_target1 = optimized1.fuel;

opt_input2 = optimized2(:, inputs);
opt_target2 = optimized2.fuel;

% WLTC
wltc_input = wltc(:, inputs);
wltc_target = wltc.fuel;

%% Regression Models
fprintf('\n--- REGRESSION: WLTC ---\n');
mdl_wltc = fitlm(wltc_input, wltc_target);
fprintf('R²: %.2f\n', mdl_wltc.Rsquared.Ordinary);

fprintf('\n--- REGRESSION: K-Means Clustered WLTC ---\n');
mdl_opt2 = fitlm(opt_input2, opt_target2);
fprintf('R²: %.2f\n', mdl_opt2.Rsquared.Ordinary);

fprintf('\n--- REGRESSION: K-Means Clustered NREL ---\n');
mdl_opt1 = fitlm(opt_input1, opt_target1);
fprintf('R²: %.2f\n', mdl_opt1.Rsquared.Ordinary);

%% Predicted vs Actual Fuel
figure;
subplot(1,3,1);
plot(wltc_target, predict(mdl_wltc, wltc_input), 'go');
title('WLTC'); xlabel('Actual Fuel'); ylabel('Predicted'); grid on; refline(1,0);

subplot(1,3,2);
plot(opt_target2, predict(mdl_opt2, opt_input2), 'ro');
title('K-Means Clustered WLTC'); xlabel('Actual Fuel'); ylabel('Predicted'); grid on; refline(1,0);

subplot(1,3,3);
plot(opt_target1, predict(mdl_opt1, opt_input1), 'ro');
title('K-Means Clustered NREL'); xlabel('Actual Fuel'); ylabel('Predicted'); grid on; refline(1,0);