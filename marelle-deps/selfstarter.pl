%
%  selfstarter.pl
%  selfstarter-vm
%
%  Dependencies for setting up selfstarter on Ubuntu 12.04.
%
%  Follows instructions from:
%  http://docs.selfstarter.org/en/latest/install-from-package.html
%

meta_pkg(selfstarter, [
    'selfstarter checked out',
    'ruby dependencies installed',
    'initialise database',
    'server set up with supervisor'
]).

pkg('selfstarter checked out').
met('selfstarter checked out', linux(_)) :-
    isdir('/home/vagrant/selfstarter').
meet('selfstarter checked out', linux(_)) :-
    bash('sudo -u vagrant git clone https://github.com/larsyencken/selfstarter /home/vagrant/selfstarter').

managed_pkg('ruby1.9.3').
managed_pkg('build-essential').
managed_pkg('libsqlite3-dev').
managed_pkg('nodejs').

pkg('ruby dependencies installed').
met('ruby dependencies installed', linux(_)) :-
    isfile('/home/vagrant/selfstarter/.rubydeps-installed').
meet('ruby dependencies installed', linux(_)) :-
    bash('sudo gem1.9.3 install bundler'),
    bash('cd /home/vagrant/selfstarter && bundle install --without production'),
    bash('touch /home/vagrant/selfstarter/.rubydeps-installed').
depends('ruby dependencies installed', linux(_), [
    'ruby1.9.3',
    'libsqlite3-dev',
    'build-essential'
]).

pkg('initialise database').
met('initialise database', linux(_)) :-
    isfile('/home/vagrant/selfstarter/db/development.sqlite3').
meet('initialise database', linux(_)) :-
    bash('cd ~/selfstarter && rake db:migrate').
depends('initialise database', linux(_), ['nodejs']).

pkg('server set up with supervisor').
met('server set up with supervisor', linux(_)) :-
    isfile('/etc/supervisor/conf.d/selfstarter.conf'),
    bash('diff -q /vagrant/config/selfstarter.conf /etc/supervisor/conf.d/selfstarter.conf').
meet('server set up with supervisor', linux(_)) :-
    bash('sudo cp -f /vagrant/config/selfstarter.conf /etc/supervisor/conf.d/selfstarter.conf'),
    bash('sudo supervisorctl reload').
depends('server set up with supervisor', linux(_), [
    supervisor
]).

managed_pkg(supervisor).
