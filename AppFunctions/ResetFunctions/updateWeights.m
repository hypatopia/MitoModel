function updateWeights(app, event)
    % This function updates the WeightsVector when the user edits the table.

    % Get the edited data
    editedData = event.EditData;

    % Get the row and column indices of the edited cell
    editedRow = event.Indices(1);
    editedColumn = event.Indices(2);

    % Ensure the edited column is the weights column (Column 2)
    if editedColumn == 2
        % Convert edited data to double (assuming weights are numeric)
        newWeight = str2double(editedData);

        % Check if the conversion was successful
        if isnan(newWeight)
            % Display an error or handle invalid input
            errordlg('Please enter a valid number for the weight.', 'Invalid Input', 'modal');
        else
            % Update the weights vector
            app.WeightsVector(editedRow) = newWeight;
        end
    end
end