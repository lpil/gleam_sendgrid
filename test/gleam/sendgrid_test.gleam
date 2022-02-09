import gleam/sendgrid

pub fn email_creation_test() {
  sendgrid.new_email()
  |> sendgrid.to("harry@example.com")
  |> sendgrid.from("Louis", "louis@gleam.run")
  |> sendgrid.subject("Hello, Joe!")
  |> sendgrid.html_body("<h1>System still working?</h1>")
  |> sendgrid.text_body("System still working?\n")
}
