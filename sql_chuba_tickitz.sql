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

-- SQL untuk Upcoming movies 
-- upcoming, movie yang release datenya masih dimasadepan
SELECT m.id, m.poster_path, m.title, m.release_date, ARRAY_AGG(g.name) AS genres
  FROM movies m
  JOIN genres_movies gm ON m.id = gm.movie_id
  JOIN genres g ON gm.genre_id = g.id
  WHERE m.release_date > CURRENT_DATE
  GROUP BY m.id, m.poster_path, m.title, m.release_date;

-- SQL untuk popular Movie
-- popular movie sort berdasarkan rating
SELECT m.id, m.poster_path, m.title, g.name AS genres, AVG(t.rating) AS avg_rating, COUNT(t.id) AS rating_count
  FROM movies m
  JOIN transactions t ON m.id = t.movies_id
  JOIN genres_movies gm ON m.id = gm.movie_id
  JOIN genres g ON gm.genre_id = g.id
  WHERE t.is_paid = true AND t.rating IS NOT NULL
  GROUP BY m.id, m.poster_path, m.title, g.name
  ORDER BY avg_rating DESC, rating_count DESC;

-- SQL Movie dengan PAGENATION
-- limit data dalam sekali query adalah 20
-- dengan offset sebagai pagenation (page1=0,page2=20,page3=40)
SELECT m.id, m.poster_path, m.title, ARRAY_AGG(g.name) AS genres
  FROM movies m
  JOIN genres_movies gm ON m.id = gm.movie_id
  JOIN genres g ON gm.genre_id = g.id
  GROUP BY m.id, m.poster_path, m.title
  LIMIT 20 OFFSET 0;

-- SQL movie filter by title and genres with pagenation
SELECT m.id, m.poster_path, m.title, ARRAY_AGG(DISTINCT g.name) AS genres
  FROM movies m
  JOIN genres_movies gm ON m.id = gm.movie_id
  JOIN genres g ON gm.genre_id = g.id
  WHERE m.title ILIKE '%avenger%'
  GROUP BY m.id, m.poster_path, m.title
  HAVING ARRAY_AGG(DISTINCT g.name)::text[] @> ARRAY['Action', 'Sci-Fi']::text[]
  LIMIT 20 OFFSET 0;

-- SQL untuk get Schedule 
-- asumsukan untuk tiap kota dan cinema memiliki schedule yang sama
-- mendapatkan schedule untuk movie tertentu dengan id yang sudah diketahui
SELECT m.id AS movie_id, m.title, s.id AS schedule_id, s.schedule
  FROM movies m
  JOIN schedules s ON m.id = s.movie_id
  WHERE m.id = 1
  ORDER BY s.schedule ASC;

-- SQL untuk seats yang sudah terjual
-- mendapatkan data seat yang sudah terjual dari satu schedule movies
SELECT sch.id AS schedule_id, m.title AS movie_title, sch.schedule, s.code AS seat_code, t.id AS transaction_id, t.is_paid
  FROM schedules sch
  JOIN movies m ON sch.movie_id = m.id
  JOIN transactions t ON sch.id = t.schedule_id
  JOIN order_seat os ON t.id = os.transaction_id
  JOIN seats s ON os.seat_id = s.id
  WHERE sch.id = 1 AND t.is_paid = true
  ORDER BY s.code ASC;

-- SQL get movie detail
-- detail dari sebuah movie dengan movie id yang sudah diketaui
SELECT m.id, m.title, m.overview, m.poster_path, m.backdrop_path, m.release_date, m.duration, d.name AS director_name, ARRAY_AGG(DISTINCT g.name) AS genres, ARRAY_AGG(DISTINCT a.name) AS actors
  FROM movies m
  JOIN directors d ON m.director_id = d.id
  LEFT JOIN genres_movies gm ON m.id = gm.movie_id
  LEFT JOIN genres g ON gm.genre_id = g.id
  LEFT JOIN actors_movies am ON m.id = am.movie_id
  LEFT JOIN actors a ON am.actor_id = a.id
  WHERE m.id = 1
  GROUP BY m.id, m.title, m.overview, m.poster_path, m.backdrop_path, m.release_date, m.duration, d.name;

-- SQL Create order 


-- SQL get profile
SELECT first_name, last_name, avatar_path, email, phone_number, password, point, gender
  FROM users WHERE email = 'email';

-- SQL get History
SELECT
  t.*, -- semua kolom dari tabel transactions
  m.title AS movie_title, sch.schedule AS schedule_time, p.method AS payment_method,
  c.name AS cinema_name, ci.name AS city_name, ARRAY_AGG(s.code) AS seat_codes
  FROM transactions t
  JOIN movies m ON t.movies_id = m.id
  JOIN schedules sch ON t.schedule_id = sch.id
  JOIN payments p ON t.payment_id = p.id
  JOIN cinemas c ON t.cinema_id = c.id
  JOIN cities ci ON t.city_id = ci.id
  JOIN order_seat os ON t.id = os.transaction_id
  JOIN seats s ON os.seat_id = s.id
  WHERE t.user_id = 1
  GROUP BY t.id, m.title, sch.schedule, p.method, c.name, ci.name
  ORDER BY t.created_at DESC;

-- SQL Edit profile 
UPDATE users
  SET first_name = 'Muhammad', last_name = 'Yusuf', email = 'yusufsmd@example.com', gender = 'male',
  phone_number = '+62-82240563847', avatar_path = '/images/ucup.jpg', point = 150,
  role = 'admin', password = '112233admin'
  WHERE id = 1;



-- SQL Get All movie (Admin)


-- SQL Delete Movie (Admin)


-- Edit Movie (Admin)