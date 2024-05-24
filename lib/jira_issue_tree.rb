class JiraIssueTree
  def initialize(options)
    @conn = Faraday.new(url: options[:base_url]) do |conn|
      conn.request :authorization, :basic, options[:user], options[:password]
    end
  end

  def get(key, deep_level = 1)
    issue = get_issue(key)
    print_issue(issue, deep_level + 1)
    print_children(issue, deep_level)
    print_linked(issue, deep_level)
  end

  private

  def print_issue(issue, deep_level)
    key = issue['key']
    summary = issue['fields']['summary']
    type = issue['fields']['issuetype']['name']
    print_line("[#{key}] [#{type}] #{summary}", deep_level)
  end

  def print_linked(issue, deep_level)
    linked = issue['fields']['issuelinks']
    return unless linked.any?

    print_line('Linked issues:', deep_level)
    linked.each do |il|
      get(il['inwardIssue']['key'], deep_level + 1) if il['inwardIssue']
    end
  end

  def print_children(issue, deep_level)
    children = get_children(issue['key'])
    return unless children.any?

    print_line('Children issues:', deep_level)
    children['issues'].each do |issue|
      print_issue(issue, deep_level)
    end
  end

  def print_line(text, deep_level)
    puts "#{indent(deep_level)} #{text}"
  end

  def indent(deep_level)
    '-' * deep_level
  end

  def get_children(key)
    url = "/rest/api/latest/search?jql=parent%3D#{key}"
    http_get(url)
  end

  def get_issue(key)
    url = "/rest/api/latest/issue/#{key}"
    http_get(url)
  end

  def http_get(url)
    response = @conn.get(url)
    JSON.parse response.body
  end
end
