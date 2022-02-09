import gleam/http/request.{Request}
import gleam/http
import gleam/string
import gleam/json
import gleam/list
import gleam/io

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
  let receipients = fn(emails) {
    json.array(
      emails,
      fn(email) { json.object([#("email", json.string(email))]) },
    )
  }

  let make_content = fn(content, content_type) {
    json.object([
      #("type", json.string(content_type)),
      #("value", json.string(content)),
    ])
  }

  let content = case email.content {
    TextContent(text: text) ->
      json.preprocessed_array([make_content(text, "text/plain")])
    RichContent(html: html, text: text) ->
      json.preprocessed_array([
        make_content(text, "text/plain"),
        make_content(html, "text/html"),
      ])
  }

  let body =
    json.object([
      #(
        "personalizations",
        json.preprocessed_array([json.object([#("to", receipients(email.to))])]),
      ),
      #(
        "from",
        json.object([
          #("email", json.string(email.sender_email)),
          #("name", json.string(email.sender_name)),
        ]),
      ),
      #("subject", json.string(email.subject)),
      #("content", content),
    ])
    |> json.to_string

  let bearer = string.append("Bearer ", api_key)
  request.new()
  |> request.set_body(body)
  |> request.prepend_header("authorization", bearer)
  |> request.prepend_header("content-type", "application/json")
  |> request.set_method(http.Post)
  |> request.set_host("api.sendgrid.com")
  |> request.set_path("/v3/mail/send")
}
