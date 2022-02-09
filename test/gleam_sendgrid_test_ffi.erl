-module(gleam_sendgrid_test_ffi).

-export([load_api_key/0]).

load_api_key() ->
    list_to_binary(os:getenv("SENDGRID_API_KEY")).
