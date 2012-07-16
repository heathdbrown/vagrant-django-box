# Taken from https://gist.github.com/701221
stage { "pre": before => Stage["main"] }				    
class python {
	package {							       
		"build-essential": ensure => latest;				
		"python": ensure => "2.6.6-2ubuntu1";			       
		"python-dev": ensure => "2.6.6-2ubuntu1";			   
		"python-setuptools": ensure => "latest";			    
	}   
	exec { "easy_install pip":					      
		path => "/usr/local/bin:/usr/bin:/bin",			     
		refreshonly => true,						
		require => Package["python-setuptools"],			    
		subscribe => Package["python-setuptools"],			  
	}								       
}									   
class { "python": stage => "pre" }

package {
	"django":
		ensure => "1.2.3",
		provider => pip;
	"libmysqlclient-dev":
		ensure => "5.1.49-1ubuntu8.1";
	"mysql-python":
		ensure => "1.2.3",
		provider => pip,
		require => Package["libmysqlclient-dev"];
}

package { "fabric":
	ensure => "0.9.3",
	provider => pip,
}

package { "south":
	ensure => "0.7.2",
	provider => pip,
}

package {
	"apache2-mpm-worker":
		ensure => "2.2.16-1ubuntu3";
	"libapache2-mod-wsgi":
		ensure => "3.2-2";
}

file {
	"/etc/apache2/sites-available/mysite":
		content => template("mysite.erb"),
		ensure => file,
		require => Package["apache2-mpm-worker"];
	"/etc/apache2/sites-enabled/001-mysite":
		ensure => "/etc/apache2/sites-available/mysite",
		require => Package["apache2-mpm-worker"];
	"/etc/apache2/sites-enabled/000-default":
		ensure => absent,
		require => Package["apache2-mpm-worker"];
	"/usr/local/share/wsgi/mysite/mysite.wsgi":
		content => template("mysite.wsgi.erb"),
		ensure => file;
}

service { "apache2":
	enable => true,
	ensure => running,
	require => Package["apache2-mpm-worker"],
	subscribe => [
		Package[
			"apache2-mpm-worker",
			"libapache2-mod-wsgi"],
		File[
			"/etc/apache2/sites-available/mysite",
			"/etc/apache2/sites-enabled/001-mysite",
			"/etc/apache2/sites-enabled/000-default",
			"/usr/local/share/wsgi/mysite/mysite.wsgi"]],
}