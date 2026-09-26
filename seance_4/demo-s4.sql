-- =====================================================================
--  Complément séance 4 — SQL avancé avec PostgreSQL
--  À exécuter sur la base cours_sql (indépendant des autres tables).
--  Un jeu de rôle en ligne : aventuriers, pièces d'or, boutique d'objets, inventaires.
--  Script ré-exécutable : il supprime aussi les procédures, fonctions et triggers
--  créés pendant la séance, pour repartir de zéro.
-- =====================================================================

DROP TABLE IF EXISTS stats_ventes, audit, journal_prix, alertes, achats, inventaire, objets, aventuriers CASCADE;
DROP PROCEDURE IF EXISTS crediter(TEXT, INTEGER), acheter(TEXT, TEXT, INTEGER, INTEGER),
                         inscrire(TEXT), distribuer_bonus(INTEGER, INTEGER);
DROP FUNCTION IF EXISTS trg_normaliser_pseudo(), trg_maj_objet(), trg_audit(),
                        trg_nb_objets(), trg_journal_prix(), trg_alerte_rupture(), trg_boucle() CASCADE;

CREATE TABLE aventuriers (
    id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pseudo     VARCHAR(30) NOT NULL UNIQUE,
    niveau     INTEGER     NOT NULL DEFAULT 1 CHECK (niveau >= 1),
    pieces     INTEGER     NOT NULL DEFAULT 100 CHECK (pieces >= 0),   -- pièces d'or
    nb_objets  INTEGER     NOT NULL DEFAULT 0                          -- total des objets possédés
);

CREATE TABLE objets (
    id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom        VARCHAR(40) NOT NULL UNIQUE,
    categorie  VARCHAR(20) NOT NULL,
    prix       INTEGER     NOT NULL CHECK (prix > 0),
    stock      INTEGER     NOT NULL CHECK (stock >= 0),
    maj_le     TIMESTAMP                                -- dernière modification
);

CREATE TABLE inventaire (
    aventurier_id  INTEGER NOT NULL REFERENCES aventuriers(id),
    objet_id       INTEGER NOT NULL REFERENCES objets(id),
    quantite       INTEGER NOT NULL CHECK (quantite > 0),
    PRIMARY KEY (aventurier_id, objet_id)
);

CREATE TABLE achats (
    id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aventurier_id  INTEGER NOT NULL REFERENCES aventuriers(id),
    objet_id       INTEGER NOT NULL REFERENCES objets(id),
    quantite       INTEGER NOT NULL,
    prix_total     INTEGER NOT NULL,
    achete_le      TIMESTAMP NOT NULL DEFAULT now()
);

-- Tables alimentées par les triggers de la séance
CREATE TABLE audit (
    id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_nom  TEXT      NOT NULL,
    operation  TEXT      NOT NULL,
    ancienne   JSONB,
    nouvelle   JSONB,
    par        TEXT      NOT NULL DEFAULT current_user,
    le         TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE journal_prix (
    id              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nb_objets       INTEGER NOT NULL,
    variation_moy   NUMERIC(6,2) NOT NULL,          -- en %
    le              TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE alertes (
    id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    message   TEXT NOT NULL,
    le        TIMESTAMP NOT NULL DEFAULT now()
);

INSERT INTO aventuriers (pseudo, niveau, pieces) VALUES
  ('zed', 12, 540), ('lyna', 8, 320), ('mo', 15, 1200), ('kenji', 3, 45),
  ('sara', 6, 210), ('nova', 20, 2500), ('kairo', 1, 100), ('atlas', 9, 380);

INSERT INTO objets (nom, categorie, prix, stock) VALUES
  ('Potion de soin', 'potion', 25, 50),
  ('Élixir de mana', 'potion', 40, 30),
  ('Épée courte', 'arme', 150, 10),
  ('Arc long', 'arme', 220, 5),
  ('Bouclier en bois', 'armure', 90, 8),
  ('Cotte de mailles', 'armure', 480, 2),
  ('Parchemin de téléportation', 'magie', 300, 1),
  ('Carte au trésor', 'quête', 999, 1);

INSERT INTO inventaire (aventurier_id, objet_id, quantite) VALUES
  (1, 1, 3), (1, 3, 1), (2, 1, 2), (2, 4, 1), (3, 3, 1), (3, 6, 1),
  (3, 2, 5), (6, 7, 1), (6, 5, 1), (8, 1, 4);

-- nb_objets cohérent avec l'inventaire de départ
UPDATE aventuriers a
SET nb_objets = COALESCE((SELECT SUM(quantite) FROM inventaire i WHERE i.aventurier_id = a.id), 0);

-- ---------- Contrôle ----------
SELECT 'aventuriers' AS table_name, COUNT(*) AS lignes FROM aventuriers
UNION ALL SELECT 'objets', COUNT(*) FROM objets
UNION ALL SELECT 'inventaire', COUNT(*) FROM inventaire;
