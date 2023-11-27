var express = require('express');
const session = require('express-session');
var bodyParser = require('body-parser');
var mysql = require('mysql2');
var path = require('path');
const { copyFileSync } = require('fs');
var connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: process.env.dbpassword,
  database: 'pt1_db'
});

connection.connect;

var app = express();

// Set up express-session middleware
// use the req.session.user to store and access user-specific data across requests.
app.use(session({
  secret: 'cs411-team010-SQLlegend', // Replace with a random secret key
  resave: false,
  saveUninitialized: true
}));

// set up ejs view engine
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(express.static(__dirname + '../public'));


/* GET home page, respond by rendering index.ejs */
app.get('/', function (req, res) {
  // Check if the user is logged in by accessing the "user" property from the session
  const cur_user = req.session.user;
  const searchedPaths = req.session.searchedPaths;
  const start = req.session.start;
  const destination = req.session.destination;

  // Check if the user is logged in. If yes, fetch the saved paths for the current user.
  if (cur_user) {
    const userId = cur_user.user_id;

    // Query to fetch the saved paths data for the current user from the database
    // To be optimized
    const sql = `
      SELECT s.color, p.path_id, s1.stop_name AS departure_stop, s2.stop_name AS arrival_stop, p.departure_time, p.arrival_time, 
      monday, tuesday, wednesday, thursday, friday, saturday, sunday,
      p.popularity
      FROM Saved s
      JOIN Paths p ON (s.path_id = p.path_id)
      JOIN (SELECT trip_id, service_id FROM Trips) T ON (p.trip_id = T.trip_id)
      JOIN StopTimes st_dep ON (p.departure_sequence=st_dep.stop_sequence AND st_dep.trip_id=p.trip_id)
      JOIN StopTimes st_arr ON (p.arrival_sequence=st_arr.stop_sequence AND st_arr.trip_id=p.trip_id)
      JOIN Stops s1 ON (s1.stop_id=st_dep.stop_id)
      JOIN Stops s2 ON (s2.stop_id=st_arr.stop_id)
      JOIN Calendar ON (T.service_id = Calendar.service_id)
      WHERE s.user_id = ?
      ORDER BY p.departure_time;
    `;

    connection.query(sql, [userId], function (err, savedPaths) {
      if (err) {
        res.send(err);
        return;
      }
      // console.log("Current saved paths: ", savedPaths);
      // console.log("Current searched paths: ", searchedPaths);
      // Render the index page with the updated savedPaths data
      res.render('index', { 
      title: 'TripExpert', 
      cur_user: cur_user, 
      savedPaths: savedPaths,
      searchedPaths: searchedPaths,
      start: start,
      destination: destination});
    });
  } else {
    // If the user is not logged in, render the home page without saved paths data
    res.render('index', {
    title: 'TripExpert',
    cur_user: cur_user,
    searchedPaths: searchedPaths,
    start: start,
    destination: destination});
  }
});

app.post('/deleteSavedPath', function (req, res) {
  const pathIdToDelete = req.body.path_id;
  const cur_user = req.session.user;
  const userId = cur_user.user_id;

  // Perform the deletion of the saved path from the Saved table based on path_id and user_id
  const sql = `DELETE FROM Saved WHERE path_id = ? AND user_id = ?`;

  connection.query(sql, [pathIdToDelete, userId], function (err, result) {
    if (err) {
      res.send(err);
      return;
    }

    console.log(`Deleted saved path with path_id ${pathIdToDelete} for user ${userId}`);
    // Redirect to the home page after successful deletion
    res.redirect('/');
  });
});

// Route to render the registration form
app.get('/register', function(req, res) {
  res.render('register');
});

app.get('/registrationSuccess', function(req, res) {
  res.render('registrationSuccess');
});

