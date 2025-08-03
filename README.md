# sendgriddle

[![Package Version](https://img.shields.io/hexpm/v/sendgriddle)](https://hex.pm/packages/sendgriddle)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/sendgriddle/)

A client for SendGrid's API, enabling Gleam programs to send emails.

## Usage

Add this package to your Gleam project.

```sh
gleam add sendgriddle
```

And then send some emails!

```gleam
import sendgriddle
import gleam/httpc

pub fn main() {
  let api_key = "your SendGrid API key here"

  // Construct an email
  let email = 
    sendgriddle.Email(
      to: ["joe@example.com"],
      sender_email: "mike@example.com",
      sender_name: "Mike",
      subject: "Hello, Joe!",
      content: sendgrid.TextContent("System still working?"),
    )

  // Prepare an API request
  let request = sendgriddle.mail_send_request(email, api_key)

  // Send it with a HTTP client of your choice
  let assert Ok(response) = httpc.send(request)

  // Check the mail send succeeded
  assert sendgriddle.mail_send_response(response) == Ok(Nil)
}
```
