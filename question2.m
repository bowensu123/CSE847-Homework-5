close all;
clear all;
clc;
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
    figure('Name', ['Reconstructed Images with ', num2str(numComponents(i)), ' Components']);
    for imgIndex = 1:2
        subplot(1, 2, imgIndex);
        imgMatrix = reshape(reconstructedData(imgIndex, :), 16, 16)';
        imshow(imgMatrix, []);
        title(['Image ', num2str(imgIndex)]);
    end
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
