# 🐘 SQL avancé avec PostgreSQL — Plan de cours

**M1 Tech Lead · Promo 2026-2027 · 17,5 h · 100 % pratique**

| ⏱ Volume | 📅 Dates | 🎬 Fil rouge | 📦 Évaluation |
|---|---|---|---|
| 17,5 h · 5 demi-journées | 25 → 29 septembre 2026 | **FilmBox** (façon Letterboxd) | Travail à rendre |

---

## 🗺 Vue d'ensemble

### 🎯 Objectif du module

> **À la fin du module, vous maîtrisez les fonctionnalités avancées de PostgreSQL** pour manipuler les données efficacement, optimiser les requêtes et automatiser les tâches — avec le regard d'un tech lead : performance, fiabilité, sécurité et sobriété.

Chaque demi-journée suit le même rythme :

1. une **démo live courte** (15 à 20 min maximum) ;
2. des **ateliers guidés** sur la base FilmBox ;
3. un **cas waouh** : le moment de démonstration qui rend la notion concrète et mémorable ;
4. un **défi** en autonomie, puis un **bilan**.

Les scripts produits en séance constituent directement la matière du travail à rendre.

### 📅 Déroulé des 5 séances

| Séance | Date | Thème | Notions clés | Cas waouh 🤩 |
|---|---|---|---|---|
| **S1** | Ven. 25/09 · 09:00–12:30 | Requêtage avancé | CTE, CTE récursives, window functions, JSONB | Le « nombre de Kevin Bacon » de n'importe quel acteur |
| **S2** | Ven. 25/09 · 13:30–17:00 | Vues & fonctions | Vues, vues matérialisées, PL/pgSQL | La note pondérée façon Top 250 d'IMDb |
| **S3** | Lun. 28/09 · 09:00–12:30 | Index & optimisation | EXPLAIN ANALYZE, B-tree, GIN, trigrammes | Recherche de titre : de 2 s à quelques ms, fautes de frappe comprises |
| **S4** | Lun. 28/09 · 13:30–17:00 | Procédures & triggers | CALL, triggers BEFORE/AFTER, audit | La moyenne du film se met à jour toute seule à chaque note |
| **S5** | Mar. 29/09 · 13:30–17:00 | Transactions & sécurité | ACID, isolation, verrous, rôles, RLS | Les likes perdus d'une critique virale, puis le journal privé inviolable |

> 📌 **Le 29/09 ne compte qu'une demi-journée.** Le brief du travail à rendre est présenté dès S1 pour que les étudiants construisent leur rendu au fil des séances, et non en une seule fois à la fin.

### 🧩 Compétences visées → séances → preuves

| Compétence (fiche pédagogique) | Séances | Preuve attendue dans le rendu |
|---|---|---|
| Créer des fonctions avancées | S1, S2 | Requêtes avancées commentées + 3 fonctions PL/pgSQL testées |
| Optimiser des requêtes | S3 | Rapport EXPLAIN ANALYZE avant/après sur 3 requêtes lentes |
| Gérer les transactions | S4, S5 | Procédure transactionnelle + scénario de concurrence documenté |
| Automatiser avec des triggers | S4 | 3 triggers (validation, statistiques, audit) |
| Sécuriser les opérations | S5 | Script rôles/GRANT + Row Level Security sur les données privées |

---

## 🎬 Le fil rouge : FilmBox

FilmBox est un réseau social de cinéphiles, sur le modèle de Letterboxd. Chaque utilisateur note les films qu'il a vus, publie des critiques, tient un journal de visionnage, crée des listes et suit d'autres membres.

**Pourquoi ce domaine fonctionne pour le module :**

- 🔁 **Récursivité** : l'ordre des sagas (film précédent → film suivant) et le graphe des acteurs (Kevin Bacon).
- 📊 **Fonctions analytiques** : classements par genre, évolution des notes, tendances.
- 🧬 **JSONB** : genres, pays, budget et métadonnées variables selon les films.
- ⚡ **Volume** : des millions de notes et de visionnages, idéal pour sentir l'effet d'un index.
- ⚙️ **Triggers** : moyennes, compteurs et historique des critiques maintenus automatiquement.
- 🔐 **Sécurité** : journaux et listes privés, protégés par la RLS.

