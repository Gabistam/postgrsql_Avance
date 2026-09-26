-- =====================================================================
--  Complément séance 3 — SQL avancé avec PostgreSQL
--  À exécuter sur la base cours_sql (indépendant des autres tables).
--  Génère une plateforme de streaming musical volumineuse :
--  5 000 artistes, 50 000 utilisateurs, 200 000 morceaux, 1 000 000 d'écoutes.
--  Données fictives et déterministes : tout le monde obtient les mêmes lignes.
--  Durée : 10 à 60 secondes selon la machine.
--  Script ré-exécutable : il supprime puis recrée ses tables (et leurs index).
-- =====================================================================

DROP TABLE IF EXISTS ecoutes, morceaux, utilisateurs_app, artistes CASCADE;

CREATE TABLE artistes (
    id     INTEGER PRIMARY KEY,
    nom    VARCHAR(60) NOT NULL,
    pays   VARCHAR(2)  NOT NULL
);

CREATE TABLE utilisateurs_app (
    id          INTEGER PRIMARY KEY,
    pseudo      VARCHAR(30) NOT NULL,
    pays        VARCHAR(2)  NOT NULL,
    inscrit_le  DATE        NOT NULL
);

CREATE TABLE morceaux (
    id          INTEGER PRIMARY KEY,
    artiste_id  INTEGER NOT NULL REFERENCES artistes(id),
    titre       VARCHAR(80) NOT NULL,
    infos       JSONB NOT NULL                 -- tags, bpm, explicite
);

CREATE TABLE ecoutes (
    id              BIGINT PRIMARY KEY,
    utilisateur_id  INTEGER   NOT NULL REFERENCES utilisateurs_app(id),
    morceau_id      INTEGER   NOT NULL REFERENCES morceaux(id),
    ecoute_le       TIMESTAMP NOT NULL,
    duree_s         INTEGER   NOT NULL,        -- secondes écoutées
    plateforme      VARCHAR(10) NOT NULL,      -- mobile, web, tv, enceinte
    terminee        BOOLEAN   NOT NULL         -- morceau écouté jusqu'au bout ?
);

-- ---------- Artistes ----------
INSERT INTO artistes (id, nom, pays)
SELECT i,
       (ARRAY['Nova','Kairo','Lune','Atlas','Echo','Vega','Orion','Sia','Milo','Zephyr'])[1 + i % 10]
         || ' ' || (ARRAY['Collective','Project','Band','Crew','Sound','Club','Trio','Duo'])[1 + (i / 10) % 8]
         || ' ' || i,
       (ARRAY['FR','FR','FR','US','US','GB','DE','BE','CA','JP'])[1 + (i * 7) % 10]
FROM generate_series(1, 5000) AS i;

-- ---------- Utilisateurs ----------
INSERT INTO utilisateurs_app (id, pseudo, pays, inscrit_le)
SELECT i,
       'user_' || i,
       (ARRAY['FR','FR','FR','FR','BE','CH','CA','MA','SN','CI'])[1 + (i * 3) % 10],
       DATE '2020-01-01' + (i * 37) % 1800
FROM generate_series(1, 50000) AS i;

-- ---------- Morceaux ----------
INSERT INTO morceaux (id, artiste_id, titre, infos)
SELECT i,
       1 + (i * 7919) % 5000,
       (ARRAY['Midnight','Golden','Electric','Silent','Crazy','Broken','Endless','Neon','Wild','Lost',
              'Blue','Summer','Frozen','Burning','Hidden','Velvet','Paper','Crystal','Shadow','Sweet'])[1 + i % 20]
         || ' ' ||
       (ARRAY['Dreams','City','Heart','Rain','Lullaby','Fire','Road','Night','Waves','Lights',
              'Story','Garden','Echoes','Skies','River','Mirror','Storm','Party','Memories','Horizon'])[1 + (i / 20) % 20],
       jsonb_build_object(
           'tags', CASE WHEN i % 100 = 0 THEN jsonb_build_array('acoustique', 'live')
                        ELSE jsonb_build_array(
                             (ARRAY['pop','rock','rap','electro','chill','jazz','rnb','indie','dance','folk'])[1 + i % 10],
                             (ARRAY['energique','calme','triste','festif','romantique'])[1 + (i / 10) % 5])
                   END,
           'bpm', 60 + (i * 13) % 121,
           'explicite', (i % 10 = 3))
FROM generate_series(1, 200000) AS i;

-- ---------- Écoutes ----------
-- Les petits identifiants de morceaux sont plus écoutés (distribution réaliste des tubes)
INSERT INTO ecoutes (id, utilisateur_id, morceau_id, ecoute_le, duree_s, plateforme, terminee)
SELECT i,
       1 + (i * 7919) % 50000,
       1 + FLOOR(200000 * POWER(((i * 104729) % 1000003) / 1000003.0, 3))::INTEGER,
       TIMESTAMP '2025-01-01 00:00' + ((i * 7907) % 525600) * INTERVAL '1 minute',
       30 + (i * 31) % 240,
       (ARRAY['mobile','mobile','mobile','mobile','mobile','mobile','web','web','enceinte','tv'])[1 + (i * 11) % 10],
       (i * 17) % 20 <> 0                       -- 95 % des écoutes vont jusqu'au bout
FROM generate_series(1::BIGINT, 1000000) AS i;

-- Statistiques à jour pour le planificateur + carte de visibilité (index-only scans)
VACUUM ANALYZE artistes, utilisateurs_app, morceaux, ecoutes;

-- ---------- Contrôle ----------
SELECT 'artistes' AS table_name, COUNT(*) AS lignes FROM artistes
UNION ALL SELECT 'utilisateurs_app', COUNT(*) FROM utilisateurs_app
UNION ALL SELECT 'morceaux', COUNT(*) FROM morceaux
UNION ALL SELECT 'ecoutes', COUNT(*) FROM ecoutes;
