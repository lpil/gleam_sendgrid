import gleam/dynamic/decode
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/option.{type Option, None, Some}

pub type Email {
  Email(
    /// A list of emails to whom this email will be sent.
    ///
    to: List(String),
    /// The email address from which messages are sent, it should be a verified
    /// sender in your Twilio SendGrid account.
    ///
    sender_email: String,
    /// A name or title associated with the email address such as "Support" or
    /// "Alice".
    ///
    sender_name: String,
    /// The subject of your email.
    ///
    /// > Note how, as per [RFC 2822](https://www.rfc-editor.org/rfc/rfc2822#section-2.1.1),
    /// > the subject line should be no more than 78 characters, and must be no
    /// > more than 998 characters.
    ///
    subject: String,
    content: EmailContent,
  )
}

pub type EmailContent {
  TextContent(text: String)
  RichContent(html: String, text: String)
}

pub type SendGridError {
  SendGridError(
    /// An id identifying the error, if applicable.
    ///
    id: Option(String),
    errors: List(ErrorObject),
  )
  UnexpectedResponseError(response: Response(String))
}

pub type ErrorObject {
  ErrorObject(
    message: String,
    /// The request's field that generated the error, if applicable.
    ///
    field: Option(String),
    /// A helper text or a link to documentation to help you troubleshoot the
    /// error.
    ///
    help: Option(String),
  )
}

/// A request to send email over SendGrid's v3 Web API.
///
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

pub fn mail_send_response(
  response: Response(String),
) -> Result(Nil, SendGridError) {
  case response.status {
    n if 200 <= n && n <= 299 -> Ok(Nil)
    _ ->
      case json.parse(response.body, sendgrid_error_decoder()) {
        Ok(errors) -> Error(errors)
        Error(_) -> Error(UnexpectedResponseError(response))
      }
  }
}

fn sendgrid_error_decoder() -> decode.Decoder(SendGridError) {
  use id <- decode.optional_field("id", None, decode.map(decode.string, Some))
  use errors <- decode.optional_field(
    "errors",
    [],
    decode.list(error_object_decoder()),
  )
  decode.success(SendGridError(id:, errors:))
}

fn error_object_decoder() -> decode.Decoder(ErrorObject) {
  use message <- decode.field("message", decode.string)
  use field <- decode.optional_field("field", None, field_decoder())
  use help <- decode.optional_field(
    "help",
    None,
    decode.optional(decode.string),
  )
  decode.success(ErrorObject(message:, field:, help:))
}

fn field_decoder() -> decode.Decoder(Option(String)) {
  use field_value <- decode.map(decode.optional(decode.string))
  case field_value {
    // According to sendgrid's API, the field "field" can have the literal
    // string "null" when not applicable:
    // https://www.twilio.com/docs/sendgrid/api-reference/mail-send/mail-send#responses
    Some("null") -> None
    _ -> field_value
  }
}
