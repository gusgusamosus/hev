% Load your optimized cycle
opt_data = readtable("C:\Users\srich\OneDrive\Desktop\Projects\HEV\optimized_cycle.csv");

% Create reference timeseries for inputs
ts_speed = timeseries(opt_data.speed, opt_data.time);
ts_accel = timeseries(opt_data.accel, opt_data.time);
ts_ed    = timeseries(opt_data.energy_density, opt_data.time);

% Load simulation output
load("out.mat");  % assumes variable 'out' of type Simulink.SimulationOutput

% Extract signals directly (assuming they were logged using To Workspace blocks)
sim_speed  = out.output_speed;     % timeseries
sim_accel  = out.output_accel;     % timeseries
sim_energy = out.energy_used;      % timeseries (cumulative in Joules)

%% Speed Analysis
ref_speed = interp1(ts_speed.Time, ts_speed.Data, sim_speed.Time);
sim_speed_vals = sim_speed.Data;
speed_error = sim_speed_vals - ref_speed;

mae_speed = mean(abs(speed_error));
rmse_speed = sqrt(mean(speed_error.^2));

fprintf("Speed MAE:  %.2f km/h\n", mae_speed);
fprintf("Speed RMSE: %.2f km/h\n", rmse_speed);

% Plot Speed
figure;
plot(sim_speed.Time, sim_speed_vals, 'b', 'LineWidth', 1.5); hold on;
plot(sim_speed.Time, ref_speed, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Speed (km/h)');
title('Simulated vs Target Speed');
legend('Simulated', 'Target');
grid on;

%% Acceleration Analysis
ref_accel = interp1(ts_accel.Time, ts_accel.Data, sim_accel.Time);
sim_accel_vals = sim_accel.Data;
accel_error = sim_accel_vals - ref_accel;

mae_accel = mean(abs(accel_error));
rmse_accel = sqrt(mean(accel_error.^2));

fprintf("Acceleration MAE:  %.3f m/s²\n", mae_accel);
fprintf("Acceleration RMSE: %.3f m/s²\n", rmse_accel);

% Plot Acceleration
figure;
plot(sim_accel.Time, sim_accel_vals, 'b', 'LineWidth', 1.5); hold on;
plot(sim_accel.Time, ref_accel, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Acceleration (m/s²)');
title('Simulated vs Target Acceleration');
legend('Simulated', 'Target');
grid on;

%% Energy Analysis
if ~isempty(sim_energy)
    % Convert simulated cumulative energy from J to Wh
    sim_energy_vals = sim_energy.Data / 3600;  % in Wh
    sim_energy_time = sim_energy.Time;

    % Interpolate reference energy density to match time base
    ref_energy_vals = interp1(ts_ed.Time, ts_ed.Data, sim_energy_time);

    % Calculate error
    energy_error = sim_energy_vals - ref_energy_vals;
    mae_energy = mean(abs(energy_error));
    rmse_energy = sqrt(mean(energy_error.^2));

    fprintf("Energy MAE:  %.2f Wh\n", mae_energy);
    fprintf("Energy RMSE: %.2f Wh\n", rmse_energy);

    % Plot Energy Comparison
    figure;
    plot(sim_energy_time, sim_energy_vals, 'b', 'LineWidth', 1.5); hold on;
    plot(sim_energy_time, ref_energy_vals, 'g--', 'LineWidth', 1.5);
    xlabel('Time (s)');
    ylabel('Energy (Wh)');
    title('Simulated vs Reference Energy Consumption');
    legend('Simulated', 'Reference');
    grid on;
else
    warning("Energy signal not found in simulation output.");
end