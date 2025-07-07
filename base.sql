create database financier;

use financier;


CREATE TABLE etablissementFinancier (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nom VARCHAR(100),
  fonds DECIMAL(15,2) NOT NULL DEFAULT 0
);

CREATE TABLE type_pret (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nom VARCHAR(100),
  taux DECIMAL(5,2) -- Exemple : 5.50 = 5,5%
);


CREATE TABLE type_client (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(50) -- salarié, étudiant, entreprise, etc.
);

CREATE TABLE depot (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_client INT,
  id_etablissement INT,
  montant DECIMAL(15,2),
  date_depot DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_client) REFERENCES client(id),
  FOREIGN KEY (id_etablissement) REFERENCES etablissementFinancier(id)
);


CREATE TABLE compte_client (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_client INT,
  id_etablissement INT,
  solde DECIMAL(15,2) NOT NULL DEFAULT 0,
  UNIQUE(id_client, id_etablissement),
  FOREIGN KEY (id_client) REFERENCES client(id),
  FOREIGN KEY (id_etablissement) REFERENCES etablissementFinancier(id)
);



CREATE TABLE client (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100),
    email VARCHAR(100),
    id_type_client INT,
    FOREIGN KEY (id_type_client) REFERENCES type_client(id)
);


CREATE TABLE pret (
  id INT PRIMARY KEY AUTO_INCREMENT,
  id_client INT,
  id_type_pret INT,
  montant DECIMAL(15,2),
  duree_mois INT,
  date_pret DATE,
  est_rembourse BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (id_client) REFERENCES client(id),
  FOREIGN KEY (id_type_pret) REFERENCES type_pret(id)
);
