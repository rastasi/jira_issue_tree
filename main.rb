require 'bundler'

Bundler.require
Dotenv.load('.env.local', '.env')

require './lib/jira_issue_tree'

JiraIssueTree.new(
  base_url: ENV['JIT_BASE_URL'],
  user: ENV['JIT_USER'],
  password: ENV['JIT_PASSWORD']
).get(ARGV[0])
