# Hermes conversation continuity integration

Hermes can preserve a customer's question during onboarding, answer follow-ups in context, and pass the remaining work to a human through the existing API inbox. This integration uses the current Messages API; it does not require a second WhatsApp receiver or a change to Chatwoot core.

## Contract

`contract.json` describes the adapter boundary. An operator summary is an outgoing **private** note. Include the case reference, latest question, previous assistant response, and remaining work. A prepared response is not proof of delivery; the sender's receipt remains authoritative. Never include credentials, model reasoning, or unrelated customer history.

Use account-scoped credentials and the conversation's verified inbox binding. Historical messages are read through the existing paginated API; filter private notes out of any model context. A customer declaring a business role does not authenticate them.

Hermes must stop autonomous replies while a human owns the conversation. Returning control to Hermes requires an explicit, authorized action and the current conversation revision. Keep webhook authentication, idempotency and outbound delivery reconciliation in the existing adapter.

## How to test

1. Ask a market question before choosing the assistant; after choosing, the pending question should be answered without requesting it again.
2. Follow a question about hours with "E domingo?"; the answer should preserve the market and address Sunday hours.
3. Request a person; confirm that the operator can see the question, previous answer and remaining work in a private note.
4. Send a message while the human owns the conversation; the bot must stay silent.
5. Explicitly return control and verify that the conversation can continue.

Use synthetic conversations for automated checks. Real delivery is a separate acceptance test. Keep deployment configuration, customer messages, account identifiers and credentials in the private application repository. This documentation does not activate an inbox, deploy this fork, or grant an assistant access.