// Route to handle user registration
app.post('/register', function(req, res) {
  const { firstName, lastName, email, password } = req.body;
  const userid = firstName+lastName;

  // Insert new users to DB
  var sql = `
  INSERT INTO Users(user_id, email, password, first_name, last_name)
  VALUES (?, ?, ?, ?, ?);
  `
  connection.query(
    sql,
    [userid, email, password, firstName, lastName],
    function (err, result) {
      if (err) {
        res.send(err);
        return;
      }
      // Once registration is successful, redirect to the success page
      console.log("Registration Success!");
      res.redirect('/registrationSuccess');
    }
  );

});

// Route to render the login form
app.get('/login', function(req, res) {
  res.render('login');
});

// Route to handle user login
// Route to handle user login
app.post('/login', function(req, res) {
  const { email, password } = req.body;

  // (TODO:yangfei) Perform user login logic here, e.g., verify credentials from the database
  const sql = `
    SELECT * FROM Users WHERE email = ? AND password = ?
  `;

  connection.query(
    sql,
    [email, password],
    function(err, results) {
      if (err) {
        console.error(err);
        return res.send('Error occurred during login.');
      }

      if (results.length === 0) {
        return res.send('Invalid email or password. Please try again.');
      }

      // Store the user data in the session after successful login
      req.session.user = results[0];
      // Redirect to the home page or any other authenticated page
      res.redirect('/');
    }
  );
});


app.get('/logout', function(req, res) {
  req.session.user = null;
  res.redirect('/');
});

app.post('/stopSearch', function(req, res) {
  var stopid = req.body.stopid;
  var sql = 'SELECT stop_name FROM Stops WHERE stop_id = ?;';

  console.log(sql);
  connection.query(
    sql,
    [stopid], // insert the input here instead of directly into the string to prevent SQL injection
    function(err, result) {
    if (err) {
      res.send(err);
      return;
    }

    res.render('stopSearch', {stopNames: result, stopid: stopid});
  });
});

app.post('/stopNameSearch', function(req, res) {
  var stopname = req.body.stopname;
  var sql = `SELECT DISTINCT stop_name FROM Stops WHERE stop_name LIKE ?;`;
  
  connection.query(
    sql,
    ['%' + stopname + '%'], 
    function(err, result) {
    if (err) {
      res.send(err);
      return;
    }

    res.render('stopNameSearch', {stopNames: result, stopname: stopname});
  });
});

app.post('/planTrip', function(req, res) {
  const cur_user = req.session.user;
  var userID = "nonExist";

  if(cur_user){
    userID = cur_user.user_id;
  }

  const {start, destination, departure_time} = req.body;
  // Input: Name of start point, destination and departure time
  // e.g: R. Da Cooperação, 32; R. Vale Do Sol, 105; 18:30:00
  // Output: -> will be inserted into Paths table
  // -- trip_id
  // -- departure sequence
  // -- arrival sequence
  // -- departure time(in next 60 mimutes)
  // -- arrival time
  // -- wasAdded

  var sql = `SELECT
    st1.trip_id AS trip_id,
    st1.stop_sequence AS departure_sequence,
    st2.stop_sequence AS arrival_sequence,
    s1.stop_name AS departure_stop,
    s2.stop_name as arrival_stop,
    st1.departure_time AS departure_t,
    st2.arrival_time AS arrival_t,
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
    EXISTS (SELECT 1 
      FROM Saved sav JOIN Paths pa ON (sav.path_id = pa.path_id)
      WHERE pa.trip_id = st1.trip_id AND pa.departure_sequence = st1.stop_sequence AND pa.arrival_sequence = st2.stop_sequence AND sav.user_id = ?) 
      AS wasAdded
  FROM StopTimes st1
    JOIN StopTimes st2 USING(trip_id)
    JOIN Stops s1 ON (st1.stop_id = s1.stop_id)
    JOIN Stops s2 ON (st2.stop_id = s2.stop_id)
    JOIN (SELECT trip_id, service_id FROM Trips) T ON (st1.trip_id = T.trip_id)
    JOIN Calendar ON (T.service_id = Calendar.service_id)
  WHERE
    s1.stop_name = ? AND s2.stop_name = ?
    AND (TIME_TO_SEC(st1.departure_time)-TIME_TO_SEC(?))>=0 
    AND (TIME_TO_SEC(st1.departure_time)-TIME_TO_SEC(?))<=3600
    AND st1.stop_sequence < st2.stop_sequence
  ORDER BY (arrival_t - departure_t) ASC;`

  connection.query(
    sql,
    [userID, start, destination, departure_time, departure_time],
    function (err, searchedPaths) {
      if (err) {
        res.send(err);
        return;
      }
    
      console.log("Trip plan successfully!");
  
      req.session.searchedPaths = searchedPaths;
      req.session.start = start;
      req.session.destination = destination;

      res.json({ success: true });
      // res.redirect('/');
    }
  );
});

