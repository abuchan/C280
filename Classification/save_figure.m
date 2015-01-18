function save_figure( figure, name, height, width )

FIGURES_DIR = 'figures';

% Format figure to specified size
set(figure,'Units','inches');
set(figure,'Position', [1 1 width height]);
set(figure,'PaperPositionMode','auto');
%set(figure,'Units','normalized','Position',[0.15 0.2 0.75 0.7]);
% Find the current directory
s = dbstack('-completenames');
path = s.file;
delim = '\';
lastslash = max(findstr(path,delim));
if isempty(lastslash)
    delim = '/';
    lastslash = max(findstr(path,delim));
end
path = path(1:lastslash);

% Save file
%saveas(figure,[path FIGURES_DIR delim name],'eps');
print(figure,'-dpng','-r300',[path FIGURES_DIR delim name]);
%print(figure,'-depsc2','-painters',[path FIGURES_DIR delim name]);
end

