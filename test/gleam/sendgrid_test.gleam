import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/option.{None, Some}
import gleam/sendgrid
import gleam/string

pub fn dispatch_request_text_content_test() {
  let request =
    sendgrid.Email(
      to: ["joe@example.com"],
      sender_email: "mike@example.com",
      sender_name: "Mike",
      subject: "Hello, Joe!",
      content: sendgrid.TextContent("System still working?"),
    )
    |> sendgrid.mail_send_request("some-api-key")

  assert http.Post == request.method
  assert http.Https == request.scheme
  assert "api.sendgrid.com" == request.host
  assert "/v3/mail/send" == request.path
  assert Ok("application/json") == request.get_header(request, "content-type")
  assert Ok("Bearer some-api-key")
    == request.get_header(request, "authorization")
  assert "{\"personalizations\":[{\"to\":[{\"email\":\"joe@example.com\"}]}],\"from\":{\"email\":\"mike@example.com\",\"name\":\"Mike\"},\"subject\":\"Hello, Joe!\",\"content\":[{\"type\":\"text/plain\",\"value\":\"System still working?\"}]}"
    == request.body
}

pub fn dispatch_request_rich_content_test() {
  let request =
    sendgrid.Email(
      to: ["joe@example.com"],
      sender_email: "mike@example.com",
      sender_name: "Mike",
      subject: "Hello, Joe!",
      content: sendgrid.RichContent(
        html: "<p>System still working?</p>",
        text: "System still working?",
      ),
    )
    |> sendgrid.mail_send_request("some-api-key")

  assert http.Post == request.method
  assert http.Https == request.scheme
  assert "api.sendgrid.com" == request.host
  assert "/v3/mail/send" == request.path
  assert Ok("application/json") == request.get_header(request, "content-type")
  assert Ok("Bearer some-api-key")
    == request.get_header(request, "authorization")
  assert "{\"personalizations\":[{\"to\":[{\"email\":\"joe@example.com\"}]}],\"from\":{\"email\":\"mike@example.com\",\"name\":\"Mike\"},\"subject\":\"Hello, Joe!\",\"content\":[{\"type\":\"text/plain\",\"value\":\"System still working?\"},{\"type\":\"text/html\",\"value\":\"<p>System still working?</p>\"}]}"
    == request.body
}

pub fn error_with_missing_field_and_help_test() {
  assert "{
      'errors': [{'message': 'an error'}]
    }"
    |> string.replace(each: "'", with: "\"")
    |> error_response
    == sendgrid.SendGridError(id: None, errors: [
      sendgrid.ErrorObject(message: "an error", field: None, help: None),
    ])
}

pub fn error_with_string_null_field_test() {
  assert "{
      'errors': [{'message': 'an error', 'field': 'null'}]
    }"
    |> string.replace(each: "'", with: "\"")
    |> error_response
    == sendgrid.SendGridError(id: None, errors: [
      sendgrid.ErrorObject(message: "an error", field: None, help: None),
    ])
}

pub fn error_with_null_field_test() {
  assert "{
      'errors': [{'message': 'an error', 'field': null}]
    }"
    |> string.replace(each: "'", with: "\"")
    |> error_response
    == sendgrid.SendGridError(id: None, errors: [
      sendgrid.ErrorObject(message: "an error", field: None, help: None),
    ])
}

pub fn error_with_field_and_help_test() {
  assert "{
      'errors': [{
        'message': 'an error',
        'field': 'wibble',
        'help': 'try this'
      }]
    }"
    |> string.replace(each: "'", with: "\"")
    |> error_response
    == sendgrid.SendGridError(id: None, errors: [
      sendgrid.ErrorObject(
        message: "an error",
        field: Some("wibble"),
        help: Some("try this"),
      ),
    ])
}

pub fn error_with_multiple_errors_and_id_test() {
  assert "{
      'id': 'E001',
      'errors': [
        {
          'message': 'first error',
          'help': 'try this'
        },
        {
          'message': 'second error',
          'field': 'wibble'
        }
      ]
    }"
    |> string.replace(each: "'", with: "\"")
    |> error_response
    == sendgrid.SendGridError(id: Some("E001"), errors: [
      sendgrid.ErrorObject(
        message: "first error",
        field: None,
        help: Some("try this"),
      ),
      sendgrid.ErrorObject(
        message: "second error",
        field: Some("wibble"),
        help: None,
      ),
    ])
}

pub fn error_with_unexpected_shape_test() {
  let error =
    "{'errors': [{ 'wobble': 1 }]}"
    |> string.replace(each: "'", with: "\"")

  let response =
    response.new(400)
    |> response.set_body(error)

  assert sendgrid.mail_send_response(response)
    == Error(sendgrid.UnexpectedResponseError(response))
}

pub fn successful_response_test() {
  assert Ok(Nil) == response.new(200) |> sendgrid.mail_send_response
}

fn error_response(error: String) -> sendgrid.SendGridError {
  let assert Error(error) =
    response.new(400)
    |> response.set_body(error)
    |> sendgrid.mail_send_response

  error
}
