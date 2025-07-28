import gleam/http
import gleam/http/request
import gleam/sendgrid

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
