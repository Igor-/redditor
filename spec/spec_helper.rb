# coding: utf-8

require 'rspec'
require 'redditor'

require 'bundler/setup'
require 'rails/all'
require 'active_record'
require 'rspec'
require 'generator_spec/test_case'
# require 'generators/redde/deploy/deploy_generator'

RSpec.configure do |c|
  c.mock_with :rspec
end