### 🗄 Schéma cible (fourni en S1)

```sql
utilisateurs   (id, pseudo, email, bio, created_at)
sagas          (id, nom)
films          (id, titre, annee, duree_min, synopsis,
                saga_id, film_precedent_id,       -- chaînage des sagas
                details JSONB)                    -- genres, pays, budget…
personnes      (id, nom, date_naissance)          -- acteurs et réalisateurs
casting        (film_id, personne_id, role, personnage)
notes          (utilisateur_id, film_id, note, created_at)   -- 0,5 à 5
critiques      (id, utilisateur_id, film_id, texte, spoiler,
                nb_likes, created_at, updated_at)
likes_critiques(utilisateur_id, critique_id, created_at)
journal        (id, utilisateur_id, film_id, date_visionnage,
                revisionnage, prive)
listes         (id, utilisateur_id, titre, publique)
liste_films    (liste_id, film_id, position)
abonnements    (follower_id, suivi_id, created_at)
films_stats    (film_id, nb_notes, moyenne)       -- maintenue par trigger
audit_critiques(id, critique_id, ancien_texte, modifie_le)
```

> 💡 **Option données réelles** : les jeux de données publics d'IMDb (films, personnes, castings) permettent de charger des millions de lignes réalistes pour S1 et S3. Ils sont réservés à un usage personnel et non commercial : vérifiez les conditions avant diffusion. Sinon, le script de seed génère les données avec `generate_series`.

### 🧰 Prérequis & installation

À envoyer aux étudiants **avant le 25/09 au matin** :

