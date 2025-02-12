local picker = require("color.picker")

local csw = {} -- color_switch

csw.elapsed_time = 0

csw.update_switch_color = function (dt, threshold)
  csw.elapsed_time = csw.elapsed_time + dt
  if csw.elapsed_time >= threshold then
    local tmp = picker.lens_lcolor
    picker.lens_lcolor = picker.lens_rcolor
    picker.lens_rcolor = tmp
    csw.elapsed_time = 0
  end
end

return csw