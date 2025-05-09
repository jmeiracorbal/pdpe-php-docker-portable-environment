v0.2.0

- Added create-project.sh script to generate project + virtual host
- Moved user-generated vhosts to etc/docker/apache2/sites-available
- Dashboard vhost now handled via template
- Fixed Dockerfile to symlink all vhosts automatically
- General structure improvements and cleanup