create database financier;

use financier;


CREATE TABLE role (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL UNIQUE -- ex: 'super_admin', 'gestionnaire', 'operateur'
);

CREATE TABLE admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL, -- stocker le hash du mot de passe
    role_id INT NOT NULL,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (role_id) REFERENCES role(id)
);


insert into admin(nom,email,mot_de_passe,role_id) VALUES('admin','admin@gmail.com','admin',1);
insert into admin(nom,email,mot_de_passe,role_id) VALUES('comptable','compta@gmail.com','compta',2);


---- Katreto iany 
CREATE TABLE type_mouvement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE -- ex: 'Apport', 'Remboursement', 'Frais', 'Penalité', ...
);  

CREATE TABLE mouvements_fond (
    id INT AUTO_INCREMENT PRIMARY KEY,
    montant DECIMAL(15,2) NOT NULL,
    date_mouvement DATETIME DEFAULT CURRENT_TIMESTAMP,
    type_id INT NOT NULL,
    description VARCHAR(255) NULL,
    FOREIGN KEY (type_mouvement_id) REFERENCES type_mouvement(id)
);

CREATE TABLE fond_etablissement (
  id INT AUTO_INCREMENT PRIMARY KEY,
  montant DECIMAL(15,2) NOT NULL,
  date_ajout DATETIME DEFAULT CURRENT_TIMESTAMP
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


insert into role(nom) values
('super_admin'),
('financier');