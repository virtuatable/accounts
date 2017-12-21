RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.profile_examples = 10
end