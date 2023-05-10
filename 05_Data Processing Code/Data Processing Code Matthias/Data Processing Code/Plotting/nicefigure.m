function nicefigure(purpose)

set(gcf, 'Units','inches');    
pos = get(gcf,'Position');

switch purpose
    case 'thesis'
        set(gca, 'FontName','Arial','FontSize',11,...
            'LabelFontSizeMultiplier',1,'TitleFontSizeMultiplier',1,...
            'XGrid','on','YGrid','on','GridColor',[0 0 0]);
        % [left bottom width height]
        set(gcf, 'Units','inches','Position',[pos(1:2), 6.5, 4.5]);
                title('')
    case 'thesis_2_per_page'
        set(gca, 'FontName','Arial','FontSize',11,...
            'LabelFontSizeMultiplier',1,'TitleFontSizeMultiplier',1,...
            'XGrid','on','YGrid','on','GridColor',[0 0 0]);
        % [left bottom width height]
        set(gcf, 'Units','inches','Position',[pos(1:2), 6.5, 4]);
                title('')

     case 'thesis_half'
        set(gca, 'FontName','Arial','FontSize',11,...
            'LabelFontSizeMultiplier',1,'TitleFontSizeMultiplier',1,...
            'XGrid','on','YGrid','on','GridColor',[0 0 0]);
        % [left bottom width height]
        set(gcf, 'Units','inches','Position',[pos(1:2), 6.5/2, 4.5/2]);
                title('')
     case 'thesis_half_tall'
        set(gca, 'FontName','Arial','FontSize',11,...
            'LabelFontSizeMultiplier',1,'TitleFontSizeMultiplier',1,...
            'XGrid','on','YGrid','on','GridColor',[0 0 0]);
        % [left bottom width height]
        set(gcf, 'Units','inches','Position',[pos(1:2), 6.5/2, 4]); % 4.5
                title('')
     case 'thesis_half_small'
        set(gca, 'FontName','Arial','FontSize',11,...
            'LabelFontSizeMultiplier',1,'TitleFontSizeMultiplier',1,...
            'XGrid','on','YGrid','on','GridColor',[0 0 0]);
        % [left bottom width height]
        set(gcf, 'Units','inches','Position',[pos(1:2), 6.5/2, 3]); % 4.5
                title('')         

      case 'thesis_small'
        set(gca, 'FontName','Arial','FontSize',11,...
            'LabelFontSizeMultiplier',1,'TitleFontSizeMultiplier',1,...
            'XGrid','on','YGrid','on','GridColor',[0 0 0]);
        % [left bottom width height]
        set(gcf, 'Units','inches','Position',[pos(1:2), 4.5, 3]);
                title('')
       case 'thesis_small_wide'
        set(gca, 'FontName','Arial','FontSize',11,...
            'LabelFontSizeMultiplier',1,'TitleFontSizeMultiplier',1,...
            'XGrid','on','YGrid','on','GridColor',[0 0 0]);
        % [left bottom width height]
        set(gcf, 'Units','inches','Position',[pos(1:2), 6.5, 3]);
                title('')
     
    case 'paper'
        set(gca, 'FontName','Times New Roman','FontSize',10,...
            'LabelFontSizeMultiplier',1,'TitleFontSizeMultiplier',1,...
            'XGrid','on','YGrid','on','GridColor',[0 0 0]);
        % [left bottom width height]
        set(gcf, 'Units','inches','Position',[pos(1:2), 3.5, 2.5]);
        title('')
        
    case 'presentation'
        set(gca, 'FontName','Times New Roman','FontSize',10,...
            'LabelFontSizeMultiplier',1,'TitleFontSizeMultiplier',1,...
            'XGrid','on','YGrid','on','GridColor',[0 0 0]);
        % [left bottom width height]
        set(gcf, 'Units','inches','Position',[pos(1:2), 4.75, 4]);
        
         case 'presentation_x2'
        set(gca, 'FontName','Times New Roman','FontSize',20,...
            'LabelFontSizeMultiplier',1,'TitleFontSizeMultiplier',1,...
            'XGrid','on','YGrid','on','GridColor',[0 0 0]);
        % [left bottom width height]
        set(gcf, 'Units','inches','Position',[pos(1:2), 4.75*2, 4*2]);
   
end