// Handler for addToMyTrip AJAX request
app.post('/addToMyTrip', function(req, res) {
  // const { trip_id, departure_sequence, arrival_sequence, departure_time, arrival_time } = req.body;
  const trip_id = req.body.trip_id;
  const departure_sequence = req.body.departure_sequence;
  const arrival_sequence = req.body.arrival_sequence;
  const departure_time = req.body.departure_time;
  const arrival_time = req.body.arrival_time;
  const cur_user = req.session.user;



  if(cur_user){
    const user_id = cur_user.user_id; 

    // Call the stored procedure
    const sql = 'CALL AddToMyTrip(?, ?, ?, ?, ?, ?)';
    const values = [trip_id, departure_sequence, arrival_sequence, departure_time, arrival_time, user_id];
    connection.query(sql, values, function(err, result) {
      if (err) {
          console.log("Failed to add to my trip!!!");
          console.log("SQL Query:", sql);
          console.log("Values:", values);
          res.status(500).json({ error: err.message });
          return;
      }
      console.log("Added to My Trip!");
      // res.json({ message: 'Added to My Trip!', success: true });
      res.redirect('/');
  });
  }
});


app.post('/tripSearch_aq1', function(req, res) {
  const {lat1, lon1, lat2, lon2, departure_time} = req.body;
  var sql = `SELECT
    st1.trip_id AS trip_id,
    st1.stop_sequence AS departure_sequence,
    st2.stop_sequence AS arrival_sequence,
    s1.stop_name AS departure_stop,
    s2.stop_name as arrival_stop,
    st1.departure_time AS departure_t,
    st2.arrival_time AS arrival_t,
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday
  FROM StopTimes st1
    JOIN StopTimes st2 USING(trip_id)
    JOIN Stops s1 ON (st1.stop_id = s1.stop_id)
    JOIN Stops s2 ON (st2.stop_id = s2.stop_id)
    JOIN (SELECT trip_id, service_id FROM Trips) T ON (st1.trip_id = T.trip_id)
    JOIN Calendar ON (T.service_id = Calendar.service_id)
  WHERE
    s1.stop_lat < ? + 0.001 AND s1.stop_lat > ? - 0.001
    AND s1.stop_lon < ? + 0.001 AND s1.stop_lon > ? - 0.001
    AND s2.stop_lat < ? + 0.001 AND s2.stop_lat > ? - 0.001
    AND s2.stop_lon < ? + 0.001 AND s2.stop_lon > ? - 0.001
    AND (TIME_TO_SEC(st1.departure_time)-TIME_TO_SEC(?))>=0 
    AND (TIME_TO_SEC(st1.departure_time)-TIME_TO_SEC(?))<=3600
    AND st1.stop_sequence < st2.stop_sequence
  ORDER BY (arrival_t - departure_t) ASC;`

  connection.query(
    sql,
    [lat1, lat1, lon1, lon1, lat2, lat2, lon2, lon2, departure_time, departure_time],
    function (err, result) {
      if (err) {
        res.send(err);
        return;
      }
    
      console.log("Trip plan successfully!");
      res.render('planTrip', {
        result: result,
        start: `(${lat1}, ${lon1})`,
        destination: `(${lat2}, ${lon2})`
      });
    }
  );
});

