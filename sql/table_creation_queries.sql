CREATE TABLE Routes (
    route_id VARCHAR(255) PRIMARY KEY,
    route_type INT,
    route_color CHAR(6),
    route_long_name VARCHAR(255)
);

CREATE TABLE Stops (
    stop_id INT PRIMARY KEY,
    stop_name VARCHAR(255),
    stop_lat REAL,
    stop_lon REAL
);

CREATE TABLE Calendar (
    service_id VARCHAR(255) PRIMARY KEY,
    monday INT,
    tuesday INT,
    wednesday INT,
    thursday INT,
    friday INT,
    saturday INT,
    sunday INT,
    start_date DATE,
    end_date DATE
);

CREATE TABLE Frequencies (
    trip_id VARCHAR(255),
    start_time TIME,
    end_time TIME,
    headway_secs INT,
    PRIMARY KEY (trip_id, start_time, end_time),
    FOREIGN KEY(trip_id) REFERENCES Trips(trip_id)
);

CREATE TABLE Trips (
    trip_id VARCHAR(255) PRIMARY KEY,
    route_id VARCHAR(255),
    service_id VARCHAR(255),
    trip_headsign VARCHAR(255),
    direction_id INT,
    FOREIGN KEY(route_id) REFERENCES Routes(route_id),
    FOREIGN KEY(service_id) REFERENCES Calendar(service_id)
);

CREATE TABLE StopTimes (
    trip_id VARCHAR(255),
    stop_sequence INT,
    stop_id INT,
    arrival_time TIME,
    departure_time TIME,
    PRIMARY KEY (trip_id, stop_sequence),
    FOREIGN KEY(trip_id) REFERENCES Trips(trip_id),
    FOREIGN KEY(stop_id) REFERENCES Stops(stop_id)
);

CREATE TABLE Users (
    user_id VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255),
    password VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255)
);

CREATE TABLE Paths (
    path_id VARCHAR(255) PRIMARY KEY,
    trip_id VARCHAR(255),
    departure_sequence INT,
    arrival_sequence INT,
    departure_time TIME,
    arrival_time TIME,
    popularity VARCHAR(255),

    FOREIGN KEY(trip_id, departure_sequence) REFERENCES StopTimes(trip_id, stop_sequence),
    FOREIGN KEY(trip_id, arrival_sequence) REFERENCES StopTimes(trip_id, stop_sequence)
);

CREATE TABLE Saved (
    user_id VARCHAR(255),
    path_id VARCHAR(255),
    color CHAR(6),
    PRIMARY KEY (user_id, path_id),
    FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(path_id) REFERENCES Paths(path_id)
);