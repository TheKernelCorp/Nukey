MAGIC = 0xADFCCFDA

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end

if __FILE__ == $PROGRAM_NAME
    nasm = which 'nasm'
    if nasm.nil?
        puts 'Unable to find `nasm` executable.'
        exit 1
    end
    Dir.mkdir 'keymaps' unless Dir.exists? 'keymaps'
    Dir.glob('sources/*.{s,asm}') do |file|
        file_name = File.basename file, '.*'
        puts "[#{file_name}] Assembling..."
        exec = "\"#{nasm}\" -O0 -Fnull -fobj -o\"keymaps/#{file_name}\" \"#{file}\""
        IO.popen exec do |io|
            Process.wait io.pid
        end
    end
    Dir.glob('keymaps/*') do |file|
        file_name = File.basename file
        offset = 0
        found = false
        contents = File.read(file).bytes.to_a
        puts "[#{file_name}] Validating..."
        while offset < contents.size
            found = true
            found &= contents[offset + 0] == (MAGIC >> 0x18) & 0xFF
            found &= contents[offset + 1] == (MAGIC >> 0x10) & 0xFF
            found &= contents[offset + 2] == (MAGIC >> 0x08) & 0xFF
            found &= contents[offset + 3] == (MAGIC >> 0x00) & 0xFF
            break if found
            offset += 1
        end
        unless found
            puts "[#{file_name}] Failed to validate! Skipping."
            break
        end
        keymap = String.new
        puts "[#{file_name}] Writing keymap..."
        offset += 4
        while offset < contents.size
            byte = contents[offset]
            keymap << "\\n#{byte}"
            offset += 1
        end
        File.open(file, 'w') { |file| file.write keymap }
    end
end