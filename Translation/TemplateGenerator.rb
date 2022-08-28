ROOT_DIRECTORY = "."
OUTPUT_PATH = "./Translation/en.pot"
EXCLUDE_DIRECTORIES = [".import", ".git"]
EXCLUDE_STRINGS = ["", "...", "x1", "Image name", "Group name", "Multiline image info", "Multiline general info", ">>>", "<<<"]
FILE_HEADER = '
msgid ""
msgstr ""
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
'

dir_stack = [ROOT_DIRECTORY]
visited_dirs = []
strings = []

while !dir_stack.empty?
    dir = dir_stack.pop
    entries = Dir.entries(dir) - [".", ".."]

    entries.each do |entry|
        next if EXCLUDE_DIRECTORIES.include?(entry)
        full_path = File.join(dir, entry)
        
        if Dir.exist?(full_path) and !visited_dirs.include?(full_path)
            visited_dirs << full_path
            dir_stack << full_path
            next
        end

        if File.extname(entry) == ".gd"
            File.readlines(full_path).each do |line|
                strings.concat line.scan(/[^s]tr\("([^()]*)"\)/).flatten
                strings.concat line.scan(/add_customization\("([^()]*)"\)/).flatten
                strings.concat line.scan(/add_info\("([^()]*)"\)/).flatten
                strings.concat line.scan(/add_image_info\("([^()]*)"\)/).flatten
                strings.concat line.scan(/add_image_info\("([^()]*)", \[/).flatten
            end
        elsif File.extname(entry) == ".tscn"
            File.readlines(full_path).each do |line|
                strings.concat line.scan(/text = "([^\"]*)"/).flatten
                strings.concat line.scan(/hint_tooltip = "([^()]*)"/).flatten
                strings.concat line.scan(/placeholder_text = "([^()]*)"/).flatten
            end
        end
    end
end

output = FILE_HEADER

strings.uniq.reject{|string| EXCLUDE_STRINGS.include?(string) or string.start_with?("v") && string.include?(".")}.each do |string|
    output.concat('
msgid "' + string + '"
msgstr ""
')
end

file = File.new(OUTPUT_PATH, "w")
file.print(output)
file.close