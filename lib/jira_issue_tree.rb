class JiraIssueTree
  def initialize(options)
    @conn = Faraday.new(url: options[:base_url]) do |conn|
      conn.request :authorization, :basic, options[:user], options[:password]
    end
  end

  def get(key, deep_level = 1)
    issue = get_issue(key)
    print_line(issue, deep_level)
    issue['fields']['issuelinks'].each do |il|
      get(il['inwardIssue']['key'], deep_level + 1) if il['inwardIssue']
    end
  end

  private

  def print_line(issue, deep_level)
    indent = '-' * deep_level
    key = issue['key']
    summary = issue['fields']['summary']
    puts "#{indent} [#{key}] #{summary}"
  end

  def get_issue(key)
    url = "/rest/api/latest/issue/#{key}"

    response = @conn.get(url)
    JSON.parse response.body
  end
end
