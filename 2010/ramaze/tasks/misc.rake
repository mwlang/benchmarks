task :environment do
  RAMAZE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  require(File.join(RAMAZE_ROOT, 'app'))
end