// aq2
app.post('/tripSearch_aq2', function(req, res) {
  const {monday, tuesday, wednesday, thursday, friday, saturday, sunday} = req.body;
  const cur_user = req.session.user;
  const userId = cur_user.user_id;

  var day_str = '';
  if (monday) { day_str += 'M'; }
  if (tuesday) { day_str += 'T'; }
  if (wednesday) { day_str += 'W'; }
  if (thursday) { day_str += 'R'; }
  if (friday) { day_str += 'F'; }
  if (saturday) { day_str += 'S'; }
  if (sunday) { day_str += 'U'; }

  var sql = `
    SELECT s.color, p.departure_sequence, p.arrival_sequence, p.departure_time, p.arrival_time
    FROM Paths p NATURAL JOIN Saved s
    WHERE s.user_id = ? AND p.path_id IN (
        SELECT p1.path_id 
        FROM Paths p1 NATURAL JOIN Trips t1 NATURAL JOIN Calendar c1
        WHERE (
            (? = 'true' AND c1.Monday = 1) OR
            (? = 'true' AND c1.Tuesday = 1) OR
            (? = 'true' AND c1.Wednesday = 1) OR
            (? = 'true' AND c1.Thursday = 1) OR
            (? = 'true' AND c1.Friday = 1) OR
            (? = 'true' AND c1.Saturday = 1) OR
            (? = 'true' AND c1.Sunday = 1)
        )
    );`
  
  connection.query(
    sql,
    [userId, monday, tuesday, wednesday, thursday, friday, saturday, sunday],
    function (err, result) {
      if (err) {
        res.send(err);
        return;
      }
      console.log("Trip search successfully!");

      res.render('tripSearch_aq2', {
        result: result,
        day_str: day_str
      });
    }
  );
});

// Route to render the "Update User" form
app.get('/updatePassword', function(req, res) {
  res.render('updatePassword');
});

// Route to handle updating the user data
app.post('/updatePassword', function(req, res) {
  const {input_email, input_old_password, new_password} = req.body;

  // used to check if the input password match the saved password
  var sqlSelect = `SELECT password FROM Users WHERE email = ?;`;

  // Execute the SELECT query to fetch the user's data from the database
  connection.query(
    sqlSelect,
    [input_email],
    function (err, results) {
      if (err) {
        res.send(err);
        return;
      }

      // Check if the user with the provided email and user_id exists
      if (results.length === 0) {
        console.log(results);
        return res.send('Invalid email.');
      }

      // Check if the provided old password matches the password stored in the database
      const storedPassword = results[0].password;
      if (input_old_password !== storedPassword) {
        return res.send('Invalid old password.');
      }

      // If the old password matches, proceed with updating the new password in the database
      var sqlUpdate = `
        UPDATE Users
        SET password = ?
        WHERE email = ?;
      `;

      connection.query(
        sqlUpdate,
        [new_password, input_email],
        function (err, result) {
          if (err) {
            res.send(err);
            return;
          }
          console.log("Password updated!");
          res.redirect('/'); // Redirect to the home page
        }
      );
    }
  );
});


// Route to handle closing the user account
app.post('/deleteAccount', function(req, res) {
  const cur_user = req.session.user;
  const userId = cur_user.user_id;

  console.log("User id: ", userId);
  // Perform account closure logic here, e.g., delete the user from the database
  // Use the "userId" to identify the user to be closed in the database and perform the necessary actions

  // Assuming you have a SQL DELETE statement to delete the user from the database
  var sql = `
    DELETE FROM Users
    WHERE user_id = ?;
  `;

  connection.query(
    sql,
    [userId],
    function (err, result) {
      if (err) {
        res.send(err);
        console.log(err);
        return;
      }
      console.log("User account closed!");
      req.session.user = null; // Remove the user from the session to log them out
      res.redirect('/'); // Redirect to the home page or any other appropriate page
    }
  );
});


const port = 80;
app.listen(port, () => {
  console.log(`TripExpert is running on port ${port}`);
});