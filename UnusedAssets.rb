#!/usr/bin/ruby
#encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

class ImagesetReferenceChecker
  def find
    # Collect all .imageset folders
    all_imagesets = Dir.glob("**/*.imageset").select { |path| File.directory?(path) }

    # Extract folder names without the .imageset extension
    imageset_names = all_imagesets.map { |imageset| File.basename(imageset, ".imageset") }
    puts "Found Imagesets: #{imageset_names.length}"
    puts imageset_names.join("\n")

    # Read other files to find references to these .imageset names
    other_files = Dir.glob("**/*.{swift,m,h,xib,storyboard,json,.plist}").reject { |path| File.directory?(path) || path.end_with?("XCAssets+Generated.swift") }
    puts "\nSearching in other files for Imageset references..."

    find_references_in_files(imageset_names, other_files)
  end

  def find_references_in_files(imageset_names, files)
    imageset_references = imageset_names.map { |name| [name, 0] }.to_h

    files.each do |file|
      lines = File.readlines(file).map { |line| line.gsub(/^\s*\/\/.*/, "") } # Remove comments
      content = lines.join("\n")

      imageset_names.each do |name|
        imageset_references[name] += content.scan(/\b#{Regexp.escape(name)}\b/i).count
      end
    end

    unused_imagesets = imageset_references.select { |_, count| count == 0 }

    if unused_imagesets.any?
      puts "\nUnused Imagesets (not referenced anywhere):"
      unused_imagesets.each { |name, _| puts name }
    else
      puts "\nNo unused Imagesets found."
    end
  end
end

ImagesetReferenceChecker.new.find
