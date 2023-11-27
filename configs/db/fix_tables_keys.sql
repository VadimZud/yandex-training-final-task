ALTER TABLE movies ADD PRIMARY KEY (id);
ALTER TABLE customers ADD PRIMARY KEY (id);
ALTER TABLE sessions ADD PRIMARY KEY (id);
ALTER TABLE sessions ADD CONSTRAINT fk_sessions_customers FOREIGN KEY (customer_id) REFERENCES customers (id);
ALTER TABLE sessions ADD CONSTRAINT fk_sessions_movies FOREIGN KEY (movie_id) REFERENCES movies (id);