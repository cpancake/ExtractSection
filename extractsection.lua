--[[
	Extract Section extension for VLC >= 2.0.0
	Authors: Andrew Rogers (http://cpancake.github.io/)
--]]

local dlg = nil
local old_bitrate = nil
local old_sub = nil
local old_include_subs = nil
local sub_input = nil
local bitrate = nil
local include_subs = nil

function descriptor()
	return {
		title = "Extract Section",
		version = "0.1",
		author = "Andrew Rogers",
		capabilities = {}
	}
end

function activate()
	if not vlc.input.item() then
		show_alert("No video playing.")
		return
	end

	local input = vlc.object.input()
	local time = vlc.var.get(input, "time")
	local length_input = nil
	local log = nil

	local subtitle_file = remove_extension(uri_to_file(vlc.input.item():uri())) .. ".srt"

	dlg = vlc.dialog("Extract Section")
	dlg:add_label("Start Time", 1, 1, 1, 1)
	dlg:add_label(os.date("!%X", time), 2, 1, 4, 1)
	dlg:add_label("Clip Length", 1, 2, 1, 1)
	length_input = dlg:add_text_input("00:00:15", 2, 2, 1, 1)
	--[[dlg:add_label("Include Subtitles", 1, 3, 1, 1)
	include_subs = dlg:add_dropdown(2, 3, 1, 1)
	if old_include_subs == false then
		include_subs:add_value("No", 2)
		include_subs:add_value("Yes", 1)
	else
		include_subs:add_value("Yes", 1)
		include_subs:add_value("No", 2)
	end]]
	--dlg:add_label("Subtitle File", 1, 4, 1, 1)
	--sub_input = dlg:add_text_input(old_sub or subtitle_file, 2, 4, 1, 1)
	dlg:add_label("Video Bitrate", 1, 3, 1, 1)
	bitrate = dlg:add_text_input(old_bitrate or "1M", 2, 3, 1, 1)
	dlg:add_label("Additional Parameters", 1, 4, 1, 1)
	local extra_parameters = dlg:add_text_input("", 2, 4, 1, 1)
	log = dlg:add_list(1, 5, 2, 1)
	dlg:add_button("Start", function() 
		local file = uri_to_file(vlc.input.item():uri())
		local query = "ffmpeg"
		query = query .. " -ss " .. seconds_to_ffmpeg_time(time)
		query = query .. " -i \"" .. file .. "\""
		query = query .. " -c:v libvpx "
		query = query .. " -b:v " .. bitrate:get_text()
		query = query .. " -c:a libvorbis"
		query = query .. " -t " .. length_input:get_text()
		query = query .. " " .. extra_parameters:get_text()
		local file_name = get_directory_from_path(file)
		file_name = file_name .. create_output_name(file, seconds_to_ffmpeg_time(time), length_input:get_text())
		query = query .. " \"" .. file_name .. "\""
		log:add_value("Running " .. query, 1)
		local value = os.execute(query)
		log:add_value("Return value: " .. value, 2)
		log:update()
	end, 1, 6, 1, 1)

	dlg:show()
end

function seconds_to_ffmpeg_time(time)
    hours = math.floor(time / 3600)
    time = time - (hours * 3600)
    minutes = math.floor(time / 60)
    time = time - (minutes * 60)
    seconds = time
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function uri_to_file(uri)
	uri = url_decode(uri)
	if string.sub(uri, 0, 4) == 'file' then
		return string.sub(uri, 9)
	end
	return uri
end

function url_decode(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end

function string_split(self, sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function get_file_name_from_path(path)
	parts = string_split(path, "/")
	return parts[#parts]
end

function get_directory_from_path(str)
    return str:match("(.*/)")
end

function remove_extension(file)
	parts = string_split(file, ".")
	table.remove(parts, #parts)
	return table.concat(parts, ".")
end

function create_output_name(path, start, duration)
	local file_name = remove_extension(get_file_name_from_path(path))
	file_name = file_name .. "-"
	file_name = file_name .. table.concat(string_split(start, ":"), "_")
	file_name = file_name .. "-"
	file_name = file_name .. table.concat(string_split(duration, ":"), "_")
	return file_name .. ".webm"
end

function show_alert(msg)
	alert_dialog = vlc.dialog("Extract Section - Dialog")
	alert_dialog:add_label(msg, 1, 1, 1, 1)
	alert_dialog:add_button("Close", function()
		vlc.deactivate()
		alert_dialog:delete()
	end)
end

function save_values()
	old_bitrate = bitrate:get_text()
	old_sub = sub_input:get_text()
	old_include_subs = include_subs:get_value() == 2
end

function deactivate() 
end

function close()
	vlc.deactivate()
end 