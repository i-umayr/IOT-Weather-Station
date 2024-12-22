% Read temperature data
readChannelID = 2792954;
tempData = thingSpeakRead(readChannelID, 'Field', 1, 'NumPoints', 30);

% Remove any NaN values
tempData = rmmissing(tempData);

% Calculate moving average for prediction
window = 3;
temp_prediction = movmean(tempData, window);

% Create plot
subplot(2,1,1);
plot(tempData, 'b-', 'LineWidth', 2);
hold on;
plot(temp_prediction, 'r--', 'LineWidth', 1.5);
title('Temperature Analysis and Prediction');
xlabel('Reading Number');
ylabel('Temperature (°C)');
legend('Actual', 'Moving Average');
grid on;
hold off;

% Add trend analysis
subplot(2,1,2);
temp_diff = diff(tempData);
bar(temp_diff);
title('Temperature Change Rate');
xlabel('Reading Number');
ylabel('Rate of Change (°C/reading)');
grid on;