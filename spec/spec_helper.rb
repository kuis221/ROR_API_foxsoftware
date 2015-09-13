require 'simplecov'
SimpleCov.start do
  add_filter 'config/'
  add_filter 'spec/'
  add_filter 'app/models/ability.rb'
  add_filter 'app/controllers/authentication.rb'
end

require 'rspec/retry'

RSpec.configure do |config|

  ## Retry
  config.verbose_retry = true
  config.display_try_failure_messages = true
  ## Clear emails on before each step
  config.before(:each) { ActionMailer::Base.deliveries.clear }

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end

def json_query(type, action, params={})
  params = params.merge(format: :json) # do not merge! here
  eval("#{type} :#{action}, #{params}")
  read_json_response(type)
end

def read_json_response(type)
  @json = JSON.parse(response.body).symbolize_keys rescue false
  puts "ERROR PARSING json_query :#{type} method, non json reply with response.body: \n\r#{response.body.inspect}" unless @json
  expect(response['Content-Type']).to match /(application\/json)/
end

def expect_email(count=1, body_eq=false, subject_eq=false)
  mail = ActionMailer::Base.deliveries.last
  if mail
    subject = mail.subject
    body = mail.body.raw_source
  end
  expect(ActionMailer::Base.deliveries.count).to eq count
  expect(body).to include(body_eq) if body_eq
  expect(subject).to include(subject_eq) if subject_eq
end

def email_clear
  ActionMailer::Base.deliveries.clear
end