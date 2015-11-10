
function [width, height] =nbt_getScreenSize()
hh =java.awt.Toolkit.getDefaultToolkit().getScreenSize;
width = hh.width;
height = hh.height;
end