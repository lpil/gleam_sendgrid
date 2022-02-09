# Gleam SendGrid

[![Package Version](https://img.shields.io/hexpm/v/gleam_sendgrid)](https://hex.pm/packages/gleam_sendgrid)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleam_sendgrid/)

A client for SendGrid's API, enabling Gleam programs to send emails.

## Usage

Add this package to your Gleam project.

```sh
gleam add gleam_sendgrid
```

And then send some emails!

```gleam
import gleam/sendgrid
import gleam/hackney

pub fn main() {
  let api_key = "your SendGrid API key here"

  // Construct an email
  let email = 
    sendgrid.new_email(from: "mike@example.com")
    |> sendgrid.to("joe@example.com")
    |> sendgrid.subject("Hello, Joe")
    |> sendgrid.text_body("System still working?\n")

  // Prepare an API request
  let request = sendgrid.dispatch_request(email, api_key)

  // Send it with a HTTP client of your choice
  assert Ok(response) = hackney.send(request)

  // A status of 202 indicates that the email has been sent
  assert 202 = response.status
}
```
