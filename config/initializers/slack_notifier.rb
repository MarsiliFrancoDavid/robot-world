module SlackNotifier
    CLIENT = Slack::Notifier.new ENV["pg_slack_webhook"]
end