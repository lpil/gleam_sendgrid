import gleam/option.{Option}

pub opaque type Email {
  Email(
    to: List(String),
    from: Option(Sender),
    subject: Option(String),
    html_body: Option(String),
    text_body: Option(String),
  )
}

type Sender {
  Sender(name: String, email: String)
}

// TODO: test
// TODO: documents
pub fn new_email() -> Email {
  Email(
    to: [],
    from: option.None,
    subject: option.None,
    html_body: option.None,
    text_body: option.None,
  )
}

// TODO: test
// TODO: documents
pub fn to(email: Email, addressee: String) -> Email {
  Email(..email, to: [addressee, ..email.to])
}

// TODO: test
// TODO: documents
pub fn from(email: Email, name: String, sender_email: String) -> Email {
  Email(..email, from: option.Some(Sender(name, sender_email)))
}

// TODO: test
// TODO: documents
pub fn subject(email: Email, subject: String) -> Email {
  Email(..email, subject: option.Some(subject))
}

// TODO: test
// TODO: documents
pub fn html_body(email: Email, body: String) -> Email {
  Email(..email, html_body: option.Some(body))
}

// TODO: test
// TODO: documents
pub fn text_body(email: Email, body: String) -> Email {
  Email(..email, text_body: option.Some(body))
}
