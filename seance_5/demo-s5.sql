-- =====================================================================
--  Complément séance 5 — SQL avancé avec PostgreSQL
--  À exécuter sur la base cours_sql, avec un compte superutilisateur (postgres).
--  Reprend le jeu de rôle de la séance 4, dans une version simplifiée :
--  aventuriers et pièces d'or, quêtes à distribuer, gardes de la cité, messagerie privée.
--  Script ré-exécutable : il supprime aussi les rôles, politiques et fonctions
--  créés pendant la séance.
-- =====================================================================

-- ---------- Nettoyage (tables de la séance 4 comprises) ----------
DROP TABLE IF EXISTS messages, quetes, gardes, stats_ventes, audit, journal_prix, alertes,
                     achats, inventaire, objets, aventuriers CASCADE;
DROP PROCEDURE IF EXISTS crediter(TEXT, INTEGER), acheter(TEXT, TEXT, INTEGER, INTEGER),
                         inscrire(TEXT), distribuer_bonus(INTEGER, INTEGER),
                         transferer(TEXT, TEXT, INTEGER);
DROP FUNCTION IF EXISTS trg_normaliser_pseudo(), trg_maj_objet(), trg_audit(), trg_nb_objets(),
                        trg_journal_prix(), trg_alerte_rupture(), trg_boucle(),
                        chercher_naif(TEXT), chercher_sur(TEXT), hacher(TEXT), verifier(TEXT, TEXT),
                        classement(), lister(TEXT) CASCADE;

-- Rôles créés pendant la séance et ses cas pratiques (les rôles existent pour tout le serveur)
DO $$
DECLARE r TEXT;
BEGIN
    FOREACH r IN ARRAY ARRAY['app_jeu', 'jeu_lecture', 'jeu_ecriture', 'analyste',
                               'moderateur', 'modo_kenji', 'joueur'] LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
            EXECUTE format('DROP OWNED BY %I', r);
            EXECUTE format('DROP ROLE %I', r);
        END IF;
    END LOOP;
END $$;

-- ---------- Tables ----------
CREATE TABLE aventuriers (
    id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pseudo  VARCHAR(30) NOT NULL UNIQUE,
    pieces  INTEGER     NOT NULL CHECK (pieces >= 0)
);

CREATE TABLE quetes (                          -- file de travail
    id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titre     VARCHAR(60) NOT NULL,
    statut    VARCHAR(10) NOT NULL DEFAULT 'a_faire'
              CHECK (statut IN ('a_faire', 'en_cours', 'terminee')),
    prise_par TEXT
);

CREATE TABLE gardes (                          -- règle : au moins un garde en service
    pseudo      VARCHAR(30) PRIMARY KEY,
    en_service  BOOLEAN NOT NULL
);

CREATE TABLE messages (                        -- messagerie privée entre aventuriers
    id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expediteur_id    INTEGER NOT NULL REFERENCES aventuriers(id),
    destinataire_id  INTEGER NOT NULL REFERENCES aventuriers(id),
    contenu          TEXT    NOT NULL
);

INSERT INTO aventuriers (pseudo, pieces) VALUES
  ('zed', 500), ('lyna', 300), ('mo', 1200), ('kenji', 50), ('sara', 200);

INSERT INTO quetes (titre) VALUES
  ('Chasser les loups'), ('Livrer le courrier'), ('Explorer la crypte'),
  ('Escorter le marchand'), ('Cueillir des herbes');

INSERT INTO gardes VALUES ('aldric', true), ('brune', true);

INSERT INTO messages (expediteur_id, destinataire_id, contenu) VALUES
  (1, 2, 'On part en quête demain ?'),
  (2, 1, 'Oui, rendez-vous à la taverne.'),
  (3, 4, 'Je te prête 100 pièces, rends-les vite.'),
  (4, 3, 'Merci, je rembourse samedi.'),
  (5, 1, 'Tu as vu la carte au trésor ?');

-- ---------- Contrôle ----------
SELECT 'aventuriers' AS table_name, COUNT(*) AS lignes FROM aventuriers
UNION ALL SELECT 'quetes', COUNT(*) FROM quetes
UNION ALL SELECT 'gardes', COUNT(*) FROM gardes
UNION ALL SELECT 'messages', COUNT(*) FROM messages;
