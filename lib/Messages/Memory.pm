package Messages::Memory;
use Moose;

with 'Messages::IMessage';

has 'messages' => ( is      => 'rw',
                    traits  => ['Array'],
                    isa     => 'ArrayRef[HashRef[Str]]',
                    default => sub { [ ] },
                    handles => { add_message      => 'push',
                    	         has_messages     => 'count',
                    	         get_all_messages => 'elements'});

no Moose;
1;