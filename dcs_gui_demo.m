% dcs_gui_demo.m
% =========================================
% GUI + Live SNR Control for DCS Project
% Combines all your existing scripts interactively.
% =========================================

function dcs_gui_demo
    % Create GUI window
    fig = uifigure('Name','DCS Live Demo','Position',[400 200 500 400]);

    % Title label
    uilabel(fig, 'Text', 'Digital Communication System - Live Demo', ...
        'FontSize', 16, 'FontWeight','bold', 'Position',[50 340 400 30]);

    % SNR slider label
    uilabel(fig, 'Text', 'Channel SNR (dB):', ...
        'FontSize', 13, 'Position',[80 270 120 30]);

    % SNR slider (5–30 dB)
    sld = uislider(fig, 'Position',[210 285 200 3], ...
        'Limits',[5 30], 'Value',20, ...
        'MajorTicks',5:5:30, 'ValueChangedFcn',@(sld,event)updateSNR(sld));

    % Display SNR value
    snrLabel = uilabel(fig, 'Text','20 dB','FontSize',13,'Position',[420 270 60 30]);

    % Buttons
    uibutton(fig,'Text','Run Downlink Demo','FontSize',13,...
        'Position',[150 200 200 40],...
        'ButtonPushedFcn',@(btn,event)runDownlink(sld));

    uibutton(fig,'Text','Run MIMO-OFDM','FontSize',13,...
        'Position',[150 140 200 40],...
        'ButtonPushedFcn',@(btn,event)runMIMO);

    uibutton(fig,'Text','Compare Methods','FontSize',13,...
        'Position',[150 80 200 40],...
        'ButtonPushedFcn',@(btn,event)runCompare);

    uibutton(fig,'Text','Exit','FontSize',13,...
        'Position',[150 20 200 40],...
        'ButtonPushedFcn',@(btn,event)close(fig));

    % --- Nested functions for callbacks ---
    function updateSNR(sld)
        snrVal = round(sld.Value);
        snrLabel.Text = sprintf('%d dB', snrVal);
    end

    function runDownlink(sld)
        snrVal = round(sld.Value);
        fprintf('\n>>> Running Downlink Demo at %d dB SNR...\n', snrVal);
        dcs_downlink_live_demo_customSNR(snrVal);
    end

    function runMIMO(~)
        fprintf('\n>>> Running MIMO-OFDM Simulation...\n');
        main_mimo_ofdm;
    end

    function runCompare(~)
        fprintf('\n>>> Running BER Comparison...\n');
        evalin('base','comparison_methods');

    end
end
