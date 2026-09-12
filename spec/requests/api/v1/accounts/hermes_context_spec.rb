require 'rails_helper'

RSpec.describe 'Hermes private handoff context', type: :request do
  let(:account) { create(:account) }
  let(:inbox) { create(:inbox, channel: create(:channel_api, account: account), account: account) }
  let(:conversation) { create(:conversation, account: account, inbox: inbox) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:path) { "/api/v1/accounts/#{account.id}/conversations/#{conversation.display_id}/hermes_context" }
  let(:content) { "HOMOLOGACAO - SEM ENVIO AO WHATSAPP\nProtocolo: WAG-#{'A' * 20}\nUltima pergunta tratada: Where?" }

  before { create(:inbox_member, inbox: inbox, user: agent) }

  it 'returns only the latest private outgoing briefing' do
    note = create(:message, conversation: conversation, account: account, inbox: inbox, private: true, message_type: :outgoing, content: content)
    create(:message, conversation: conversation, account: account, inbox: inbox, private: false, message_type: :outgoing, content: content)
    with_modified_env HERMES_CONTEXT_ENABLED: 'true' do
      get path, headers: agent.create_new_auth_token, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include('private' => true, 'message_id' => note.id, 'content' => content)
    end
  end

  it 'does not expose a briefing without authentication' do
    with_modified_env HERMES_CONTEXT_ENABLED: 'true' do
      get path, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  it 'is unavailable when the integration is disabled' do
    with_modified_env HERMES_CONTEXT_ENABLED: 'false' do
      get path, headers: agent.create_new_auth_token, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  it 'does not allow a user from another account' do
    outsider = create(:user, account: create(:account), role: :agent)
    with_modified_env HERMES_CONTEXT_ENABLED: 'true' do
      get path, headers: outsider.create_new_auth_token, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
