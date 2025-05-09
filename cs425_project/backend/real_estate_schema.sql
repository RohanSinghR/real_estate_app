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

CREATE TABLE neighborhood(  
    neighborhood_id INT NOT NULL,  
    crime_rate INT NOT NULL, 
    nearby_schools INT NOT NULL,  
    PRIMARY KEY (neighborhood_id)
);
CREATE TABLE Renter(  
    renter_details INT NOT NULL,  
    preferred_location VARCHAR(100) NOT NULL,  
    reward_points INT NOT NULL,  
    email VARCHAR(100) NOT NULL,  
    PRIMARY KEY (email),  
    FOREIGN KEY (email) REFERENCES Users(email)on delete cascade);

CREATE TABLE Agent(  
    phone_num INT NOT NULL,  
    Job_role VARCHAR(100) NOT NULL,  
    Agency VARCHAR(100) NOT NULL,  
    email VARCHAR(100) NOT NULL,  
    PRIMARY KEY (email),  
    FOREIGN KEY (email) REFERENCES Users(email)  on delete cascade
);

CREATE TABLE property(  
    price INT NOT NULL,  
    property_id INT NOT NULL,  
    type VARCHAR(15) CHECK (type in ('House','Property','Commercial_buildings','Vaction_homes','Land')),  
    availability DATE NOT NULL,  
    description VARCHAR(500) NOT NULL,  
    city VARCHAR(100) NOT NULL,  
    state VARCHAR(100)  NOT NULL,  
    neighborhood_id INT NOT NULL,  
    email VARCHAR(100) NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhood(neighborhood_id)on delete cascade,  
    FOREIGN KEY (email) REFERENCES Agent(email)on delete cascade
);

CREATE TABLE House(  
    num_rooms INT NOT NULL,  
    square_footage INT NOT NULL,  
    property_id INT NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id)on delete cascade
);

CREATE TABLE Commercial_buildings(  
    square_footage INT NOT NULL,  
    type_of_business VARCHAR(100) NOT NULL,  
    property_id INT NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id)on delete cascade
);

CREATE TABLE Vacation_homes(  
    num_rooms INT NOT NULL,  
    square_footage INT NOT NULL, 
    property_id INT NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id)on delete cascade
);

CREATE TABLE Land(  
    area INT NOT NULL,  
    property_id INT NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id)on delete cascade
);

CREATE TABLE Apartment(  
    num_rooms INT NOT NULL, 
    square_footage INT NOT NULL,  
    building_type VARCHAR(100) NOT NULL,  
    property_id INT NOT NULL,  
    PRIMARY KEY (property_id),  
    FOREIGN KEY (property_id) REFERENCES property(property_id)on delete cascade
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
    FOREIGN KEY (card_number) REFERENCES Credit_Card(card_number)on delete cascade
);

CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_credit_email ON Credit_Card(email);
CREATE INDEX idx_address_card_number ON Address(card_number);
CREATE INDEX idx_renter_location ON Renter(preferred_location);
CREATE INDEX idx_agent_agency ON Agent(Agency);
CREATE INDEX idx_agent_job_role ON Agent(Job_role);
CREATE INDEX idx_agent_phone_num ON Agent(phone_num);
CREATE INDEX idx_property_neighborhood ON property(neighborhood_id);
CREATE INDEX idx_property_city ON property(city);
CREATE INDEX idx_property_state ON property(state);
CREATE INDEX idx_property_email ON property(email);
CREATE INDEX idx_property_availability ON property(availability);
CREATE INDEX idx_booking_date ON Booking(date);
CREATE INDEX idx_renter_reward_points ON Renter(reward_points);
CREATE INDEX idx_neighborhood_crime_rate ON neighborhood(crime_rate);
CREATE INDEX idx_property_type ON property(type);
CREATE INDEX idx_booking_email ON Booking(email);
CREATE INDEX idx_booking_card_number ON Booking(card_number);
