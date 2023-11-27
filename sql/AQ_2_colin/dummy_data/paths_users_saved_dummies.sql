INSERT INTO Users(user_id,email,password,first_name,last_name) 
VALUES
('1','bsmith@gmail.com','pass123','Bob','Smith');

INSERT INTO Paths(path_id,trip_id,departure_sequence,arrival_sequence,departure_time,arrival_time)
VALUES
    ('1','1021-10-0',2,13,'12:01:22','12:16:24'),
    ('2','1177-31-1',3,5,'17:04:08','17:08:16'),
    ('3','1178-32-0',8,10,'07:10:30','07:13:30'),
    ('4','1783-10-1',5,13,'16:05:00','16:15:00'),
    ('5','1783-22-0',7,12,'06:39:00','06:46:30'),
    ('6','573T-31-0',4,14,'16:04:33','16:19:43'),
    ('7','6002-10-0',9,11,'07:13:36','07:17:00'),
    ('8','6008-41-0',7,8,'05:10:00','05:11:40'),
    ('9','6020-10-0',6,13,'17:12:20','17:29:36'),
    ('10','6052-31-0',3,10,'05:02:30','05:11:15'),
    ('11','607M-10-1',7,14,'17:15:30','17:33:35'),
    ('12','6250-10-0',9,12,'07:13:28','07:18:31'),
    ('13','637G-10-0',4,10,'07:05:54','07:17:42'),
    ('14','637G-10-1',5,9,'17:08:48','17:17:36'),
    ('15','637J-10-0',11,14,'07:20:20','07:26:26'),
    ('16','6400-10-0',4,7,'17:06:42','17:13:24'),
    ('17','6422-10-0',8,13,'17:14:56','17:25:36'),
    ('18','6475-10-0',3,14,'17:04:36','17:29:54'),
    ('19','6475-10-1',7,9,'17:16:06','17:21:28'),
    ('20','675G-41-0',5,14,'06:07:04','06:22:58'),
    ('21','675G-41-1',6,12,'17:10:00','17:22:00'),
    ('22','6801-51-0',3,8,'16:02:14','16:07:49'),
    ('23','6801-51-1',6,11,'16:07:15','16:14:30'),
    ('24','6805-31-0',7,12,'06:12:12','06:22:22'),
    ('25','6805-31-1',10,14,'17:16:30','17:23:50'),
    ('26','6835-31-0',4,11,'18:05:18','18:17:40'),
    ('27','6835-31-1',5,10,'18:07:08','18:16:03'),
    ('28','6913-21-0',6,12,'16:12:40','16:27:52'),
    ('29','695Y-21-0',3,8,'07:33:16','07:41:26'),
    ('30','695Y-21-1',9,14,'08:14:40','08:23:50'),
    ('31','695Y-41-1',7,10,'22:38:24','22:40:06'),
    ('32','6L04-41-0',5,9,'05:06:00','05:12:00'),
    ('33','6L04-41-1',4,12,'07:04:45','07:17:25'),
    ('34','6L04-42-0',3,13,'04:02:56','04:17:36'),
    ('35','6L04-42-1',8,11,'07:55:37','08:00:10'),
    ('36','7005-10-0',7,10,'18:11:00','18:16:30'),
    ('37','701U-10-0',6,12,'07:09:35','07:21:05'),
    ('38','701U-10-1',9,14,'16:17:20','16:28:10'),
    ('39','7021-10-0',5,11,'07:08:32','07:21:20'),
    ('40','7021-10-1',3,12,'18:03:32','18:19:26'),
    ('41','7022-10-0',6,9,'07:12:00','07:19:12');
    
INSERT INTO Saved(user_id,path_id,color)
VALUES
    ('1','1','04263F'),
    ('1','2','8D918D'),
    ('1','3','C211EA'),
    ('1','4','AFEEEC'),
    ('1','5','6F0C71'),
    ('1','6','F82940'),
    ('1','7','88C2D2'),
    ('1','8','90C14F'),
    ('1','9','903F5D'),
    ('1','10','1A5509'),
    ('1','11','D06687'),
    ('1','12','FC199E'),
    ('1','13','309AF6'),
    ('1','14','E706F3'),
    ('1','15','A88A40'),
    ('1','16','EB6EEC'),
    ('1','17','BD2FA0'),
    ('1','18','ECEAFE'),
    ('1','19','8A405C'),
    ('1','20','F48C74'),
    ('1','21','1EC47F'),
    ('1','22','E90C06'),
    ('1','23','464DD0'),
    ('1','24','F45312'),
    ('1','25','09FE2B'),
    ('1','26','519B41'),
    ('1','27','9C3107'),
    ('1','28','4E90F1'),
    ('1','29','418D43'),
    ('1','30','8D58B3'),
    ('1','31','6F4163'),
    ('1','32','CC3595'),
    ('1','33','C435E4'),
    ('1','34','4497DA'),
    ('1','35','46FFE8'),
    ('1','36','9CF69A'),
    ('1','37','24A1E4'),
    ('1','38','4CD4B2'),
    ('1','39','5D6EF9'),
    ('1','40','C2CE6D'),
    ('1','41','995438');