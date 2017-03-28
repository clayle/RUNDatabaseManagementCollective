/*Clayton Szelestey, 3/28/17, Lab 8*/
/*Part 2*/
CREATE TABLE IF NOT EXISTS People(
    PID INT NOT NULL,
    Name TEXT,
    Address TEXT,
    Spouse_Name TEXT,
    PRIMARY KEY(PID)
);

CREATE TABLE IF NOT EXISTS Actors(
    PID INT NOT NULL REFERENCES People(PID),
    Birthdate DATE,
    Hair_Color TEXT,
    Eye_Color TEXT,
    Height_in_Inches NUMERIC, 
    Weight INT,
    Favorite_Color TEXT,
    SAGA_Date DATE,
    PRIMARY KEY(PID)
);

CREATE TABLE IF NOT EXISTS Directors(
    PID INT NOT NULL REFERENCES People(PID),
    Film_School_Attnd BOOL,
    DGA_Date DATE,
    Favorite_Lens_Maker Text,
    PRIMARY KEY(PID)
);

CREATE TABLE IF NOT EXISTS Movies(
    MID INT NOT NULL,
    Name TEXT,
    Release_Year INT,
    MPAA_Number INT,
    Dom_Box_Office_Sales MONEY,
    For_Box_Office_Sales MONEY,
    DVD_Bluray_Sales MONEY,
    PRIMARY KEY(MID)
);

CREATE TABLE IF NOT EXISTS Movie_Directors(
    PID INT NOT NULL REFERENCES Directors(PID),
    MID INT NOT NULL REFERENCES Movies(MID),
    PRIMARY KEY(PID, MID)
);

CREATE TABLE IF NOT EXISTS Movie_Actors(
    PID INT NOT NULL REFERENCES Actors(PID),
    MID INT NOT NULL REFERENCES Movies(MID),
    PRIMARY KEY(PID, MID)
);

/* Part 4 */
SELECT DISTINCT Name
FROM People
WHERE PID in(
      SELECT PID
      FROM Movie_Directors
      WHERE MID in(
            SELECT MID
            FROM Movie_Actors
            WHERE PID in(
                  SELECT PID
                  FROM People
                  WHERE Name = 'Sean Connery'
                )
          )
    );