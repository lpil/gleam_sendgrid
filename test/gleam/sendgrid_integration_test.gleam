import gleam/sendgrid
import gleam/hackney

// pub fn main_test() {
pub fn main() {
  let api_key = "nope"

  // Construct an email
  let email =
    sendgrid.Email(
      to: ["nope"],
      sender_email: "nope",
      sender_name: "You",
      subject: "Hello, Joe!",
      content: sendgrid.TextContent("System still working?"),
    )

  // Prepare an API request
  let request = sendgrid.dispatch_request(email, api_key)

  // Send it with a HTTP client of your choice
  let assert Ok(response) = hackney.send(request)

  // A status of 202 indicates that the email has been sent
  let assert 202 = response.status
}
