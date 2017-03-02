# Demo Brainstorming Rails API application

This is a demo brainstorming rails JSON API application. At first an user makes a registration with an unique username. The login is done via username. After successful login an user can list all existing brainstorming trees, can add a new term to an existing brainstorming tree or create a new brainstorming tree.

![Kiku](doc/images/health.jpg)

The application was generated with `rails new brainstorm -d mysql -J -S --api`. Used technologies and versions:

* docker 1.13.1
* docker-compose 1.11.1
* mysql 5.7.17
* ruby 2.4.0
* rails 5.0.2

Start the application with `docker-compose up -d`. Generate test data with `docker-compose exec web rake db:seed`. The application run's on port 3000.
