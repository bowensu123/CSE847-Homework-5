close all;
clear all;
clc;
% Given data points
data_points = [0, 0; -1, 2; -3, 6; 1, -2; 3, -6];

% Plot the data points
figure;
plot(data_points(:,1), data_points(:,2), 'bo');
title('2D Plot of Given Data Points');
xlabel('X Coordinate');
ylabel('Y Coordinate');
grid on;
axis equal;



% Load the dataset
load('/MATLAB Drive/cse847/USPS.mat');
originalData = A; % Each row in A corresponds to an image

% Perform mean-centering on the data
dataMean = mean(originalData, 1);
dataCentered = bsxfun(@minus, originalData, dataMean);

% Perform SVD on mean-centered data
[U, S, V] = svd(dataCentered, 'econ');

% Reconstruct images using different numbers of principal components and calculate error
numComponents = [10, 50, 100, 200];
errors = zeros(length(numComponents), 1);
for i = 1:length(numComponents)
    [reconstructedData, errors(i)] = reconstruct_images(U, S, V, dataMean, numComponents(i), originalData);
    
    % Visualize the first two images for the current number of components
    fig = figure('Name', ['Reconstructed Images with ', num2str(numComponents(i)), ' Components'], 'Visible', 'off');
    for imgIndex = 1:2
        subplot(1, 2, imgIndex);
        imgMatrix = reshape(reconstructedData(imgIndex, :), 16, 16)';
        imshow(imgMatrix, []);
        title(['Image ', num2str(imgIndex)]);
    end
    
    % Save the figure without white space
    set(fig,'InvertHardcopy','off');
    set(fig,'Color','none');
    ax = gca;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset; 
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];

    print(fig, ['Reconstructed_Image_', num2str(numComponents(i))], '-dpng', '-r300');
end

% Display total reconstruction error for different numbers of principal components
disp('Total Reconstruction Error:');
disp(array2table(errors, 'VariableNames', {'Error'}, 'RowNames', {'p=10', 'p=50', 'p=100', 'p=200'}));

% Function to reconstruct images using different numbers of principal components
function [reconstructedData, error] = reconstruct_images(U, S, V, dataMean, numComponents, originalData)
    reconstructedData = U(:, 1:numComponents) * S(1:numComponents, 1:numComponents) * V(:, 1:numComponents)' ...
                        + repmat(dataMean, size(U, 1), 1);
    % Total reconstruction error
    error = sum(sum((originalData - reconstructedData).^2)); 
end