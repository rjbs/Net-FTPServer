#!/usr/bin/perl -w -T
# -*- perl -*-

# Net::FTPServer A Perl FTP Server
# Copyright (C) 2000 Bibliotech Ltd., Unit 2-3, 50 Carnwath Road,
# London, SW6 3EG, United Kingdom.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# $Id: FileHandle.pm,v 1.1 2000/11/02 18:42:08 rich Exp $

=pod

=head1 NAME

Net::FTPServer::RO::FileHandle - The anonymous, read-only FTP server personality

=head1 SYNOPSIS

  use Net::FTPServer::RO::FileHandle;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=cut

package Net::FTPServer::RO::FileHandle;

use strict;

# Some magic which is required by CPAN. This is not the real version
# number. If you want that, have a look at FTPServer::VERSION.
use vars qw($VERSION);
$VERSION = '1.0';

use Net::FTPServer::FileHandle;

use vars qw(@ISA);

@ISA = qw(Net::FTPServer::FileHandle);

=pod

=item $dirh = $fileh->dir;

Return the directory which contains this file.

=cut

sub dir
  {
    my $self = shift;

    my $dirname = $self->{_pathname};
    $dirname =~ s,[^/]+$,,;

    return Net::FTPServer::RO::DirHandle->new ($self->{ftps}, $dirname);
  }

=pod

=item $fh = $fileh->open (["r"|"w"|"a"]);

Open a file handle (derived from C<IO::Handle>, see
L<IO::Handle(3)>) in either read or write mode.

=cut

sub open
  {
    my $self = shift;
    my $mode = shift;

    return undef unless $mode eq "r";

    return new IO::File $self->{_pathname}, $mode;
  }

=pod

=item ($mode, $perms, $nlink, $user, $group, $size, $time) = $handle->status;

Return the file or directory status. The fields returned are:

  $mode     Mode        'd' = directory,
                        'f' = file,
                        and others as with
                        the file(1) -type option.
  $perms    Permissions Permissions in normal octal numeric format.
  $nlink    Link count
  $user     Username    In printable format.
  $group    Group name  In printable format.
  $size     Size        File size in bytes.
  $time     Time        Time (usually mtime) in Unix time_t format.

In derived classes, some of this status information may well be
synthesized, since virtual filesystems will often not contain
information in a Unix-like format.

=cut

sub status
  {
    my $self = shift;

    my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size,
	$atime, $mtime, $ctime, $blksize, $blocks)
      = lstat $self->{_pathname};

    # Generate printable user/group.
    my $user = getpwuid $uid;
    my $group = getgrgid $gid;

    # Permissions from mode.
    my $perms = $mode & 0777;

    # Work out the mode using special "_" operator which causes Perl
    # to use the result of the previous stat call.
    $mode
      = (-f _ ? 'f' :
	 (-d _ ? 'd' :
	  (-l _ ? 'l' :
	   (-p _ ? 'p' :
	    (-S _ ? 's' :
	     (-b _ ? 'b' :
	      (-c _ ? 'c' : '?')))))));

    return ($mode, $perms, $nlink, $user, $group, $size, $mtime);
  }

=pod

=item $rv = $handle->move ($dirh, $filename);

Move the current file (or directory) into directory C<$dirh> and
call it C<$filename>. If the operation is successful, return 0,
else return -1.

Underlying filesystems may impose limitations on moves: for example,
it may not be possible to move a directory; it may not be possible
to move a file to another directory; it may not be possible to
move a file across filesystems.

=cut

sub move
  {
    return -1;			# Not permitted in read-only server.
  }

=pod

=item $rv = $fileh->delete;

Delete the current file. If the delete command was
successful, then return 0, else if there was an error return -1.

=cut

sub delete
  {
    return -1;			# Not permitted in read-only server.
  }

=pod

=item $rv = $fileh->can_read;

Return true if the current user can read the given file.

=cut

sub can_read
  {
    my $self = shift;

    return -r $self->{_pathname};
  }

=pod

=item $rv = $fileh->can_write;

Return true if the current user can overwrite the given file.

=cut

sub can_write
  {
    return 0;
  }

=pod

=item $rv = $fileh->can_append

Return true if the current user can append to the given file.

=cut

sub can_append
  {
    return 0;
  }

=pod

=item $rv = $fileh->can_rename;

Return true if the current user can change the name of the given file.

=cut

sub can_rename
  {
    return 0;
  }

=pod

=item $rv = $fileh->can_delete;

Return true if the current user can delete the given file.

=cut

sub can_delete
  {
    return 0;
  }

1 # So that the require or use succeeds.

__END__

=back 4

=head1 AUTHORS

Richard Jones (rich@annexia.org).

=head1 COPYRIGHT

Copyright (C) 2000 Biblio@Tech Ltd., Unit 2-3, 50 Carnwath Road,
London, SW6 3EG, UK

=head1 SEE ALSO

L<Net::FTPServer(3)>, L<perl(1)>

=cut
