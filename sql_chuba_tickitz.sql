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
-- use real id movies from TMDB
alter table movies
alter column id type int;
-- undo, change with my own id 
CREATE SEQUENCE movies_id_seq;
alter table movies
alter column id SET DEFAULT nextval('movies_id_seq');
-- change timestamp to date (column release_date)
alter table movies
alter column release_date type date;

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
-- ======================= { ADD DUMMY DATA } ==========================
-- =====================================================================
insert into genres (id, name)
values (28, 'Action'),
  (12, 'Adventure'),
  (16, 'Animation'),
  (35, 'Comedy'),
  (80, 'Crime'),
  (99, 'Documentary'),
  (18, 'Drama'),
  (10751, 'Family'),
  (14, 'Fantasy'),
  (36, 'History'),
  (27, 'Horror'),
  (10402, 'Music'),
  (9648, 'Mystery'),
  (10749, 'Romance'),
  (878, 'Science Fiction'),
  (10770, 'TV Movie'),
  (53, 'Thriller'),
  (10752, 'War'),
  (37, 'Western');

insert into directors(name)
values ('Kazuya Tsurumaki');

insert into movies(poster_path, backdrop_path, title, overview, release_date, duration, director_id)
  values ('/9FO1K6oKygac3j7LXLrIcG2Sz71.jpg', '/tiLGwBZ499pYvgYnJA5cI2ZAEbB.jpg', 'Mobile Suit Gundam GQuuuuuuX -Beginning-',
  'High-school student Amate Yuzuriha lives peacefully in a space colony floating in outer space. But when she meets a war refugee named Nyaan, Amate is drawn into the illegal mobile suit dueling sport known as Clan Battle. Theatrical compilation of the first few episodes of Mobile Suit Gundam GQuuuuuuX.',
  '2025-01-17', 80, 1);

insert into genres_movies(genre_id, movie_id)
  values (16, 1),
  (28, 1),
  (878, 1),
  (18, 1);


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

