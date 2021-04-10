function accuracy = testNetwork(net, data, labels)

    % Test the network performance on test set
    %
    %   net     The network
    %   data    The test data set
    %   labels  Labels for the test set
    %-------------------------------
    
    prediction = classify(net, data);
    accuracy = sum(prediction == categorical(labels))/numel(categorical(labels));
end