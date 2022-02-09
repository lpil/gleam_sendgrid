import gleam/sendgrid
import gleam/hackney
import gleam/io

external fn load_api_key() -> String =
  "gleam_sendgrid_test_ffi" "load_api_key"

pub fn email_creation_test() {
  sendgrid.new_email("sender@example.com")
  |> sendgrid.to("harry@example.com")
  |> sendgrid.sender_name("Louis")
  |> sendgrid.subject("Hello, Joe!")
  |> sendgrid.html_body("<h1>System still working?</h1>")
  |> sendgrid.text_body("System still working?\n")
}
