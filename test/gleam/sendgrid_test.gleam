import gleam/sendgrid
import gleam/http
import gleam/http/request
import gleeunit/should

pub fn dispatch_request_text_content_test() {
  let request =
    sendgrid.Email(
      to: ["joe@example.com"],
      sender_email: "mike@example.com",
      sender_name: "Mike",
      subject: "Hello, Joe!",
      content: sendgrid.TextContent("System still working?"),
    )
    |> sendgrid.dispatch_request("some-api-key")

  request.host
  |> should.equal("api.sendgrid.com")

  request.path
  |> should.equal("/v3/mail/send")

  request.method
  |> should.equal(http.Post)

  request
  |> request.get_header("content-type")
  |> should.equal(Ok("application/json"))

  request
  |> request.get_header("authorization")
  |> should.equal(Ok("Bearer some-api-key"))

  request.body
  |> should.equal(
    "{\"personalizations\":[{\"to\":[{\"email\":\"joe@example.com\"}]}],\"from\":{\"email\":\"mike@example.com\",\"name\":\"Mike\"},\"subject\":\"Hello, Joe!\",\"content\":[{\"type\":\"text/plain\",\"value\":\"System still working?\"}]}",
  )
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
    |> sendgrid.dispatch_request("some-api-key")

  request.host
  |> should.equal("api.sendgrid.com")

  request.path
  |> should.equal("/v3/mail/send")

  request.method
  |> should.equal(http.Post)

  request
  |> request.get_header("content-type")
  |> should.equal(Ok("application/json"))

  request
  |> request.get_header("authorization")
  |> should.equal(Ok("Bearer some-api-key"))

  request.body
  |> should.equal(
    "{\"personalizations\":[{\"to\":[{\"email\":\"joe@example.com\"}]}],\"from\":{\"email\":\"mike@example.com\",\"name\":\"Mike\"},\"subject\":\"Hello, Joe!\",\"content\":[{\"type\":\"text/plain\",\"value\":\"System still working?\"},{\"type\":\"text/html\",\"value\":\"<p>System still working?</p>\"}]}",
  )
}
