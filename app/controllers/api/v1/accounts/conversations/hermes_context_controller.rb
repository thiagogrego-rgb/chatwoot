# Auth and conversation visibility are inherited from the standard conversation API.
class Api::V1::Accounts::Conversations::HermesContextController < Api::V1::Accounts::Conversations::BaseController
  def show
    return head :not_found unless ENV['HERMES_CONTEXT_ENABLED'] == 'true'
    return head :not_found unless @conversation.inbox.channel_type == 'Channel::Api'

    note = @conversation.messages.where(account_id: Current.account.id, private: true, message_type: :outgoing)
                        .order(id: :desc).limit(100).detect do |message|
      message.content.to_s.start_with?("HOMOLOGACAO - SEM ENVIO AO WHATSAPP\n") &&
        message.content.to_s.match?(/^Protocolo: WAG-[A-F0-9]{20}$/)
    end
    return head :not_found unless note

    render json: { version: 1, message_id: note.id, conversation_id: @conversation.display_id,
                   inbox_id: @conversation.inbox_id, private: true, content: note.content.to_s.first(3500) }
  end
end
