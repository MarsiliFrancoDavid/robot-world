module SlackMessenger
    def send_message(msg)
        SlackNotifier::CLIENT.ping msg
    end
end