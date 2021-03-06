package Messages::IMessage;
use Moose::Role;

requires qw(add_message 
            has_messages 
            get_all_messages);

has config => ( is  => 'ro',
                isa => 'HashRef[Any]' );

1;