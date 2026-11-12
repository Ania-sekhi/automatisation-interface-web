"""Médiathèque : application de démonstration testée par Robot Framework.

API REST (JSON) + interface web (une page HTML qui appelle l'API).
Les données sont enregistrées dans une petite base de données (fichier mediatheque.db),
ce qui permet de les vérifier avec des requêtes SQL.
POST /api/test/reset remet le jeu de données de référence (isolation des tests).
"""
import re
import sqlite3
from datetime import datetime
from pathlib import Path

from flask import Flask, g, jsonify, request, send_from_directory

ICI = Path(__file__).resolve().parent
BASE = ICI / "mediatheque.db"
TITRE_MAX = 100

LIVRES_INITIAUX = [
    (1, "Le Petit Prince", "Antoine de Saint-Exupéry", "9782070408504", None),
    (2, "L'Étranger", "Albert Camus", "9782070360024", None),
    (3, "Les Misérables", "Victor Hugo", "9782253096344", "Alice"),
]

app = Flask(__name__, static_folder="static")
app.json.ensure_ascii = False


# ------------------------------------------------------------------ base de données

def base():
    if "base" not in g:
        g.base = sqlite3.connect(BASE)
        g.base.row_factory = sqlite3.Row
    return g.base


@app.teardown_appcontext
def fermer_base(_):
    connexion = g.pop("base", None)
    if connexion is not None:
        connexion.close()


def maintenant():
    return datetime.now().isoformat(timespec="seconds")


def reinitialiser():
    connexion = sqlite3.connect(BASE)
    connexion.executescript(
        """
        DROP TABLE IF EXISTS emprunts;
        DROP TABLE IF EXISTS livres;
        CREATE TABLE livres (
            id          INTEGER PRIMARY KEY,
            titre       TEXT NOT NULL,
            auteur      TEXT NOT NULL,
            isbn        TEXT NOT NULL UNIQUE,
            emprunteur  TEXT
        );
        CREATE TABLE emprunts (
            id            INTEGER PRIMARY KEY,
            livre_id      INTEGER NOT NULL,
            emprunteur    TEXT NOT NULL,
            date_emprunt  TEXT NOT NULL,
            date_retour   TEXT
        );
        """
    )
    connexion.executemany("INSERT INTO livres VALUES (?, ?, ?, ?, ?)", LIVRES_INITIAUX)
    connexion.execute(
        "INSERT INTO emprunts (livre_id, emprunteur, date_emprunt) VALUES (3, 'Alice', ?)", (maintenant(),)
    )
    connexion.commit()
    nombre = connexion.execute("SELECT COUNT(*) FROM livres").fetchone()[0]
    connexion.close()
    return nombre


def erreur(message, code):
    return jsonify({"erreur": message}), code


def trouver(livre_id):
    return base().execute("SELECT * FROM livres WHERE id = ?", (livre_id,)).fetchone()


def avec_statut(livre):
    livre = dict(livre)
    return {**livre, "statut": "emprunté" if livre["emprunteur"] else "disponible"}


# ------------------------------------------------------------------ routes

@app.get("/")
def accueil():
    return send_from_directory(app.static_folder, "index.html")


@app.get("/api/livres")
def lister():
    livres = base().execute("SELECT * FROM livres ORDER BY id").fetchall()
    return jsonify([avec_statut(l) for l in livres])


@app.get("/api/livres/<int:livre_id>")
def consulter(livre_id):
    livre = trouver(livre_id)
    return jsonify(avec_statut(livre)) if livre else erreur("Livre introuvable", 404)


@app.post("/api/livres")
def ajouter():
    donnees = request.get_json(silent=True) or {}
    titre = str(donnees.get("titre", "")).strip()
    auteur = str(donnees.get("auteur", "")).strip()
    isbn = str(donnees.get("isbn", "")).strip()
    if not titre:
        return erreur("Le titre est obligatoire", 400)
    if len(titre) > TITRE_MAX:
        return erreur(f"Le titre ne doit pas dépasser {TITRE_MAX} caractères", 400)
    if not auteur:
        return erreur("L'auteur est obligatoire", 400)
    if not re.fullmatch(r"\d{13}", isbn):
        return erreur("L'ISBN doit contenir exactement 13 chiffres", 400)
    if base().execute("SELECT 1 FROM livres WHERE isbn = ?", (isbn,)).fetchone():
        return erreur("Un livre avec cet ISBN existe déjà", 409)
    curseur = base().execute(
        "INSERT INTO livres (titre, auteur, isbn) VALUES (?, ?, ?)", (titre, auteur, isbn)
    )
    base().commit()
    return jsonify(avec_statut(trouver(curseur.lastrowid))), 201


@app.post("/api/livres/<int:livre_id>/emprunt")
def emprunter(livre_id):
    livre = trouver(livre_id)
    if not livre:
        return erreur("Livre introuvable", 404)
    emprunteur = str((request.get_json(silent=True) or {}).get("emprunteur", "")).strip()
    if not emprunteur:
        return erreur("Le nom de l'emprunteur est obligatoire", 400)
    if livre["emprunteur"]:
        return erreur("Ce livre est déjà emprunté", 409)
    base().execute("UPDATE livres SET emprunteur = ? WHERE id = ?", (emprunteur, livre_id))
    base().execute(
        "INSERT INTO emprunts (livre_id, emprunteur, date_emprunt) VALUES (?, ?, ?)",
        (livre_id, emprunteur, maintenant()),
    )
    base().commit()
    return jsonify(avec_statut(trouver(livre_id)))


@app.post("/api/livres/<int:livre_id>/retour")
def rendre(livre_id):
    livre = trouver(livre_id)
    if not livre:
        return erreur("Livre introuvable", 404)
    if not livre["emprunteur"]:
        return erreur("Ce livre n'est pas emprunté", 409)
    base().execute("UPDATE livres SET emprunteur = NULL WHERE id = ?", (livre_id,))
    base().execute(
        "UPDATE emprunts SET date_retour = ? WHERE livre_id = ? AND date_retour IS NULL",
        (maintenant(), livre_id),
    )
    base().commit()
    return jsonify(avec_statut(trouver(livre_id)))


@app.delete("/api/livres/<int:livre_id>")
def supprimer(livre_id):
    livre = trouver(livre_id)
    if not livre:
        return erreur("Livre introuvable", 404)
    if livre["emprunteur"]:
        return erreur("Impossible de supprimer un livre emprunté", 409)
    base().execute("DELETE FROM livres WHERE id = ?", (livre_id,))
    base().commit()
    return "", 204


@app.post("/api/test/reset")
def reset():
    return jsonify({"livres": reinitialiser()})


reinitialiser()

if __name__ == "__main__":
    app.run(port=5000)
