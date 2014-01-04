#!/usr/bin/env perl
use Mojolicious::Lite;
use FindBin qw($Bin);
use lib     qq{$Bin/lib};
use feature qw(state);
use Module::Load;
use DateTime;

my $counter;
my %clients;

app->sessions->default_expiration(86400);
plugin JSONConfig => { file => 'ChatIt.conf.json' };
load(app->config->{message_storage});

helper 'messages' => sub { 
	    my $controller = shift;
        state $module = app->config->{message_storage}->new( config => app->config );
        return $module;
};
helper 'message_all_participants' => sub {
	   my ($controller,$msg,$who) = @_;
	   my $hms  = DateTime->now->hms();
	   my $html = $controller->render( template => 'application/message', 
			    	                   partial  => 1,
			  	                       user     => $who,
			  	                       message  => $msg,
			  	                       time     => $hms );
       $controller->messages()->add_message( { user    => $who,
		       	                               message => $msg,
		       	                               time    => $hms });
       	                        
	   foreach my $tx_str (keys(%clients)) {
	       $clients{$tx_str}->send( { text => $html } );
	   };
};

get '/' => sub {
  my $self = shift;
  my $user;
  
  unless ($self->session('user')) {
  	$user = sprintf("user%d",$counter++);
  	$self->session( user => $user );
  }
  # Why cant we do url_for('/chat')->to_abs on a websocket route????
  $self->render( template => 'application/chat', 
                 messages => $self->messages(),
                 ws       => sprintf("ws://%s:%d/%s",$self->req->url->to_abs->host,
                                                     $self->req->url->to_abs->port,'chat') );
};

get '/logout' => sub {
	 my $self = shift;
	 
	 if ($self->session('user')) {
	 	delete $self->session->{user};
	 	$self->render( template => 'application/logout' );
	 }
};

websocket '/chat' => sub {
	  my $controller = shift;
	  $clients{ $controller->tx } = $controller->tx;
	  
	  Mojo::IOLoop->stream($controller->tx->connection)->timeout(0); # Never timeout
	  $controller->on( json => sub { 
	  	           my ($ws,$json) = @_;
                   $controller->message_all_participants($json->{message},$json->{user});
      });
      $controller->on(finish => sub {
    				my ($ws, $code, $reason) = @_;
    				delete($clients{$ws});
    				delete($controller->session->{user});
       });
};
app->start;