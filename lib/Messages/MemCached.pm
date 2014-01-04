package Messages::MemCached;
use Moose;
use Carp;
use Cache::Memcached;

with 'Messages::IMessage';

has '_memcached' => ( is    => 'ro',
                     isa    => 'Cache::Memcached',
                     writer => '_set_memcached' );

has 'message_counter' => ( is      => 'ro',
                           traits  => ['Counter'],
                           isa     => 'Int',
                           handles => { _inc_counter => 'inc' },
                           default => 0 );

has 'message_keys' => ( is         => 'ro',
                        traits     => ['Array'],
                        isa        => 'ArrayRef[Str]',
                        auto_deref => 1,
                        handles    => { _push => 'push' } );

has 'message_id' => ( is      => 'ro',
                      isa     => 'Str',
                      lazy    => 1,
                      clearer => '_clear_message_id',
                      default =>  sub { sprintf("msg-%d",$_[0]->message_counter) } );
                           
after 'add_message' => sub {
	my $self = shift;
	
	$self->_push($self->message_id);
	$self->_inc_counter;
	$self->_clear_message_id();
};

sub BUILD {
    my $self = shift;
    my $args = shift;
    
    croak "Missing Memcached servers parameters in config file" unless (exists($args->{config}{servers}));
    $self->_set_memcached( Cache::Memcached->new( {  servers => $args->{config}{servers} })  );
}

sub add_message {
	my $self = shift;
	my $msg  = shift;
    
    $self->_memcached->set($self->message_id,$msg);
}

sub has_messages {
	my $self = shift;
	
	return scalar($self->message_keys);
}

sub get_all_messages {
	my $self = shift;
    
    # Cache::Memcached::get_multi() is a better choice, but it also returns the keys, trying to 
    # avoid loading all messages to memory before returning them.
	return scalar($self->message_keys) ? map { $self->_memcached->get($_) } sort $self->message_keys : ();
}

no Moose;
1;