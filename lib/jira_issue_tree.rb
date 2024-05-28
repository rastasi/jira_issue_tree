class JiraIssueTree
  def initialize(options)
    @base_url = options[:base_url]
    @conn = Faraday.new(url: @base_url) do |conn|
      conn.request :authorization, :basic, options[:user], options[:password]
    end
  end

  def start!(key)
    puts "<html>
            <head>
              <title>Jira issue Tree for #{key}</title>
              <link rel='stylesheet' href='https://matcha.mizu.sh/matcha.css'>
              <style>
                body { font-family: Courier New; }
              </style>
            </head>
            <body>"
    get(key)
    puts '  </body>
          </html>'
  end

  private

  def get(key)
    issue = get_issue(key)
    print_issue(issue)
    puts '<ul>'
    print_children(issue)
    print_linked(issue)
    puts '</ul>'
  end

  def print_issue(issue)
    key = issue['key']
    summary = issue['fields']['summary']
    type = issue['fields']['issuetype']['name']
    link = "#{@base_url}/browse/#{key}"
    color = get_color(type)
    print_line("<a href='#{link}' target='_blank'>#{"[#{key}]".ljust(8)}</a> #{"[#{type}]".ljust(7)} <span style='color: #{color}'>#{summary}</span>")
  end

  def print_linked(issue)
    linked = issue['fields']['issuelinks'].filter { |il| !il['inwardIssue'].nil? }
    return unless linked.any?

    print_line('<u><b>Linked issues</b></u>')
    puts '<ul>'
    linked.each do |il|
      get(il['inwardIssue']['key'])
    end
    puts '</ul>'
  end

  def print_children(issue)
    children = get_children(issue['key'])
    return unless children.any?

    print_line('<u><b>Children issues</b></u>')
    puts '<ul>'
    children['issues'].each do |child_issue|
      print_issue(child_issue)
    end
    puts '</ul>'
  end

  def print_line(text)
    puts "<li>#{text}</li>"
  end

  def get_color(type)
    return 'magenta' if type == 'Epic'
    return 'lightgreen' if type == 'Story'

    'lightblue' if type == 'Task'
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
