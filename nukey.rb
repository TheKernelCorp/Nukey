MAGIC = 0xADFCCFDA

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  nil
end

if __FILE__ == $PROGRAM_NAME
    # Try to find nasm, which is used for assembling
    # the keymap sources into a format processable by nukey.
    nasm = which 'nasm'
    unless nasm
        # Exit if nasm can't be found.
        puts 'Unable to find `nasm` executable.'
        exit 1
    end
    Dir.mkdir 'keymaps' unless Dir.exists? 'keymaps'
    # Find all assembly sources in the ./sources directory.
    # Those are the keymaps, in a format readable by nasm.
    Dir.glob('sources/*.{s,asm}') do |file_name|
        key_layout = File.basename file_name, '.*'
        print "[#{key_layout}] Assembling..."
        # Compile the current keymap with nasm.
        # nasm flags:
        # -Oo       = Apply no optimizations
        # -Fnull    = Include no debug information
        # -fobj     = Produce a flat binary

        status = system("\"#{nasm}\" -O0 -Fnull -fobj -o\"keymaps/#{key_layout}.bin\" \"#{file_name}\"")
        raise "Error in calling #{nasm}" unless status
        puts "OK"
    end
    # Find all flat binaries produced in the previous step.
    Dir.glob('keymaps/*.bin') do |file_name|
        # Get the name of the current key layout.
        key_layout = File.basename file_name, '.*'
        offset = 0
        found = false
        contents = File.read(file_name).bytes.to_a
        File.delete file_name
        print "[#{key_layout}] Validating..."
        while offset < contents.size
            # Test whether the next four bytes are equal to the magic number.
            # If they are, we've found our entry point.
            found = true
            found &= contents[offset + 0] == (MAGIC >> 0x18) & 0xFF
            found &= contents[offset + 1] == (MAGIC >> 0x10) & 0xFF
            found &= contents[offset + 2] == (MAGIC >> 0x08) & 0xFF
            found &= contents[offset + 3] == (MAGIC >> 0x00) & 0xFF
            break if found
            offset += 1
        end
        # Add four to the offset to skip the magic number.
        offset += 4
        unless found
            # Stop processing this keymap if the magic number couldn't be found.
            puts "FAILED"
            puts "[#{key_layout}] Failed to validate! Skipping."
            break
        end
        puts "OK"
        print "[#{key_layout}] Creating Crystal source..."
        max_offset = [contents.size, offset + 256].min
        # Construct an empty string for the keymap and append some
        # boostrap code to it, to make it work with Crystal.
        keymap = "KEYMAP_#{key_layout.upcase} = "
        keymap << '"'
        # Iterate over the key codes.
        while offset < max_offset
            keycode = contents[offset]
            # There are special cases where the actual ascii character
            # of the keycode can be embedded into the string directly.
            if true &&
                keycode >= 32 &&    # greater than or equal to ' '
                keycode <= 126 &&   # less than or equal to '~'
                keycode != 34 &&    # not '"'
                keycode != 92       # not '\\'
                # Embed the ascii character into the keymap
                keymap << keycode.chr
            else
                # If the aforementioned special cases don't apply,
                # an octal escape will be used to embed the keycode
                # into the string. However, this can lead to issues
                # if the next keycode is embedded as an ascii character
                # and it starts with a number.
                keycode_oct = keycode.to_s 8
                if offset + 1 < max_offset
                    # Read the next keycode.
                    next_keycode = contents[offset + 1]
                    if next_keycode >= 32 && next_keycode <= 126
                        # The special cases probably apply for the next keycode,
                        # so we justify its octal representation with zeroes.
                        keymap << "\\#{keycode_oct.rjust 3, '0'}"
                        offset += 1
                        next
                    end
                end
                # Embed the keycode with an octal escape.
                keymap << "\\#{keycode_oct}"
            end
            offset += 1
        end
        keymap << '"'
        # Create a Crystal source file from the keymap.
        File.write("keymaps/#{key_layout}.cr", keymap)
        puts "OK"
    end
end