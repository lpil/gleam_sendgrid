//
// Edit and run this module manually to test email sending
//
import gleam/httpc
import sendgriddle

pub fn main() {
  let api_key = "nope"

  // Construct an email
  let email =
    sendgriddle.Email(
      to: ["nope"],
      sender_email: "nope",
      sender_name: "You",
      subject: "Hello, Joe!",
      content: sendgriddle.TextContent("System still working?"),
    )

  // Prepare an API request
  let request = sendgriddle.mail_send_request(email, api_key)

  // Send it with a HTTP client of your choice
  let assert Ok(response) = httpc.send(request)

  // A status of 202 indicates that the email has been sent
  assert 202 == response.status
}
