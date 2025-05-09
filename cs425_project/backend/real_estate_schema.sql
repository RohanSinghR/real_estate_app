CREATE TABLE Users(  
    email VARCHAR(100) NOT NULL, 
    address VARCHAR(200) NOT NULL,
    PRIMARY KEY (email)
);

CREATE TABLE Credit_Card(
    card_number INT NOT NULL,  
    cvv INT NOT NULL,  
    billing_address VARCHAR(200) NOT NULL,  
    expiry_date DATE NOT NULL,  email 
    VARCHAR(100) NOT NULL,  
    PRIMARY KEY (card_number),  
    FOREIGN KEY (email) REFERENCES Users(email) on delete cascade
);

CREATE TABLE Address(  
    zipcode INT NOT NULL,  
    state VARCHAR(100) NOT NULL,  
    city VARCHAR(100) NOT NULL,  
    street VARCHAR(100) NOT NULL,  
    address_id INT NOT NULL,  
    card_number INT NOT NULL,  
    PRIMARY KEY (address_id),  
    FOREIGN KEY (card_number) REFERENCES Credit_Card(card_number) on delete cascade
);

CREATE TABLE Renter(  
    renter_details INT NOT NULL,  
    preferred_location VARCHAR(100) NOT NULL,  
    reward_points INT NOT NULL,  
    email VARCHAR(100) NOT NULL,  
    PRIMARY KEY (email),  
    FOREIGN KEY (email) REFERENCES Users(email));

CREATE TABLE property(  
    price INT NOT NULL,  
    property_id INT NOT NULL,  
    type INT NOT NULL,  
    availability DATE NOT NULL,  
    description VARCHAR(500) NOT NULL,  
    city VARCHAR(100) NOT NULL,  
    state VARCHAR(100)  NOT NULL,  
    neighborhood_id INT NOT NULL,  
    email VARCHAR(100) NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhood(neighborhood_id),  
    FOREIGN KEY (email) REFERENCES Agent(email)
);

CREATE TABLE House(  
    num_rooms INT NOT NULL,  
    square_footage INT NOT NULL,  
    property_id INT NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id)
);

CREATE TABLE Commercial_buildings(  
    square_footage INT NOT NULL,  
    type_of_business VARCHAR(100) NOT NULL,  
    property_id INT NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id)
);

CREATE TABLE Vacation_homes(  
    num_rooms INT NOT NULL,  
    square_footage INT NOT NULL, 
    property_id INT NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id)
);

CREATE TABLE Land(  
    area INT NOT NULL,  
    property_id INT NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id)
);

CREATE TABLE Apartment(  
    num_rooms INT NOT NULL, 
    square_footage INT NOT NULL,  
    building_type VARCHAR(100) NOT NULL,  
    property_id INT NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id)
);

CREATE TABLE Booking(  
    booking_id INT NOT NULL,  
    payment_method VARCHAR(100) NOT NULL,  
    date DATE NOT NULL,  
    property_id INT NOT NULL,  
    email VARCHAR(100) NOT NULL,  
    card_number INT NOT NULL,  
    PRIMARY KEY (booking_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id),  
    FOREIGN KEY (email) REFERENCES Renter(email),  
    FOREIGN KEY (card_number) REFERENCES Credit_Card(card_number)
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_agents_user_id ON agents(user_id);
CREATE INDEX IF NOT EXISTS idx_renters_user_id ON renters(user_id);
CREATE INDEX IF NOT EXISTS idx_login_logs_user_id ON login_logs(user_id);