- [ ] PostgreSQL 16 ou 17 installé ([postgresql.org](https://www.postgresql.org/)) — ou Docker `postgres:17`
- [ ] Un client SQL : psql + DBeaver ou pgAdmin
- [ ] Extensions activables : `pg_stat_statements`, `pg_trgm`
- [ ] Repo Git personnel `filmbox-sql` créé
- [ ] Prérequis maîtrisés : `SELECT`, `JOIN`, `GROUP BY`

> ⚠️ Les 20 premières minutes de S1 ne suffisent pas à dépanner une installation Windows capricieuse.

### 🤖 Usage de l'IA

- Réécrire une requête complexe, puis **prouver** l'équivalence (mêmes résultats) et le gain (EXPLAIN ANALYZE).
- Soumettre un plan d'exécution à une IA pour repérer les goulets d'étranglement, puis vérifier chaque hypothèse par une mesure.
- **Règle du module** : toute requête produite avec l'IA est signalée dans le README du rendu.

### 🌱 Démarche RSE

- Mesurer avant d'optimiser : buffers lus, temps d'exécution, volume scanné.
- Chaque optimisation du rapport S3 est traduite en charge serveur économisée.
- Sobriété : pas d'index « au cas où » (coût en écriture et en stockage), purge et archivage pensés dès la modélisation.

---

## 🔎 S1 — Installation & requêtage avancé

**Vendredi 25/09 · 09:00–12:30** · *Fonctions avancées de manipulation des données*

> 🎯 **Objectif** : écrire des requêtes analytiques que le `GROUP BY` classique ne permet pas — classements, cumuls, comparaisons ligne à ligne, parcours de graphes et données semi-structurées.

| Horaire | Type | Contenu |
|---|---|---|
| 09:00–09:25 | 🛠 Setup | Vérification des installations, création de la base `filmbox`, exécution du schéma + seed. Présentation du brief du rendu (5 min). |
| 09:25–10:05 | 🎥 Démo + lab | **CTE et CTE récursives** : requêtes en étapes lisibles, ordre de visionnage d'une saga, graphe des acteurs. |
| 10:05–10:55 | 🎥 Démo + lab | **Window functions** : `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG/LEAD`, `AVG() OVER` avec `PARTITION BY` et cadres de fenêtre. |
| 10:55–11:05 | ☕ Pause | — |
| 11:05–11:50 | 🧪 Lab | **Agrégations avancées** : `FILTER`, `GROUPING SETS / ROLLUP`, `LATERAL`, JSONB (`->>`, `@>`, `jsonb_array_elements_text`). |
| 11:50–12:20 | 🏆 Défi | Top 3 des films par genre (au moins 50 notes), avec l'écart de note par rapport au film précédent de la même saga. |
| 12:20–12:30 | 💬 Bilan | Quelle requête vous aurait pris 3 sous-requêtes avant ce matin ? |

### 🤩 Cas waouh : le nombre de Kevin Bacon

Le jeu des « six degrés de Kevin Bacon » dit que tout acteur est relié à Kevin Bacon en 6 films maximum. En SQL, c'est une CTE récursive qui parcourt le graphe des acteurs ayant partagé un film. Les étudiants tapent le nom de leur acteur préféré et découvrent son « nombre de Bacon ».

```sql
-- Qui est relié à Kevin Bacon, et en combien de films ?
WITH RECURSIVE chaine AS (
  -- Point de départ : Kevin Bacon, degré 0
  SELECT p.id AS personne_id, 0 AS degre, ARRAY[p.id] AS chemin
  FROM personnes p
  WHERE p.nom = 'Kevin Bacon'

  UNION ALL

  -- Étape récursive : les partenaires de casting des acteurs déjà trouvés
  SELECT c2.personne_id, ch.degre + 1, ch.chemin || c2.personne_id
  FROM chaine ch
  JOIN casting c1 ON c1.personne_id = ch.personne_id AND c1.role = 'acteur'
  JOIN casting c2 ON c2.film_id = c1.film_id AND c2.role = 'acteur'
                 AND c2.personne_id <> ALL(ch.chemin)   -- évite les boucles
  WHERE ch.degre < 3                                    -- limite la profondeur
)
SELECT p.nom, MIN(ch.degre) AS nombre_de_bacon
FROM chaine ch
JOIN personnes p ON p.id = ch.personne_id
GROUP BY p.nom
ORDER BY nombre_de_bacon;
```

> 🧠 **La question de tech lead à poser** : pourquoi la requête explose-t-elle au-delà de 3 ou 4 degrés ? C'est la même mécanique que les suggestions « amis de vos amis » des réseaux sociaux, et la raison pour laquelle ils ne calculent jamais tout en temps réel.

### Autres exemples de la séance

```sql
-- Ordre de visionnage d'une saga, reconstruit par chaînage
WITH RECURSIVE saga AS (
  SELECT id, titre, annee, 1 AS episode
  FROM films
  WHERE saga_id = 1 AND film_precedent_id IS NULL      -- premier film
  UNION ALL
  SELECT f.id, f.titre, f.annee, s.episode + 1
  FROM films f
  JOIN saga s ON f.film_precedent_id = s.id            -- film suivant
)
SELECT episode, titre, annee FROM saga ORDER BY episode;
```

```sql
-- Top 3 des films par genre (genres stockés en JSONB)
SELECT genre, titre, moyenne, rang
FROM (
  SELECT g.genre, f.titre, s.moyenne,
         DENSE_RANK() OVER (PARTITION BY g.genre ORDER BY s.moyenne DESC) AS rang
  FROM films f
  JOIN films_stats s ON s.film_id = f.id
  CROSS JOIN LATERAL jsonb_array_elements_text(f.details -> 'genres') AS g(genre)
  WHERE s.nb_notes >= 50
) t
WHERE rang <= 3;
```

> ⚠️ **Piège fréquent** : confondre `RANK` (saute des rangs en cas d'égalité) et `DENSE_RANK`. Faites-le constater sur deux films à la même moyenne.

**Exemples complémentaires** : classement de pilotes de F1 par cumul de points (fenêtrage), arbre des sous-genres musicaux (CTE récursive).

### ✅ Checklist formateur S1

- [ ] Tous les postes connectés à la base `filmbox` avec données
- [ ] Ordre de saga et nombre de Bacon réalisés
- [ ] Window functions : classement + moyenne glissante + `LAG`
- [ ] `FILTER` / `ROLLUP` / JSONB manipulés
- [ ] Défi tenté et `s1_requetes.sql` poussé sur le repo

> 📦 **Livrable de séance** — `s1_requetes.sql` : 8 requêtes commentées (au moins 1 CTE récursive, 3 window functions, 1 requête JSONB).

---

## 🧱 S2 — Vues & fonctions PL/pgSQL

**Vendredi 25/09 · 13:30–17:00** · *Vues · Fonctions avancées*

> 🎯 **Objectif** : encapsuler la logique métier dans la base — exposer des vues propres aux applications, calculer une seule fois les indicateurs coûteux, et écrire des fonctions réutilisables et testées.

| Horaire | Type | Contenu |
|---|---|---|
| 13:30–13:40 | 💬 Rappel | Correction express du défi S1. |
| 13:40–14:25 | 🎥 Démo + lab | **Vues** : vue « fiche film » (infos + casting + stats), vue modifiable, `WITH CHECK OPTION`, vue comme contrat d'API entre la base et le back-end. |
| 14:25–15:05 | 🧪 Lab | **Vues matérialisées** : tendances de la semaine, `REFRESH MATERIALIZED VIEW CONCURRENTLY`, arbitrage fraîcheur vs coût. |
| 15:05–15:15 | ☕ Pause | — |
| 15:15–16:15 | 🎥 Démo + lab | **Fonctions SQL et PL/pgSQL** : paramètres, `RETURNS TABLE`, variables, `IF` et boucles, `RAISE EXCEPTION`, volatilité `IMMUTABLE / STABLE / VOLATILE`. |
| 16:15–16:50 | 🏆 Défi | `fn_films_communs(user_a, user_b)` : les films vus par deux membres et leur écart de note (« compatibilité cinéphile »). |
| 16:50–17:00 | 💬 Bilan | Vue, vue matérialisée ou fonction : quand choisir quoi ? |

### 🤩 Cas waouh : la note pondérée façon IMDb

Un film noté 5/5 par 3 personnes ne doit pas dépasser *Le Parrain*, noté 4,6 par 80 000 membres. La note pondérée (formule du Top 250 d'IMDb) tire les films peu notés vers la moyenne générale.

```sql
-- Note pondérée = (v / (v + m)) × R + (m / (v + m)) × C
--   v : nombre de notes du film     R : moyenne du film
--   m : seuil minimal de votes      C : moyenne de tous les films
CREATE OR REPLACE FUNCTION fn_note_ponderee(p_film INT, p_min_votes INT DEFAULT 50)
RETURNS NUMERIC
LANGUAGE plpgsql
STABLE              -- lit des tables : jamais IMMUTABLE
AS $$
DECLARE
  v_moyenne  NUMERIC;
  v_nb       INT;
  v_globale  NUMERIC;
BEGIN
  SELECT moyenne, nb_notes INTO v_moyenne, v_nb
  FROM films_stats
  WHERE film_id = p_film;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Film % inconnu ou jamais noté', p_film;
  END IF;

  SELECT AVG(moyenne) INTO v_globale FROM films_stats;

  RETURN ROUND(
      (v_nb::NUMERIC / (v_nb + p_min_votes)) * v_moyenne
    + (p_min_votes::NUMERIC / (v_nb + p_min_votes)) * v_globale
  , 2);
END;
$$;

-- Le classement change complètement :
SELECT f.titre, s.moyenne, s.nb_notes, fn_note_ponderee(f.id) AS note_ponderee
FROM films f JOIN films_stats s ON s.film_id = f.id
ORDER BY note_ponderee DESC
LIMIT 10;
```

```sql
-- Tendances de la semaine, calculées une fois puis servies instantanément
CREATE MATERIALIZED VIEW mv_tendances_semaine AS
SELECT f.id, f.titre, COUNT(*) AS nb_visionnages
FROM journal j
JOIN films f ON f.id = j.film_id
WHERE j.date_visionnage >= CURRENT_DATE - 7
GROUP BY f.id, f.titre;

CREATE UNIQUE INDEX ON mv_tendances_semaine (id);   -- requis pour CONCURRENTLY
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_tendances_semaine;
```

> ⚠️ **Piège à montrer** : déclarer `IMMUTABLE` une fonction qui lit une table. Ça compile, mais le planificateur peut réutiliser un résultat périmé. C'est une erreur qui marque les esprits.

**Exemples complémentaires** : vue « fiche joueur » d'un jeu en ligne, vue matérialisée du classement d'une ligue de foot.

### ✅ Checklist formateur S2

- [ ] Vue « fiche film » + `WITH CHECK OPTION` testée en insertion
- [ ] Vue matérialisée rafraîchie en `CONCURRENTLY` (index unique créé)
- [ ] Fonction de note pondérée avec `RAISE EXCEPTION`
- [ ] `s2_vues_fonctions.sql` poussé sur le repo

> 📦 **Livrable de séance** — `s2_vues_fonctions.sql` : 2 vues (dont 1 matérialisée) + 2 fonctions avec jeux de tests.

---

## ⚡ S3 — Index & optimisation de requêtes

**Lundi 28/09 · 09:00–12:30** · *Index · Optimisation · IA · RSE*

> 🎯 **Objectif** : lire un plan d'exécution, identifier le goulet d'étranglement, choisir le bon index et **prouver le gain par la mesure** — pas par l'intuition.

| Horaire | Type | Contenu |
|---|---|---|
| 09:00–09:20 | 🛠 Setup | Montée en volume avec `generate_series` (~500 000 films, ~5 M notes, ~3 M entrées de journal), `ANALYZE`, activation de `pg_stat_statements`. |
| 09:20–10:05 | 🎥 Démo + lab | **Lire un plan** : `EXPLAIN (ANALYZE, BUFFERS)`, Seq Scan vs Index Scan vs Bitmap, Nested Loop / Hash Join / Merge Join, écart estimé vs réel. |
| 10:05–10:50 | 🧪 Lab | **Types d'index** : B-tree, composite (ordre des colonnes), partiel, sur expression, couvrant (`INCLUDE`), GIN pour JSONB et trigrammes. |
| 10:50–11:00 | ☕ Pause | — |
| 11:00–11:40 | 🧪 Lab | **Anti-patterns** : fonction sur colonne indexée, `OR` multiples, `SELECT *`, pagination `OFFSET` → pagination par clé. Coût d'un index en écriture. |
| 11:40–12:20 | 🏆 Défi IA | 3 requêtes lentes fournies (page profil, fil d'actualité, recherche par genre) : soumettre le plan à une IA, confronter ses suggestions à la mesure, ne garder que ce qui est prouvé. |
| 12:20–12:30 | 🌱 Bilan RSE | Traduire les gains en buffers et en millisecondes économisés à l'échelle de 10 000 appels par jour. |

### 🤩 Cas waouh : la recherche de titre instantanée

Sur 500 000 films, un `ILIKE '%star wars%'` parcourt toute la table. Un index trigramme GIN la ramène à quelques millisecondes, et la similarité permet de retrouver le film malgré une faute de frappe.

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Avant : Seq Scan sur toute la table
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, titre FROM films WHERE titre ILIKE '%star wars%';

-- Index trigramme : le ILIKE devient indexable
CREATE INDEX idx_films_titre_trgm ON films USING GIN (titre gin_trgm_ops);

-- Après : Bitmap Index Scan, quelques millisecondes
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, titre FROM films WHERE titre ILIKE '%star wars%';

-- Bonus : recherche tolérante aux fautes de frappe
SELECT titre, word_similarity('star wras', titre) AS score
FROM films
ORDER BY score DESC
LIMIT 5;
```

### Autre exemple de la séance

```sql
-- Page profil : « mes 20 derniers films vus »
EXPLAIN (ANALYZE, BUFFERS)
SELECT film_id, date_visionnage
FROM journal
WHERE utilisateur_id = 4242
ORDER BY date_visionnage DESC
LIMIT 20;

-- Index composite + couvrant : lecture directe, déjà triée, sans accès à la table
CREATE INDEX idx_journal_user_date
  ON journal (utilisateur_id, date_visionnage DESC)
  INCLUDE (film_id);
```

> 🚫 **Règle du module** : l'IA propose souvent d'ajouter des index partout. Un index sans gain mesuré dans le rapport est supprimé.

**Exemples complémentaires** : recherche de joueurs par pseudo dans un jeu en ligne (`pg_trgm`), filtrage d'annonces auto par attributs JSONB (marque, carburant, kilométrage).

### ✅ Checklist formateur S3

- [ ] Base montée en volume et statistiques à jour
- [ ] Chaque étudiant sait lire « estimé vs réel » et les buffers
- [ ] Au moins 4 types d'index testés et mesurés
- [ ] Rapport avant/après amorcé sur les 3 requêtes

> 📦 **Livrable de séance** — `s3_optimisation.md` : pour chaque requête, plan avant, hypothèse, index ou réécriture, plan après, gain chiffré, apport réel de l'IA.

---

## ⚙️ S4 — Procédures stockées & triggers

**Lundi 28/09 · 13:30–17:00** · *Procédures · Triggers · Transactions*

> 🎯 **Objectif** : automatiser les règles métier au plus près des données — une procédure qui publie un avis de bout en bout, et des triggers qui valident, calculent et tracent.

| Horaire | Type | Contenu |
|---|---|---|
| 13:30–13:45 | 🎥 Démo | Fonction vs procédure : `CALL`, contrôle de transaction (`COMMIT` / `ROLLBACK`) dans une procédure. |
| 13:45–14:45 | 🧪 Lab | **Procédure `publier_avis`** : validation de la note, enregistrement note + critique + journal en un seul bloc, bloc `EXCEPTION` et annulation propre. |
| 14:45–14:55 | ☕ Pause | — |
| 14:55–15:40 | 🎥 Démo + lab | **Triggers BEFORE** : validation (note entre 0,5 et 5, critique non vide), mise à jour automatique de `updated_at`. `NEW` / `OLD`, `TG_OP`. |
| 15:40–16:25 | 🧪 Lab | **Triggers AFTER** : statistiques de films recalculées, historique des critiques modifiées, triggers niveau instruction et tables de transition. |
| 16:25–16:50 | 🏆 Défi | Badge automatique « Marathonien » quand un membre enregistre 5 films dans la même journée. |
| 16:50–17:00 | 💬 Bilan | Logique métier en base ou dans l'application : les arguments du tech lead. |

### 🤩 Cas waouh : la moyenne qui se met à jour toute seule

Un utilisateur publie sa note, et la moyenne du film se met à jour instantanément, sans une ligne de code applicatif.

```sql
CREATE OR REPLACE FUNCTION trg_maj_stats_film()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_film INT;
BEGIN
  -- En DELETE, seule OLD existe ; sinon on prend NEW
  IF TG_OP = 'DELETE' THEN
    v_film := OLD.film_id;
  ELSE
    v_film := NEW.film_id;
  END IF;

  -- Recalcul des statistiques du film concerné
  INSERT INTO films_stats (film_id, nb_notes, moyenne)
  SELECT v_film, COUNT(*), COALESCE(ROUND(AVG(note), 2), 0)
  FROM notes
  WHERE film_id = v_film
  ON CONFLICT (film_id) DO UPDATE
    SET nb_notes = EXCLUDED.nb_notes,
        moyenne  = EXCLUDED.moyenne;

  RETURN NULL;   -- ignoré pour un trigger AFTER
END;
$$;

CREATE TRIGGER maj_stats_film
AFTER INSERT OR UPDATE OR DELETE ON notes
FOR EACH ROW EXECUTE FUNCTION trg_maj_stats_film();
```

### Procédure de la séance

```sql
-- Publier un avis complet : note + critique + entrée de journal, tout ou rien
CREATE OR REPLACE PROCEDURE publier_avis(
  p_user    INT,
  p_film    INT,
  p_note    NUMERIC,
  p_texte   TEXT,
  p_spoiler BOOLEAN DEFAULT false
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Note valide : de 0,5 à 5, par demi-point
  IF p_note NOT BETWEEN 0.5 AND 5 OR p_note * 2 <> TRUNC(p_note * 2) THEN
    RAISE EXCEPTION 'Note invalide : % (0,5 à 5 par demi-point)', p_note;
  END IF;

  INSERT INTO notes (utilisateur_id, film_id, note)
  VALUES (p_user, p_film, p_note)
  ON CONFLICT (utilisateur_id, film_id)
    DO UPDATE SET note = EXCLUDED.note, created_at = now();

  INSERT INTO critiques (utilisateur_id, film_id, texte, spoiler)
  VALUES (p_user, p_film, p_texte, p_spoiler);

  INSERT INTO journal (utilisateur_id, film_id, date_visionnage)
  VALUES (p_user, p_film, CURRENT_DATE);
END;
$$;

CALL publier_avis(12, 603, 4.5, 'Toujours aussi culte, 25 ans après.');
```

> ⚠️ **Pièges à montrer** : un trigger qui met à jour sa propre table (récursion), une cascade de triggers invisible pour les développeurs, et le coût d'un trigger ligne à ligne sur un import massif de notes.

**Exemples complémentaires** : mise à jour automatique du classement d'une ligue après saisie d'un score, historique des prix d'un skin dans un marché de jeu vidéo.

### ✅ Checklist formateur S4

- [ ] `publier_avis` fonctionne et annule tout en cas de note invalide
- [ ] Trigger BEFORE de validation + `updated_at`
- [ ] Statistiques de films et historique des critiques opérationnels
- [ ] `s4_procedures_triggers.sql` poussé sur le repo

> 📦 **Livrable de séance** — `s4_procedures_triggers.sql` : 1 à 2 procédures + 3 triggers, avec scénarios de test (cas nominal et cas d'échec).

---

## 🔐 S5 — Transactions, concurrence & sécurité

**Mardi 29/09 · 13:30–17:00** · *Transactions · Sécurité*

> 🎯 **Objectif** : garantir la cohérence quand plusieurs utilisateurs écrivent en même temps, et verrouiller l'accès aux données selon le principe du moindre privilège.

| Horaire | Type | Contenu |
|---|---|---|
| 13:30–14:15 | 🎥 Démo à 2 terminaux | **Transactions** : ACID, `SAVEPOINT`, MVCC, niveaux d'isolation (READ COMMITTED, REPEATABLE READ, SERIALIZABLE) et anomalies associées. |
| 14:15–14:55 | 🧪 Lab | **Concurrence** : likes simultanés, `SELECT … FOR UPDATE`, `SKIP LOCKED` (file de modération des critiques signalées), provoquer puis éviter un deadlock. |
| 14:55–15:05 | ☕ Pause | — |
| 15:05–16:05 | 🧪 Lab | **Sécurité** : rôles et `GRANT/REVOKE`, rôle applicatif sans droits DDL, **Row Level Security** sur le journal et les listes privés, `SECURITY DEFINER` + `search_path` fixé, injection SQL et requêtes paramétrées. |
| 16:05–16:45 | 🧑‍💻 Atelier rendu | Point individuel sur l'avancement du travail à rendre, questions, déblocages. |
| 16:45–17:00 | 🏁 Clôture | Rappel des attendus, de la date limite et de la grille d'évaluation. |

### 🤩 Cas waouh n°1 : les likes perdus d'une critique virale

Une critique devient virale : 50 likes arrivent en même temps. Avec la version naïve, une partie des likes disparaît.

```sql
-- ❌ Version naïve : l'application lit, calcule, puis réécrit
SELECT nb_likes FROM critiques WHERE id = 42;        -- les 2 sessions lisent 120
UPDATE critiques SET nb_likes = 121 WHERE id = 42;   -- les 2 écrivent 121 : un like perdu

-- ✅ Version correcte : un like par personne + incrément atomique
BEGIN;
INSERT INTO likes_critiques (utilisateur_id, critique_id)
VALUES (7, 42);                                      -- la clé primaire empêche le double like
UPDATE critiques SET nb_likes = nb_likes + 1 WHERE id = 42;
COMMIT;
```

### 🤩 Cas waouh n°2 : le journal privé inviolable

```sql
ALTER TABLE journal ENABLE ROW LEVEL SECURITY;

-- Chaque membre gère entièrement ses propres entrées
CREATE POLICY journal_proprietaire ON journal
  USING (utilisateur_id = current_setting('app.user_id')::INT);

-- Tout le monde peut lire les entrées publiques
CREATE POLICY journal_public ON journal
  FOR SELECT
  USING (prive = false);

-- Côté application, après connexion du membre 12 :
SET app.user_id = '12';
SELECT * FROM journal;   -- ses entrées + les entrées publiques des autres, jamais leurs entrées privées
```

> 🚫 **Attention** : le propriétaire d'une table contourne la RLS par défaut. Testez toujours les politiques avec le rôle applicatif, jamais avec `postgres` (ou utilisez `FORCE ROW LEVEL SECURITY`).

**Exemples complémentaires** : réservation de la dernière place d'un tournoi esport (`FOR UPDATE`), clubs sportifs qui ne voient que leurs licenciés (RLS).

### ✅ Checklist formateur S5

- [ ] Likes perdus reproduits puis corrigés
- [ ] Deadlock provoqué et expliqué
- [ ] Rôle applicatif + RLS testés avec le bon rôle
- [ ] Chaque étudiant connaît ce qui reste à faire pour son rendu

> 📦 **Livrable de séance** — `s5_transactions_securite.sql` : scénario de concurrence commenté + script rôles, `GRANT` et RLS.

---

## 📦 Travail à rendre — FilmBox Data Layer

> 🎯 **Objectif** : livrer la couche données complète de FilmBox, comme un tech lead la remettrait à son équipe — fonctionnelle, mesurée, sécurisée et documentée.

> 📅 **Date limite** : à fixer (suggestion : 2 semaines après S5).
> **Rendu** : lien vers le repo Git `filmbox-sql`, historique de commits visible.

### Contenu attendu

| Fichier | Attendu | Séance |
|---|---|---|
| `01_schema.sql` · `02_seed.sql` | Schéma avec contraintes + jeu de données volumineux reproductible | Base |
| `03_requetes.sql` | 10 requêtes analytiques commentées (CTE récursive, window functions, `FILTER`, JSONB, `LATERAL`) | S1 |
| `04_vues_fonctions.sql` | 2 vues dont 1 matérialisée + 3 fonctions PL/pgSQL avec tests | S2 |
| `05_optimisation.md` | Rapport avant/après sur 3 requêtes : plans, index retenus, gains chiffrés | S3 |
| `06_procedures_triggers.sql` | 2 procédures + 3 triggers, cas nominal et cas d'échec | S4 |
| `07_securite.sql` | Rôles, `GRANT/REVOKE`, RLS sur les données privées + scénario de concurrence documenté | S5 |
| `README.md` | Installation, choix techniques, usage de l'IA déclaré, section RSE | Doc |

### 📊 Grille d'évaluation

| Critère | Ce qui est vérifié | Points |
|---|---|---|
| Requêtage avancé | Justesse des résultats, usage pertinent des fonctions avancées | 3 |
| Vues & fonctions | Fonctions robustes (erreurs gérées, volatilité correcte), vue matérialisée justifiée | 3 |
| Optimisation | Plans lus et interprétés, gains mesurés, pas d'index inutile | 4 |
| Procédures & triggers | Atomicité de la publication d'avis, triggers fiables, cas d'échec testés | 4 |
| Transactions & sécurité | Concurrence maîtrisée, moindre privilège, RLS testée avec le bon rôle | 4 |
| Documentation, IA & RSE | README clair, usage de l'IA déclaré et critiqué, impact de sobriété chiffré | 2 |
| **Total** | | **20** |

> ⚠️ **Règles de notation**
> - Un script qui ne s'exécute pas sur une base vierge plafonne le critère concerné à la moitié des points.
> - Une requête issue de l'IA non déclarée n'est pas comptée.

### 🚀 Pour aller plus loin (bonus)

- Partitionnement de la table `journal` par mois et mesure de l'effet sur les requêtes.
- Recherche plein texte sur les synopsis (`tsvector` + index GIN).
- Recommandations « les membres qui ont aimé ce film ont aussi aimé… » en une requête.
- Tests automatisés des fonctions avec pgTAP.

---

*SQL avancé · PostgreSQL — M1TL 2026-2027 · 17,5 h · Plan de cours formateur*
