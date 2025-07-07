INSERT INTO etablissementFinancier (nom, adresse, telephone, email )
VALUES 
('Banque Centrale', 'Antananarivo', '0341123456', 'central@bank.mg') ; 
 
INSERT INTO role (nom) VALUES 
('super_admin'),
('gestionnaire'),
('operateur');

INSERT INTO admin (nom, email, mot_de_passe, role_id)
VALUES 
('Jean Admin', 'jean@admin.com', 'motdepassehash1', 1),
('Marie Gestionnaire', 'marie@gestion.com', 'motdepassehash2', 2);

INSERT INTO type_client (nom, description, montant_min, montant_max, duree_min, duree_max, taux_interet, frais_dossier, penalite_retard)
VALUES 
('Salarie', 'Client salarié en entreprise', 100000.00, 10000000.00, 6, 60, 5.50, 10000.00, 2.00),
('Etudiant', 'Étudiant universitaire', 50000.00, 2000000.00, 3, 24, 3.00, 5000.00, 1.00);

INSERT INTO client (nom, email, date_naissance, id_type_client)
VALUES 
('Rakoto Andry', 'andry@client.com', '1995-06-10', 1),
('Rabe Ny Aina', 'aina@client.com', '2002-03-15', 2);

INSERT INTO type_pret (nom, description, revenu_minimum, montant_min, montant_max, duree_min, duree_max, taux_interet)
VALUES 
('Pret Personnel', 'Prêt pour besoin personnel', 200000.00, 100000.00, 5000000.00, 6, 36, 6.50),
('Pret Etudiant', 'Prêt destiné aux étudiants', 100000.00, 50000.00, 2000000.00, 3, 24, 4.00);

 
INSERT INTO statut_pret (nom, description, couleur) VALUES
('DEMANDE', 'Demande de prêt soumise', '#f39c12'),
('ETUDE', 'Dossier en cours détude', '#3498db'),
('APPROUVE', 'Prêt approuvé, en attente de signature', '#27ae60'),
('REJETE', 'Demande rejetée', '#e74c3c'),
('ACTIF', 'Prêt actif en cours de remboursement', '#2ecc71'),
('SOLDE', 'Prêt entièrement remboursé', '#95a5a6'),
('RETARD', 'Prêt en retard de paiement', '#e67e22'),
('CONTENTIEUX', 'Prêt en procédure contentieuse', '#8e44ad');


INSERT INTO pret (numero_pret, id_client, id_type_pret, id_admin_createur, montant_demande, duree_demandee, motif_demande, montant_accorde, duree_accordee, taux_applique, id_statut)
VALUES 
('PRT001', 1, 1, 1, 1000000.00, 24, 'Renovation maison', 950000.00, 24, 6.5, 2),
('PRT002', 2, 2, 1, 500000.00, 12, 'Frais de scolarité', 500000.00, 12, 4.0, 1);

INSERT INTO type_categorie (type_name) VALUES 
('depot'), ('retrait'), ('transfert');

INSERT INTO type_mouvement (id_type, nom)
VALUES 
(1, 'Apport initial'),
(2, 'Retrait classique');
