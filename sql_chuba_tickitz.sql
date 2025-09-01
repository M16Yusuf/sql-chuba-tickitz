-- =====================================================================  
-- ====================== {Create all tables} ==========================
-- =====================================================================  
create table genres (
	id serial primary key,
	name varchar(25) not null
);
-- alter genres, add id manual not using serial
alter table genres 
alter column id type int;

create table actors (
	id serial primary key,
	name varchar(50) not null
);

create table directors (
	id serial primary key,
	name varchar(50) not null
);

create table movies (
	id serial primary key,
	poster_path varchar(100),
	backdrop_path varchar(100),
	title varchar(70),
	overview text,
	release_date timestamp,
	duration int,
	director_id int references directors(id)
);

create table genres_movies(
	genre_id int references genres(id),
	movie_id int references movies(id)
);

create table actors_movies(
	movie_id int references movies(id),
	actor_id int references actors(id)
);

create table schedules (
	id serial primary key,
	schedule timestamp,
	movie_id int references movies(id)
);

create type gender as enum ('female', 'male');

create type user_role as enum ('user', 'admin');

create table users(
	id serial primary key,
	first_name varchar(25),
	last_name varchar(25),
	avatar_path varchar(100),
	email varchar(20),
	point int,
	role user_role,
	phone_number varchar(20),
	password varchar(20),
	gender gender
);

-- alter table users, add some default value
alter table users 
alter column first_name set default 'user',
alter column last_name set default 'user',
alter column role  set default 'user',
alter column point set default 0;

create table city(
	id serial primary key,
	name varchar (50)
);

alter table city rename to cities;

create table cinema(
	id serial primary key,
	name varchar (50)
);

alter table cinema rename to cinemas;

create table payment(
	id serial primary key,
	method varchar(25)
);

alter table payment rename to payments;

create table seats (
	id serial primary key,
	code varchar(3),
	is_book bool default false
);

create table transactions(
	id serial primary key,
	code_ticket text,
	user_id int references users(id),
	movies_id int references movies(id),
	city_id int references city(id),
	cinema_id int references cinema(id),
	schedule_id int references schedules(id),
	payment_id int references payment(id),
	is_paid bool default false,
	paid_at timestamp,
	total_price float,
	created_at timestamp,
	rating float
);

create table order_seat(
	seat_id int references seats(id),
	transaction_id int references transactions(id)
);


-- =====================================================================  
-- ==================== {USED QUERY FOR PROJECT} =======================
-- ===================================================================== 

-- SQL untuk login,  
select email, password, role,  from users where email="email";

-- SQL For register 
-- dapatkan semua email yang sudah terdaftar (untuk validasi)
select email from users;
-- insert user baru jika validasi terpenuhi 
insert into users (email, password)
  values('example@mail.com', 'test-hehe');

