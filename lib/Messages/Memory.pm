package Messages::Memory;
use Moose;

has 'messages' => ( is      => 'rw',
                    traits  => ['Array'],
                    isa     => 'ArrayRef[HashRef[Str]]',
                    default => sub { [ ] },
                    handles => { add_message      => 'push',
                    	         has_messages     => 'count',
                    	         get_all_messages => 'elements'});

with 'Messages::IMessage';

no Moose;
1;