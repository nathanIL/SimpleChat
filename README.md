SimpleChat
==========

A very basic & simple web chat based on Mojolicious (backend) and Twitter Boostrap & jQuery (frontend).
Uses WebSockets and basic sessions for auto-generated users.

Its configurable via a JSON configuraion file (<b>ChatIt.conf.json</b>).
For instance, rename this file with <b>ChatIt-Memcached.conf.json</b> to use MemCached to store
the chat messages, you may want to add more MemCached servers to <b>servers</b>.

## Notes:
Its not, by all means, supposed to be used in production environment. its just me playing around with WebSockets
and <b>Mojolicious::Lite</b>.

## TODO:
0. First an foremost, fix language support - only English is supported.
1. Fix CSS issues, and prettify.
2. Encapsulate clients behavior in a dedicated module.
3. Add emoticons / smileys.
4. add real-time ads to messages by parsing relevant keywords. upon keyword mouse over event,
a tooltip will pop out showing some relevant details (ad info).
5. Custom user logins (usernames),
6. change default exception & not found pages from the Mojo templated to custom ones.
