-- Active: 1652720146904@@127.0.0.1@3306@dataimmo3

/* 1-Nombre total d'appartements au 1er semestre 2020 */

select
    count(*) as 'ventes appartements au 1er semestre 2020'
from transactions as t
    inner join biens as b on t.id_bien = b.id_bien
    inner join regions as r on r.id_region = b.id_region
where
    date between "2020-01-01" and "2020-06-30"
    and b.type_local = "appartement";

/* 2- Nombre de ventes d'appartements par région pour le 1er semestre 2020 */

SELECT
    count (t.id_transaction) as 'nombre de ventes',
    r.nom_region as 'région'
from transactions as t
    INNER JOIN biens as b on b.id_bien = t.id_bien
    INNER JOIN regions as r on b.id_region = r.id_region
WHERE
    date BETWEEN "2020-01-01" AND "2020-06-01"
    and b.type_local = "appartement"
GROUP BY r.nom_region;

/*  3- Proportion des ventes d'appartements par le nombre de pièces */

SELECT
    COUNT(t.id_transaction) / tmp_table.nb * 100 as 'proportion des ventes',
    b.nb_pieces as 'nombre de pièces'
from transactions as t
    JOIN biens as b on b.id_bien = t.id_bien, (
        SELECT COUNT(*) AS nb
        FROM
            transactions AS tt,
            biens AS bb
        WHERE
            tt.id_bien = bb.id_bien
            AND bb.type_local = 'appartement'
    ) as tmp_table
where
    b.type_local = 'appartement'
GROUP BY b.nb_pieces;

/*  4- Liste des 10 départements où le prix du m² est le plus élevé */

SELECT
    SUM(t.valeur) / tmp_surf.nb as 'prixSurface',
    d.nom_departement as 'département'
FROM transactions as t
    INNER JOIN biens AS b ON b.id_bien = t.id_bien
    INNER JOIN regions AS r ON b.id_region = r.id_region
    INNER JOIN departements AS d ON r.id_departement = d.id_departement, (
        SELECT
            count(surface_carrez) AS nb
        FROM
            biens as bb
    ) as tmp_surf
GROUP BY d.nom_departement
ORDER BY prixSurface DESC
LIMIT 10;

/*  5- Prix moyen du m² d’une maison en île de france*/

SELECT
    SUM(t.valeur) / tmp_surf.nb as "prix moyen €/m² Maison",
    r.nom_region as "île-de-France"
FROM transactions as t
    INNER JOIN biens AS b ON b.id_bien = t.id_bien
    INNER JOIN regions AS r ON b.id_region = r.id_region, (
        SELECT
            count(surface_carrez) AS nb
        FROM
            biens as bb
    ) as tmp_surf
WHERE
    b.type_local = "maison"
    AND r.nom_region = "Île-de-France";

/* 6- Liste des 10 appartements les plus chers, avec la région et le nombre de m² */

SELECT
    b.id_bien as 'id bien',
    r.nom_region as 'région',
    t.valeur as 'prix en €'
FROM biens AS b
    INNER JOIN regions AS r ON b.id_region = r.id_region
    INNER JOIN transactions AS t ON b.id_bien = t.id_bien
WHERE
    b.type_local = 'appartement'
ORDER BY t.valeur DESC
LIMIT 10;

/* 7- Taux d'évolution du nombre de ventes entre le premier et le second trimestre 2020*/

SELECT
    t1 as "trimestre 1",
    t2 as "trimestre 2", ( (t2 - t1) / t1) * 100 as "taux d'évolution des ventes"
FROM (
        SELECT COUNT(*) as t2
        FROM transactions
        WHERE
            date BETWEEN "2020-04-01" AND "2020-06-30"
    ) t2
    JOIN (
        SELECT COUNT(*) as t1
        FROM transactions
        WHERE
            date BETWEEN "2020-01-01" AND "2020-03-31"
    ) t1;

/* 8- classement des régions par rapport au prix /m² des appartements de plus de 4 pièces*/

SELECT
    SUM(t.valeur) / tmp_surf.nb as 'prixSurface',
    r.nom_region as 'région'
FROM transactions as t
    INNER JOIN biens AS b ON b.id_bien = t.id_bien
    INNER JOIN regions AS r ON b.id_region = r.id_region
    INNER JOIN departements AS d ON r.id_departement = d.id_departement, (
        SELECT
            count(surface_carrez) AS nb
        FROM
            biens as bb
    ) as tmp_surf
WHERE b.nb_pieces > 4
GROUP BY r.nom_region
ORDER BY prixSurface;

/* 9-Liste de communes ayant eu au moins 50 ventes au 1er trimestre */

SELECT
    COUNT(t.id_transaction) as ventes,
    c.nom_commune
FROM communes as c
    INNER JOIN biens AS b ON b.id_commune = c.id_commune
    INNER JOIN transactions AS t ON b.id_bien = t.id_bien
WHERE
    t.date BETWEEN "2020-01-01" AND "2020-03-31"
GROUP BY c.nom_commune
HAVING (count(t.id_transaction) > 50)
ORDER BY
    COUNT(t.id_transaction) DESC;

/* 10- Différence en % du prix au m² entre un appartement de 2  pièces
 et un appartement de 3 pièces */

SELECT
    p2 as "2pièces",
    p3 as "3 pieces", (p2 / p3) * 100 as "différence de prix en %"
FROM (
        SELECT
            AVG(valeur) as p2
        FROM transactions AS t
            INNER JOIN biens as b ON b.id_bien = t.id_bien
        WHERE
            b.nb_pieces = 2
    ) p2
    JOIN (
        SELECT
            AVG(valeur) as p3
        FROM transactions AS t
            INNER JOIN biens as b ON b.id_bien = t.id_bien
        WHERE
            b.nb_pieces = 3
    ) p3;

/* 11- Les moyennes de valeurs foncières pour le top 3 des communes des départements 6,13,33,59 et 69*/
SELECT *
    FROM (
        SELECT
        RANK() OVER (PARTITION BY code_departement ORDER BY moyenne_commune DESC) AS Rang, 
        id_commune, 
        nom_commune, 
        moyenne_commune,
        code_departement

        FROM (
            SELECT c.id_commune,
            c.nom_commune, 
            d.code_departement, 
            ROUND(AVG(t.valeur), 2) AS moyenne_commune

            FROM communes AS c
                INNER JOIN biens AS b
                ON b.id_commune = c.id_commune
                INNER JOIN transactions AS t
                ON t.id_bien = b.id_bien
                INNER JOIN regions AS r
                ON b.id_region = r.id_region
                INNER JOIN departements AS d
                ON r.id_departement = d.id_departement
                

            WHERE d.code_departement IN ("06", "13", "33", "59", "69")
            GROUP BY c.nom_commune
            ORDER BY c.id_commune) 
        AS sub) 
    AS sub2

    WHERE Rang <=3 ;
