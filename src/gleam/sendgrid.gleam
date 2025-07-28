import gleam/http
import gleam/http/request.{type Request}
import gleam/json

pub type Email {
  Email(
    to: List(String),
    sender_name: String,
    sender_email: String,
    subject: String,
    content: EmailContent,
  )
}

pub type EmailContent {
  TextContent(text: String)
  RichContent(html: String, text: String)
}

// TODO: test
// TODO: documents
// curl --request POST \
//   --url https://api.sendgrid.com/v3/mail/send \
//   --header "Authorization: Bearer $SENDGRID_API_KEY" \
//   --header 'Content-Type: application/json' \
//   --data '{"personalizations": [{"to": [{"email": "test@example.com"}]}],"from": {"email": "test@example.com"},"subject": "Sending with SendGrid is Fun","content": [{"type": "text/plain", "value": "and easy to do anywhere, even with cURL"}]}'
pub fn dispatch_request(email: Email, api_key: String) -> Request(String) {
pub fn mail_send_request(email: Email, api_key: String) -> Request(String) {
  let Email(to:, sender_name:, sender_email:, subject:, content:) = email

  let make_email = fn(email) { json.object([#("email", json.string(email))]) }
  let recipients = json.object([#("to", json.array(to, make_email))])
  let personalizations = json.preprocessed_array([recipients])

  let from =
    json.object([
      #("email", json.string(sender_email)),
      #("name", json.string(sender_name)),
    ])

  let make_content = fn(content, content_type) {
    json.object([
      #("type", json.string(content_type)),
      #("value", json.string(content)),
    ])
  }

  let content = case content {
    TextContent(text:) ->
      json.preprocessed_array([make_content(text, "text/plain")])
    RichContent(html:, text:) ->
      json.preprocessed_array([
        make_content(text, "text/plain"),
        make_content(html, "text/html"),
      ])
  }

  let body =
    json.object([
      #("personalizations", personalizations),
      #("from", from),
      #("subject", json.string(subject)),
      #("content", content),
    ])

  request.new()
  |> request.set_method(http.Post)
  |> request.set_host("api.sendgrid.com")
  |> request.set_path("/v3/mail/send")
  |> request.set_body(json.to_string(body))
  |> request.prepend_header("authorization", "Bearer " <> api_key)
  |> request.prepend_header("content-type", "application/json")
}
