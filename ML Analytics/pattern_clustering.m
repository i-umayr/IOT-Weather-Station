% Read multiple parameters
readChannelID = 2792954;
tempData = thingSpeakRead(readChannelID, 'Field', 1, 'NumPoints', 30);
humidData = thingSpeakRead(readChannelID, 'Field', 2, 'NumPoints', 30);
pressData = thingSpeakRead(readChannelID, 'Field', 3, 'NumPoints', 30);

% Remove any NaN values
valid = ~isnan(tempData) & ~isnan(humidData) & ~isnan(pressData);
tempData = tempData(valid);
humidData = humidData(valid);
pressData = pressData(valid);

% Prepare data for clustering
X = [tempData, humidData, pressData];
X_norm = normalize(X, 'range');  % Range normalization instead of z-score

% Perform k-means clustering
k = 2;  % Reduced to 2 clusters for simplicity
[idx, centroids] = kmeans(X_norm, k);

% Plot clusters
subplot(2,1,1);
scatter3(tempData, humidData, pressData, 50, idx, 'filled');
title('Weather Patterns');
xlabel('Temperature (°C)');
ylabel('Humidity (%)');
zlabel('Pressure (mbar)');
grid on;

% Plot pattern changes over time
subplot(2,1,2);
plot(1:length(idx), idx, 'bo-', 'LineWidth', 2);
title('Weather Pattern Changes');
ylabel('Pattern Type');
xlabel('Time Points');
ylim([0.5, 2.5]);
grid on;