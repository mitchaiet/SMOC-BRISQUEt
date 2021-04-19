classdef VisualCompressionScore_BRISQUEt < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure       matlab.ui.Figure
        LoadButton     matlab.ui.control.Button
        DropDown       matlab.ui.control.DropDown
        ExamplesLabel  matlab.ui.control.Label
        VisualCompressionScoreEditFieldLabel  matlab.ui.control.Label
        VisualCompressionScoreEditField  matlab.ui.control.NumericEditField
        ImageAxes      matlab.ui.control.UIAxes
        BlueAxes       matlab.ui.control.UIAxes
        GreenAxes      matlab.ui.control.UIAxes
        RedAxes        matlab.ui.control.UIAxes
    end
    
    
    methods (Access = private)
        
        function updateimage(app,imagefile)
            
            % For corn.tif, read the second image in the file
            if strcmp(imagefile,'')
                im = imread('', 2);
            else
                try
                    im = imread(imagefile);
                catch ME
                    % If problem reading image, display error message
                    uialert(app.UIFigure, ME.message, 'Image Error');
                    return;
                end
            end
            
            % Create histograms based on number of color channels
            switch size(im,3)
                case 1
                    % Display the grayscale image
                    imagesc(app.ImageAxes,im);
                    
                    % Plot all histograms with the same data for grayscale
                    histr = histogram(app.RedAxes, im, 'FaceColor',[1 0 0],'EdgeColor', 'none');
                    histg = histogram(app.GreenAxes, im, 'FaceColor',[0 1 0],'EdgeColor', 'none');
                    histb = histogram(app.BlueAxes, im, 'FaceColor',[0 0 1],'EdgeColor', 'none');
                    
                case 3
                    % Display the truecolor image
                    imagesc(app.ImageAxes,im);
                    
                    % Plot the histograms
                    histr = histogram(app.RedAxes, im(:,:,1), 'FaceColor', [1 0 0], 'EdgeColor', 'none');
                    histg = histogram(app.GreenAxes, im(:,:,2), 'FaceColor', [0 1 0], 'EdgeColor', 'none');
                    histb = histogram(app.BlueAxes, im(:,:,3), 'FaceColor', [0 0 1], 'EdgeColor', 'none');
                    
                otherwise
                    % Error when image is not grayscale or truecolor
                    uialert(app.UIFigure, 'Image must be grayscale or truecolor.', 'Image Error');
                    return;
            end
            % Get largest bin count
            maxr = max(histr.BinCounts);
            maxg = max(histg.BinCounts);
            maxb = max(histb.BinCounts);
            maxcount = max([maxr maxg maxb]);
            
            % Set y axes limits based on largest bin count
            app.RedAxes.YLim = [0 maxcount];
            app.RedAxes.YTick = round([0 maxcount/2 maxcount], 2, 'significant');
            app.GreenAxes.YLim = [0 maxcount];
            app.GreenAxes.YTick = round([0 maxcount/2 maxcount], 2, 'significant');
            app.BlueAxes.YLim = [0 maxcount];
            app.BlueAxes.YTick = round([0 maxcount/2 maxcount], 2, 'significant');
            
            % Get Visual Compression Score
            
            % For built-in BRISQUE function:
            % vcs = brisque(im);
            
            % For new BRISQUEt function:
            
              vcs = brisquet(im);
           
            % For pure BRISQUEt score:
            % app.VisualCompressionScoreEditField.Value = vcs;
            
            % To restrict the range of BRISQUEt to 0-100:
        
              vcs_max_min = interp1([-50,100],[0,100],vcs);
              app.VisualCompressionScoreEditField.Value = vcs_max_min;
            
            
        end
    end
    
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Code that executes after component creation
        function startupFcn(app)
            % Configure image axes
            app.ImageAxes.Visible = 'off';
            app.ImageAxes.Colormap = gray(256);
            axis(app.ImageAxes, 'image');
            
            % Update the image and histograms
            updateimage(app, 'hankhill/hankhill3.jpg');
        end
        
        % Value changed function: DropDown
        function DropDownValueChanged(app, event)
            
            % Update the image and histograms
            updateimage(app, app.DropDown.Value);
        end
        
        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            
            % Display uigetfile dialog
            filterspec = {'*.jpg;*.jpeg;*.jfif;*.tif;*.png;*.gif','All Image Files'};
            [f, p] = uigetfile(filterspec);
            
            % Make sure user didn't cancel uigetfile dialog
            if (ischar(p))
                fname = [p f];
                updateimage(app, fname);
            end
        end
    end
    
    % Component initialization
    methods (Access = private)
        
        % Create UIFigure and components
        function createComponents(app)
            
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 702 528];
            app.UIFigure.Name = 'Visual Compression Score';
            app.UIFigure.Resize = 'off';
            
            % Create LoadButton
            app.LoadButton = uibutton(app.UIFigure, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Position = [239 19 225 22];
            app.LoadButton.Text = 'Load Custom Image';
            
            % Create DropDown
            app.DropDown = uidropdown(app.UIFigure);
            app.DropDown.Items = {'Hank Hill - Level 1', 'Hank Hill - Level 2', 'Hank Hill - Level 3', 'Hank Hill - Level 4'};
            app.DropDown.ItemsData = {'hankhill/hankhill1.jpg', 'hankhill/hankhill2.jpg', 'hankhill/hankhill3.jpg', 'hankhill/hankhill4.jpg', ''};
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
            app.DropDown.FontWeight = 'bold';
            app.DropDown.Position = [321 54 140 22];
            app.DropDown.Value = 'hankhill/hankhill3.jpg';
            
            % Create ExamplesLabel
            app.ExamplesLabel = uilabel(app.UIFigure);
            app.ExamplesLabel.HorizontalAlignment = 'right';
            app.ExamplesLabel.Position = [243 54 58 22];
            app.ExamplesLabel.Text = {'Examples'; ''};
            
            % Create VisualCompressionScoreEditFieldLabel
            app.VisualCompressionScoreEditFieldLabel = uilabel(app.UIFigure);
            app.VisualCompressionScoreEditFieldLabel.HorizontalAlignment = 'center';
            app.VisualCompressionScoreEditFieldLabel.FontName = 'Dubai';
            app.VisualCompressionScoreEditFieldLabel.FontSize = 20;
            app.VisualCompressionScoreEditFieldLabel.FontWeight = 'bold';
            app.VisualCompressionScoreEditFieldLabel.Position = [179 136 350 51];
            app.VisualCompressionScoreEditFieldLabel.Text = {'Visual Compression Score (BRISQUEt)'; ''};
            
            % Create VisualCompressionScoreEditField
            app.VisualCompressionScoreEditField = uieditfield(app.UIFigure, 'numeric');
            app.VisualCompressionScoreEditField.ValueDisplayFormat = '%.4f';
            app.VisualCompressionScoreEditField.HorizontalAlignment = 'center';
            app.VisualCompressionScoreEditField.FontName = 'Dubai';
            app.VisualCompressionScoreEditField.FontSize = 20;
            app.VisualCompressionScoreEditField.FontWeight = 'bold';
            app.VisualCompressionScoreEditField.Position = [288 93 133 36];
            
            % Create ImageAxes
            app.ImageAxes = uiaxes(app.UIFigure);
            app.ImageAxes.XTick = [];
            app.ImageAxes.XTickLabel = {'[ ]'};
            app.ImageAxes.YTick = [];
            app.ImageAxes.Position = [173 170 357 305];
            
            % Create BlueAxes
            app.BlueAxes = uiaxes(app.UIFigure);
            title(app.BlueAxes, 'Blue')
            xlabel(app.BlueAxes, 'Intensity')
            ylabel(app.BlueAxes, 'Pixels')
            app.BlueAxes.XLim = [0 255];
            app.BlueAxes.XTick = [0 128 255];
            app.BlueAxes.Visible = 'off';
            app.BlueAxes.Position = [663 19 10 10];
            
            % Create GreenAxes
            app.GreenAxes = uiaxes(app.UIFigure);
            title(app.GreenAxes, 'Green')
            xlabel(app.GreenAxes, 'Intensity')
            ylabel(app.GreenAxes, 'Pixels')
            app.GreenAxes.XLim = [0 255];
            app.GreenAxes.XTick = [0 128 255];
            app.GreenAxes.Visible = 'off';
            app.GreenAxes.Position = [663 25 10 10];
            
            % Create RedAxes
            app.RedAxes = uiaxes(app.UIFigure);
            title(app.RedAxes, 'Red')
            xlabel(app.RedAxes, 'Intensity')
            ylabel(app.RedAxes, 'Pixels')
            app.RedAxes.XLim = [0 255];
            app.RedAxes.XTick = [0 128 255];
            app.RedAxes.Visible = 'off';
            app.RedAxes.Position = [663 19 10 10];
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = VisualCompressionScore_BRISQUEt
            
            % Create UIFigure and components
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            
            % Execute the startup function
            runStartupFcn(app, @startupFcn)
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end