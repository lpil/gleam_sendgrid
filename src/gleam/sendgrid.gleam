import gleam/option.{Option}
import gleam/http/request.{Request}
import gleam/http
import gleam/string
import gleam/json
import gleam/list
import gleam/io

pub type Email {
  Email(
    to: List(String),
    sender_name: Option(String),
    sender_email: String,
    subject: Option(String),
    html_body: Option(String),
    text_body: Option(String),
  )
}

// TODO: test
// TODO: documents
pub fn new_email(sender: String) -> Email {
  Email(
    to: [],
    sender_name: option.None,
    sender_email: sender,
    subject: option.None,
    html_body: option.None,
    text_body: option.None,
  )
}

// TODO: test
// TODO: documents
pub fn to(email: Email, addressee: String) -> Email {
  Email(..email, to: [addressee, ..email.to])
}

// TODO: test
// TODO: documents
pub fn sender_name(email: Email, name: String) -> Email {
  Email(..email, sender_name: option.Some(name))
}

// TODO: test
// TODO: documents
pub fn subject(email: Email, subject: String) -> Email {
  Email(..email, subject: option.Some(subject))
}

// TODO: test
// TODO: documents
pub fn html_body(email: Email, body: String) -> Email {
  Email(..email, html_body: option.Some(body))
}

// TODO: test
// TODO: documents
pub fn text_body(email: Email, body: String) -> Email {
  Email(..email, text_body: option.Some(body))
}

// TODO: test
// TODO: documents
// curl --request POST \
//   --url https://api.sendgrid.com/v3/mail/send \
//   --header "Authorization: Bearer $SENDGRID_API_KEY" \
//   --header 'Content-Type: application/json' \
//   --data '{"personalizations": [{"to": [{"email": "test@example.com"}]}],"from": {"email": "test@example.com"},"subject": "Sending with SendGrid is Fun","content": [{"type": "text/plain", "value": "and easy to do anywhere, even with cURL"}]}'
pub fn dispatch_request(email: Email, api_key: String) -> Request(String) {
  let body =
    json.object([
      #(
        "personalizations",
        json.preprocessed_array([
          json.object([
            #(
              "to",
              json.array(
                email.to,
                fn(email) { json.object([#("email", json.string(email))]) },
              ),
            ),
          ]),
        ]),
      ),
      #("from", json.object([#("email", json.string(email.sender_email))])),
      #("subject", json.nullable(email.subject, of: json.string)),
      #(
        "content",
        json.preprocessed_array([
          json.object([
            #("type", json.string("text/plain")),
            #("value", json.string("Ok plz work")),
          ]),
        ]),
      ),
    ])
    |> json.to_string

  let bearer = string.append("Bearer ", api_key)
  request.new()
  |> request.set_body(body)
  |> request.prepend_header("Authorization", bearer)
  |> request.prepend_header("Content-Type", "application/json")
  |> request.set_method(http.Post)
  |> request.set_host("api.sendgrid.com")
  |> request.set_path("/v3/mail/send")
}
