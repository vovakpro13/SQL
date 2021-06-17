USE bank;

-- 1. +Вибрати усіх клієнтів, чиє ім'я має менше ніж 6 символів.
SELECT * FROM client WHERE LENGTH(FirstName) < 6;

-- 2. +Вибрати львівські відділення банку.+
SELECT * FROM department WHERE DepartmentCity = 'Lviv';

-- 3. +Вибрати клієнтів з вищою освітою та посортувати по прізвищу.
SELECT * FROM client WHERE Education = 'high' ORDER BY LastName;

-- 4. +Виконати сортування у зворотньому порядку над таблицею Заявка і вивести 5 останніх елементів.
SELECT * FROM application ORDER BY Sum DESC LIMIT 5;

-- 6. +Вивести клієнтів банку, які обслуговуються київськими відділеннями.
SELECT c.idClient, c.FirstName, c.LastName
FROM client c
JOIN department d ON d.idDepartment = c.Department_idDepartment
WHERE d.DepartmentCity = 'Kyiv';

-- 7. +Вивести імена клієнтів та їхні номера телефону, погрупувавши їх за іменами.
-- номеру телефону то нема)
SELECT FirstName, LastName
FROM client
GROUP BY FirstName;

-- 8. +Вивести дані про клієнтів, які мають кредит більше ніж на 5000 тисяч гривень.
SELECT * FROM client c
JOIN application ap ON  c.idClient = ap.Client_idClient
WHERE Sum > 5000;

-- 9. +Порахувати кількість клієнтів усіх відділень та лише львівських відділень.
SELECT
COUNT(*) AS AllClients
FROM client
WHERE Department_idDepartment IN (SELECT idDepartment FROM department);

SELECT
COUNT(*) AS LvivClients
FROM client c
WHERE Department_idDepartment
IN (SELECT idDepartment FROM department WHERE DepartmentCity = 'Lviv');

-- 10. Знайти кредити, які мають найбільшу суму для кожного клієнта окремо.
SELECT
c.FirstName,
MAX(Sum)
FROM application ap
JOIN client c ON c.idClient = ap.Client_idClient
GROUP BY Client_idClient;

-- 11. Визначити кількість заявок на крдеит для кожного клієнта.
SELECT
c.FirstName,
COUNT(*)
FROM application ap
JOIN client c ON c.idClient = ap.Client_idClient
GROUP BY Client_idClient;

-- 12. Визначити найбільший та найменший кредити.
SELECT
MAX(Sum) MaxCredit, MIN(Sum) MinCredit
FROM application ;

-- 13. Порахувати кількість кредитів для клієнтів,які мають вищу освіту.
SELECT
c.FirstName,
COUNT(*)
FROM application ap
JOIN client c ON c.idClient = ap.Client_idClient
WHERE c.Education = 'high'
GROUP BY Client_idClient;

-- 14. Вивести дані про клієнта, в якого середня сума кредитів найвища.
SELECT
c.FirstName, c.LastName, c.Education, c.Passport,
AVG(Sum) avg
FROM application ap
JOIN client c ON c.idClient = ap.Client_idClient
GROUP BY Client_idClient
ORDER BY avg DESC
LIMIT 1;

-- 15. Вивести відділення, яке видало в кредити найбільше грошей
SELECT idDepartment, DepartmentCity, SUM(ap.Sum) sum
FROM department d
JOIN client c ON c.Department_idDepartment = d.idDepartment
JOIN application ap ON c.idClient = ap.Client_idClient
group by d.idDepartment
ORDER BY sum DESC LIMIT 1;

-- 16. Вивести відділення, яке видало найбільший кредит.
SELECT MAX(ap.Sum), DepartmentCity
FROM department d
JOIN client c ON d.idDepartment = c.Department_idDepartment
JOIN application ap ON ap.Client_idClient = c.idClient
GROUP BY DepartmentCity;

-- -- 17. Усім клієнтам, які мають вищу освіту, встановити усі їхні кредити у розмірі 6000 грн.
UPDATE application
SET Sum = 6000
WHERE Client_idClient IN(SELECT idClient FROM client WHERE Education = 'high');

-- -- 18. Усіх клієнтів київських відділень пересилити до Києва.
UPDATE client
SET City = 'Kyiv'
WHERE Department_idDepartment IN (
	SELECT idDepartment FROM department WHERE DepartmentCity = 'Kyiv'
);

-- -- 19. Видалити усі кредити, які є повернені.
DELETE FROM application
WHERE CreditState = 'Returned' ;

-- -- 20. Видалити кредити клієнтів, в яких друга літера прізвища є голосною.
DELETE FROM application
WHERE Client_idClient IN(
	SELECT idClient
	FROM client
	WHERE (
		FirstName LIKE '_a%' OR		-- _[aeiouy]% - в мене не работає
	  	FirstName LIKE '_e%' OR
		FirstName LIKE '_i%' OR
		FirstName LIKE '_o%' OR
		FirstName LIKE '_u%' OR
		FirstName LIKE '_y%'
    )
);

-- Знайти львівські відділення, які видали кредитів на загальну суму більше ніж 5000
SELECT SUM(ap.Sum) sum,  DepartmentCity FROM department d
JOIN client c ON d.idDepartment = c.Department_idDepartment
JOIN application ap ON ap.Client_idClient = c.idClient
WHERE DepartmentCity = 'Lviv' AND sum > 5000
GROUP BY idDepartment;

-- -- Знайти клієнтів, які повністю погасили кредити на суму більше ніж 5000
SELECT * FROM client c
JOIN application ap ON ap.Client_idClient = c.idClient
WHERE CreditState = 'Returned' AND Sum > 5000;

/* Знайти максимальний неповернений кредит.*/
SELECT *, MAX(Sum) FROM application
WHERE CreditState = 'Not returned';

/*Знайти клієнта, сума кредиту якого найменша*/
SELECT FirstName, MIN(Sum) as min
FROM client c
JOIN application a ON c.idClient = a.Client_idClient;

/*Знайти кредити, сума яких більша за середнє значення усіх кредитів*/
SELECT *
FROM application app
WHERE Sum > (SELECT AVG(Sum) FROM application);

/*Знайти клієнтів, які є з того самого міста,
що і клієнт, який взяв найбільшу кількість кредитів*/
SELECT * FROM client
WHERE City = (
	SELECT City
	FROM application ap
    JOIN client c ON c.idClient = ap.Client_idClient
	GROUP BY Client_idClient
    ORDER BY COUNT(Client_idClient) DESC LIMIT 1
    );

#місто чувака який набрав найбільше кредитів

SELECT City
	FROM application ap
    JOIN client c ON c.idClient = ap.Client_idClient
	GROUP BY Client_idClient
    ORDER BY COUNT(Client_idClient) DESC LIMIT 1
